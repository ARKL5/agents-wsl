# Read-only CLIProxyAPI live-check. Print facts; never print secrets.
# Exit 0 only when management is 200, image policy is passthrough,
# and /v1/models is 200 (or skipped because key_count != 1).
# ASCII only so Windows PowerShell 5.1 can parse without a UTF-8 BOM.
$ErrorActionPreference = 'Continue'

$cpaRoot = Join-Path $env:LOCALAPPDATA 'CLIProxyAPI'
$keeperRoot = Join-Path $env:LOCALAPPDATA 'CPAUsageKeeper'
$cfgPath = Join-Path $cpaRoot 'config.yaml'
$cpaExe = Join-Path $cpaRoot 'bin\cli-proxy-api.exe'
$keeperExe = Join-Path $keeperRoot 'bin\cpa-usage-keeper.exe'
$keeperEnv = Join-Path $keeperRoot '.env'

function Line([string]$Name, [string]$Value) {
    if ($null -eq $Value) { $Value = '' }
    $Value = ([string]$Value) -replace '[\r\n\t]+', ' '
    Write-Output ('{0}={1}' -f $Name, $Value)
}

function Get-HttpCode([string]$Url, [string]$Auth) {
    $curlArgs = @('--silent', '--output', 'NUL', '--write-out', '%{http_code}', '--max-time', '5', '--connect-timeout', '3')
    if ($Auth) { $curlArgs += @('-H', "Authorization: Bearer $Auth") }
    $curlArgs += $Url
    $code = & curl.exe @curlArgs 2>$null
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($code)) { return '000' }
    return [string]$code
}

function Get-TaskState([string]$Name) {
    $t = Get-ScheduledTask -TaskName $Name -ErrorAction SilentlyContinue
    if (-not $t) { return 'none' }
    return [string]$t.State
}

function Get-Listen([string]$ExePath) {
    if (-not (Test-Path -LiteralPath $ExePath)) { return 'none' }
    $procs = @(Get-CimInstance Win32_Process -ErrorAction SilentlyContinue | Where-Object {
        $_.ExecutablePath -and $_.ExecutablePath.Equals($ExePath, [StringComparison]::OrdinalIgnoreCase)
    })
    $ports = New-Object System.Collections.Generic.List[string]
    foreach ($p in $procs) {
        $conns = @(Get-NetTCPConnection -OwningProcess $p.ProcessId -State Listen -ErrorAction SilentlyContinue)
        foreach ($c in $conns) {
            $ports.Add(('{0}:{1}' -f $c.LocalAddress, $c.LocalPort))
        }
    }
    if ($ports.Count -eq 0) { return 'none' }
    return (($ports | Select-Object -Unique) -join ',')
}

function Get-DotEnvValue([string]$Path, [string]$Key) {
    if (-not (Test-Path -LiteralPath $Path)) { return $null }
    $prefix = '^\s*' + [regex]::Escape($Key) + '\s*=\s*(.*)$'
    foreach ($raw in Get-Content -LiteralPath $Path) {
        if ($raw -match $prefix) {
            return $Matches[1].Trim().Trim('"').Trim("'")
        }
    }
    return $null
}

function Get-CpaVersion {
    $log = Join-Path $cpaRoot 'logs\main.log'
    if (Test-Path -LiteralPath $log) {
        $match = Get-Content -LiteralPath $log -Tail 300 -Encoding UTF8 |
            Select-String -Pattern 'CLIProxyAPI Version:\s*([^,\s]+)' |
            Select-Object -Last 1
        if ($match -and $match.Matches.Count -gt 0) {
            return $match.Matches[0].Groups[1].Value.TrimStart('v')
        }
    }
    if (Test-Path -LiteralPath $cpaExe) {
        $text = & $cpaExe --help 2>&1 | Out-String
        if ($text -match 'CLIProxyAPI Version:\s*([^,\s]+)') {
            return $Matches[1].TrimStart('v')
        }
    }
    return 'none'
}

function Get-KeeperVersion {
    if (-not (Test-Path -LiteralPath $keeperExe)) { return 'none' }
    $text = [string](& $keeperExe -v 2>&1 | Select-Object -First 1)
    if ($text -match 'v?(\d+\.\d+\.\d+)') { return $Matches[1] }
    return 'none'
}

Line 'cpa_root' $cpaRoot
Line 'config' $cfgPath

if (-not (Test-Path -LiteralPath $cfgPath)) {
    Line 'result' 'fail'
    exit 1
}

$hostName = '127.0.0.1'
$port = 8317
$tlsEnable = $false
$imagePolicy = ''
$authDir = 'auths'
$keys = New-Object System.Collections.Generic.List[string]
$subtypes = New-Object System.Collections.Generic.List[string]
$upstream = New-Object System.Collections.Generic.List[string]
$section = ''

