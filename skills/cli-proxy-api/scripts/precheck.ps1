# Read-only CLIProxyAPI precheck. Print facts; never print secrets.
# Exit 0 only when management is 200 and /v1/models is 200 (or skipped because key_count != 1).
$ErrorActionPreference = 'Continue'

$cpaRoot = 'C:\Users\38993\AppData\Local\CLIProxyAPI'
$cfgPath = Join-Path $cpaRoot 'config.yaml'

function Line([string]$Name, [string]$Value) {
    Write-Output ('{0}={1}' -f $Name, $Value)
}

if (-not (Test-Path -LiteralPath $cfgPath)) {
    Line 'config' "missing $cfgPath"
    Line 'result' 'fail'
    exit 1
}

$hostName = '127.0.0.1'
$port = 8317
$tlsEnable = $false
$keys = New-Object System.Collections.Generic.List[string]
$section = ''

foreach ($raw in Get-Content -LiteralPath $cfgPath) {
    if ($raw -match '^(\S[^:]*):') {
        $section = $Matches[1]
    }
    if ($raw -match '^host:\s*["'']?([^"'']+)["'']?\s*$') { $hostName = $Matches[1].Trim() }
    if ($raw -match '^port:\s*["'']?(\d+)') { $port = [int]$Matches[1] }
    if ($section -eq 'tls' -and $raw -match '^\s+enable:\s*(true|false)') {
        $tlsEnable = ($Matches[1] -eq 'true')
    }
    if ($section -eq 'api-keys' -and $raw -match '^\s+-\s+(?:"([^"]*)"|''([^'']*)''|(\S+))\s*$') {
        $val = $Matches[1]; if (-not $val) { $val = $Matches[2] }; if (-not $val) { $val = $Matches[3] }
        if (-not [string]::IsNullOrWhiteSpace($val)) { $keys.Add($val.Trim()) }
    }
}

$scheme = if ($tlsEnable) { 'https' } else { 'http' }
$base = '{0}://{1}:{2}' -f $scheme, $hostName, $port
$keyCount = $keys.Count

Line 'config' $cfgPath
Line 'base' $base
Line 'tls' ([string]$tlsEnable)
Line 'api_keys' ([string]$keyCount)

function Get-HttpCode([string]$Url, [string]$Auth) {
    $args = @('--silent', '--output', 'NUL', '--write-out', '%{http_code}', '--max-time', '5', '--connect-timeout', '3')
    if ($Auth) { $args += @('-H', "Authorization: Bearer $Auth") }
    $args += $Url
    $code = & curl.exe @args 2>$null
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($code)) { return '000' }
    return [string]$code
}

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

$ok = ($mgmt -eq '200') -and (($keyCount -ne 1) -or ($models -eq '200'))
Line 'result' $(if ($ok) { 'pass' } else { 'fail' })
if ($ok) { exit 0 } else { exit 1 }
