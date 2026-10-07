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
    if ($Auth) {
        $config = @(
            'silent',
            'output = NUL',
            'write-out = %{http_code}',
            'max-time = 5',
            'connect-timeout = 3',
            ('header = Authorization: Bearer {0}' -f $Auth),
            ('url = {0}' -f $Url)
        ) -join "`n"
        $code = $config | & curl.exe --config - 2>$null
    } else {
        $curlArgs += $Url
        $code = & curl.exe @curlArgs 2>$null
    }
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

function Unquote-Scalar([string]$Value) {
    if ($null -eq $Value) { return '' }
    $v = $Value.Trim()
    if ($v.Length -ge 2) {
        $a = $v[0]
        $b = $v[$v.Length - 1]
        if (($a -eq '"' -and $b -eq '"') -or ($a -eq "'" -and $b -eq "'")) {
            return $v.Substring(1, $v.Length - 2)
        }
    }
    return $v
}

$hostName = '127.0.0.1'
$port = 8317
$tlsEnable = $false
$imagePolicy = ''
$authDir = 'auths'
$keys = New-Object System.Collections.Generic.List[string]
$subtypes = New-Object System.Collections.Generic.List[string]
$upstream = New-Object System.Collections.Generic.List[string]
$scalars = @{}
$seen = @{}
$stack = New-Object System.Collections.Generic.List[object]
$accessKeys = New-Object System.Collections.Generic.List[string]
$legacyKeys = New-Object System.Collections.Generic.List[string]
$serverSubtypes = New-Object System.Collections.Generic.List[string]
$legacySubtypes = New-Object System.Collections.Generic.List[string]
$apiKeysIsMap = $false
$scalarPaths = @(
    'server.host', 'host',
    'server.port', 'port',
    'server.tls.enable', 'tls.enable',
    'multimedia.disable-image-generation', 'disable-image-generation',
    'oauth.auth-dir', 'auth-dir'
)

foreach ($raw in Get-Content -LiteralPath $cfgPath) {
    if ($raw -match '^\s*(#|$)') { continue }
    $indent = 0
    foreach ($ch in $raw.ToCharArray()) {
        if ($ch -eq ' ') { $indent++ }
        elseif ($ch -eq "`t") { $indent += 2 }
        else { break }
    }
    $trimmed = $raw.Trim()
    if ($trimmed.StartsWith('- ')) {
        $path = ''
        if ($stack.Count -gt 0) { $path = (($stack | ForEach-Object { $_.Key }) -join '.') }
        $item = $trimmed.Substring(2).Trim()
        $scalar = $null
        if ($item -match '^(?:"([^"]*)"|''([^'']*)''|(\S+))\s*$') {
            $scalar = $Matches[1]
            if (-not $scalar) { $scalar = $Matches[2] }
            if (-not $scalar) { $scalar = $Matches[3] }
        }
        if ([string]::IsNullOrWhiteSpace($scalar)) { continue }
        $scalar = $scalar.Trim()
        if ($path -eq 'access.api-keys') { $accessKeys.Add($scalar) }
        elseif ($path -eq 'api-keys') { $legacyKeys.Add($scalar) }
        elseif ($path -eq 'server.discovery.subtypes') { $serverSubtypes.Add($scalar) }
        elseif ($path -eq 'discovery.subtypes') { $legacySubtypes.Add($scalar) }
        continue
    }
    if ($trimmed -notmatch '^([^:#]+):(.*)$') { continue }
    $key = (Unquote-Scalar $Matches[1].Trim())
    if ([string]::IsNullOrWhiteSpace($key)) { continue }
    $val = $Matches[2]
    while ($stack.Count -gt 0 -and $stack[$stack.Count - 1].Indent -ge $indent) {
        $stack.RemoveAt($stack.Count - 1)
    }
    $parent = ''
    if ($stack.Count -gt 0) { $parent = (($stack | ForEach-Object { $_.Key }) -join '.') }
    $stack.Add([pscustomobject]@{ Indent = $indent; Key = $key })
    $path = if ($parent) { "$parent.$key" } else { $key }
    $seen[$path] = $true
    if ($scalarPaths -contains $path) {
        $parsed = Unquote-Scalar $val
        if (-not [string]::IsNullOrWhiteSpace($parsed)) { $scalars[$path] = $parsed.Trim() }
    }
    if ($parent -eq '' -and ($key -match '^.+-api-key$' -or $key -eq 'openai-compatibility' -or $key -eq 'remote-management' -or $key -eq 'management')) {
        if (-not $upstream.Contains($key)) { $upstream.Add($key) }
    }
    if ($parent -eq 'api-keys') {
        $apiKeysIsMap = $true
        $field = 'api-keys.' + $key
        if (-not $upstream.Contains($field)) { $upstream.Add($field) }
    }
}

if ($scalars.ContainsKey('server.host')) { $hostName = [string]$scalars['server.host'] }
elseif ($scalars.ContainsKey('host')) { $hostName = [string]$scalars['host'] }
$pickedPort = $null
if ($scalars.ContainsKey('server.port')) { $pickedPort = [string]$scalars['server.port'] }
elseif ($scalars.ContainsKey('port')) { $pickedPort = [string]$scalars['port'] }
if ($pickedPort -match '^\d+$') { $port = [int]$pickedPort }
$pickedTls = $null
if ($scalars.ContainsKey('server.tls.enable')) { $pickedTls = [string]$scalars['server.tls.enable'] }
elseif ($scalars.ContainsKey('tls.enable')) { $pickedTls = [string]$scalars['tls.enable'] }
if ($pickedTls) { $tlsEnable = ($pickedTls.ToLowerInvariant() -eq 'true') }
if ($scalars.ContainsKey('multimedia.disable-image-generation')) {
    $imagePolicy = [string]$scalars['multimedia.disable-image-generation']
} elseif ($scalars.ContainsKey('disable-image-generation')) {
    $imagePolicy = [string]$scalars['disable-image-generation']
}
if ($scalars.ContainsKey('oauth.auth-dir')) { $authDir = [string]$scalars['oauth.auth-dir'] }
elseif ($scalars.ContainsKey('auth-dir')) { $authDir = [string]$scalars['auth-dir'] }
if ($seen.ContainsKey('access.api-keys')) {
    $keys = $accessKeys
} elseif ($seen.ContainsKey('api-keys') -and -not $apiKeysIsMap) {
    $keys = $legacyKeys
}
if ($seen.ContainsKey('server.discovery.subtypes')) {
    $subtypes = $serverSubtypes
} elseif ($seen.ContainsKey('discovery.subtypes')) {
    $subtypes = $legacySubtypes
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