foreach ($raw in Get-Content -LiteralPath $cfgPath) {
    if ($raw -match '^(\S[^:]*):') {
        $section = $Matches[1]
        if ($section -match '^.+-api-key$' -or $section -eq 'openai-compatibility' -or $section -eq 'remote-management') {
            if (-not $upstream.Contains($section)) { $upstream.Add($section) }
        }
    }
    if ($raw -match '^host:\s*["'']?([^"'']+)["'']?\s*$') { $hostName = $Matches[1].Trim() }
    if ($raw -match '^port:\s*["'']?(\d+)') { $port = [int]$Matches[1] }
    if ($raw -match '^disable-image-generation:\s*["'']?([^"'']+)["'']?\s*$') {
        $imagePolicy = $Matches[1].Trim()
    }
    if ($raw -match '^auth-dir:\s*["'']?([^"'']+)["'']?\s*$') { $authDir = $Matches[1].Trim() }
    if ($section -eq 'tls' -and $raw -match '^\s+enable:\s*(true|false)') {
        $tlsEnable = ($Matches[1] -eq 'true')
    }
    if ($section -eq 'api-keys' -and $raw -match '^\s+-\s+(?:"([^"]*)"|''([^'']*)''|(\S+))\s*$') {
        $val = $Matches[1]; if (-not $val) { $val = $Matches[2] }; if (-not $val) { $val = $Matches[3] }
        if (-not [string]::IsNullOrWhiteSpace($val)) { $keys.Add($val.Trim()) }
    }
    if ($section -eq 'discovery' -and $raw -match '^\s+-\s+["'']?([^"'']+)["'']?\s*$') {
        $st = $Matches[1].Trim()
        if ($st) { $subtypes.Add($st) }
    }
}

$clientHost = $hostName
if ($hostName -in @('0.0.0.0', '::', '*')) { $clientHost = '127.0.0.1' }
$scheme = if ($tlsEnable) { 'https' } else { 'http' }
$base = '{0}://{1}:{2}' -f $scheme, $clientHost, $port
$keyCount = $keys.Count
$authPath = $authDir
if (-not [System.IO.Path]::IsPathRooted($authDir)) {
    $authPath = Join-Path $cpaRoot $authDir
}
$authCount = 0
if (Test-Path -LiteralPath $authPath) {
    $authCount = @(Get-ChildItem -LiteralPath $authPath -File -ErrorAction SilentlyContinue).Count
}

Line 'cpa_exe' $(if (Test-Path -LiteralPath $cpaExe) { $cpaExe } else { 'missing' })
Line 'cpa_version' (Get-CpaVersion)
Line 'cpa_task' (Get-TaskState 'CLIProxyAPI')
Line 'cpa_listen' (Get-Listen $cpaExe)
Line 'bind' ('{0}:{1}' -f $hostName, $port)
Line 'base' $base
Line 'openai_base' ($base + '/v1')
Line 'tls' ([string]$tlsEnable)
Line 'disable_image_generation' $(if ($imagePolicy) { $imagePolicy } else { 'missing' })
Line 'discovery_subtypes' $(if ($subtypes.Count -gt 0) { ($subtypes -join ',') } else { 'none' })
Line 'api_keys' ([string]$keyCount)
Line 'upstream_key_fields' $(if ($upstream.Count -gt 0) { ($upstream -join ',') } else { 'none' })
Line 'auth_files' ([string]$authCount)

$mgmt = Get-HttpCode ($base + '/management.html') $null
Line 'management' $mgmt

$models = 'skipped'
$modelsReason = ''
if ($keyCount -eq 1) {
    $models = Get-HttpCode ($base + '/v1/models') $keys[0]
} elseif ($keyCount -eq 0) {
    $modelsReason = 'no-api-keys'
} else {
    $modelsReason = 'key_count_not_one'
}
Line 'models' $models
if ($modelsReason) { Line 'models_reason' $modelsReason }

$keeperHost = Get-DotEnvValue $keeperEnv 'APP_HOST'
if ([string]::IsNullOrWhiteSpace($keeperHost)) { $keeperHost = '127.0.0.1' }
$keeperPort = Get-DotEnvValue $keeperEnv 'APP_PORT'
if ([string]::IsNullOrWhiteSpace($keeperPort)) { $keeperPort = '8080' }
$keeperBase = 'http://{0}:{1}/' -f $keeperHost, $keeperPort

Line 'keeper_root' $keeperRoot
Line 'keeper_exe' $(if (Test-Path -LiteralPath $keeperExe) { $keeperExe } else { 'missing' })
Line 'keeper_version' (Get-KeeperVersion)
Line 'keeper_task' (Get-TaskState 'CPAUsageKeeper')
Line 'keeper_listen' (Get-Listen $keeperExe)
Line 'keeper_base' $keeperBase
Line 'keeper_http' (Get-HttpCode $keeperBase $null)

$imageOk = ($imagePolicy -eq 'passthrough')
$ok = ($mgmt -eq '200') -and $imageOk -and (($keyCount -ne 1) -or ($models -eq '200'))
Line 'result' $(if ($ok) { 'pass' } else { 'fail' })
if ($ok) { exit 0 } else { exit 1 }
