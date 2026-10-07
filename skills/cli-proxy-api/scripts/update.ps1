[CmdletBinding()]
param(
    [ValidateSet('all', 'cpa', 'keeper')]
    [string]$Target = 'all',

    [string]$Version,

    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ($Version -and $Target -eq 'all') {
    throw 'Version requires Target to be cpa or keeper.'
}

# Discover local mixed proxy for GitHub downloads.
if (-not $env:HTTP_PROXY -and -not $env:ALL_PROXY) {
    $candidates = @(7897, 7890, 10808, 10809, 20171, 7893)
    $active = Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue |
        Where-Object { $_.LocalAddress -in @('127.0.0.1', '0.0.0.0', '::1', '::') -and $candidates -contains $_.LocalPort } |
        Select-Object -First 1

    if ($active) {
        $proxyUrl = "http://127.0.0.1:$($active.LocalPort)"
        $env:HTTP_PROXY = $proxyUrl
        $env:HTTPS_PROXY = $proxyUrl
        $env:ALL_PROXY = $proxyUrl
        Write-Host "[proxy] Using detected proxy: $proxyUrl" -ForegroundColor Cyan
    } else {
        Write-Warning "[proxy] No local proxy port detected. If GitHub download fails, ensure your proxy is running."
    }
}

$cpaRoot = Join-Path $env:LOCALAPPDATA 'CLIProxyAPI'
$keeperRoot = Join-Path $env:LOCALAPPDATA 'CPAUsageKeeper'

function Get-YamlPort([string]$Path, [int]$Default) {
    if (-not (Test-Path -LiteralPath $Path)) { return $Default }
    $stack = New-Object System.Collections.Generic.List[object]
    $serverPort = $null
    $rootPort = $null
    foreach ($raw in Get-Content -LiteralPath $Path) {
        if ($raw -match '^\s*(#|$)') { continue }
        $indent = 0
        foreach ($ch in $raw.ToCharArray()) {
            if ($ch -eq ' ') { $indent++ }
            elseif ($ch -eq "`t") { $indent += 2 }
            else { break }
        }
        $trimmed = $raw.Trim()
        if ($trimmed.StartsWith('- ')) { continue }
        if ($trimmed -notmatch '^([^:#]+):(.*)$') { continue }
        $key = $Matches[1].Trim().Trim('"').Trim("'")
        $val = $Matches[2].Trim().Trim('"').Trim("'")
        while ($stack.Count -gt 0 -and $stack[$stack.Count - 1].Indent -ge $indent) {
            $stack.RemoveAt($stack.Count - 1)
        }
        $parent = ''
        if ($stack.Count -gt 0) { $parent = (($stack | ForEach-Object { $_.Key }) -join '.') }
        $stack.Add([pscustomobject]@{ Indent = $indent; Key = $key })
        if ($key -eq 'port' -and $val -match '^\d+$') {
            if ($parent -eq 'server') { $serverPort = [int]$val }
            elseif ($parent -eq '') { $rootPort = [int]$val }
        }
    }
    if ($null -ne $serverPort) { return $serverPort }
    if ($null -ne $rootPort) { return $rootPort }
    return $Default
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

function Get-KeeperHealthUrl {
    $envFile = Join-Path $keeperRoot '.env'
    $hostName = Get-DotEnvValue $envFile 'APP_HOST'
    if ([string]::IsNullOrWhiteSpace($hostName) -or $hostName -in @('0.0.0.0', '::', '*')) {
        $hostName = '127.0.0.1'
    }
    $port = Get-DotEnvValue $envFile 'APP_PORT'
    if ([string]::IsNullOrWhiteSpace($port)) { $port = '8080' }
    return "http://${hostName}:${port}/"
}

function Get-CpaInstalledVersion {
    $log = Join-Path $cpaRoot 'logs\main.log'
    if (Test-Path -LiteralPath $log) {
        $match = Get-Content -LiteralPath $log -Tail 300 -Encoding UTF8 |
            Select-String -Pattern 'CLIProxyAPI Version:\s*([^,\s]+)' |
            Select-Object -Last 1
        if ($match -and $match.Matches.Count -gt 0) {
            return $match.Matches[0].Groups[1].Value.TrimStart('v')
        }
    }
    $exe = Join-Path $cpaRoot 'bin\cli-proxy-api.exe'
    if (Test-Path -LiteralPath $exe) {
        $text = & $exe --help 2>&1 | Out-String
        if ($text -match 'CLIProxyAPI Version:\s*([^,\s]+)') {
            return $Matches[1].TrimStart('v')
        }
    }
    return 'none'
}

function Get-KeeperInstalledVersion {
    $exe = Join-Path $keeperRoot 'bin\cpa-usage-keeper.exe'
    if (-not (Test-Path -LiteralPath $exe)) { return 'none' }
    $output = & $exe -v 2>&1 | Select-Object -First 1
    $text = [string]$output
    if ($text -match 'v?(\d+\.\d+\.\d+)') { return $Matches[1] }
    return 'none'
}

function Get-HttpCode([string]$Url) {
    $code = & curl.exe --silent --output NUL --write-out '%{http_code}' --max-time 3 $Url 2>$null
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($code)) { return '000' }
    return $code
}

$cpaPort = Get-YamlPort (Join-Path $cpaRoot 'config.yaml') 8317
$cpaHealth = "http://127.0.0.1:$cpaPort/management.html"
$keeperHealth = Get-KeeperHealthUrl

$results = [ordered]@{}

if ($Target -in @('all', 'cpa')) {
    $cpaScript = Join-Path $cpaRoot 'update.ps1'
    if (Test-Path -LiteralPath $cpaScript) {
        Write-Host "`n>>> Checking / Updating CLIProxyAPI..." -ForegroundColor Green
        try {
            $params = @{}
            if ($Version -and $Target -eq 'cpa') { $params['Version'] = $Version }
            if ($Force) { $params['Force'] = $true }
            $res = & $cpaScript @params
            if ($null -ne $res) {
                $results['CLIProxyAPI'] = @{
                    Status = 'Updated'
                    Version = $res.Version
                    TaskState = $res.TaskState
                    ManagementHTTP = $res.ManagementHTTP
                }
            } else {
                $taskState = (Get-ScheduledTask -TaskName 'CLIProxyAPI' -ErrorAction SilentlyContinue).State
                $results['CLIProxyAPI'] = @{
                    Status = 'AlreadyLatest'
                    Version = Get-CpaInstalledVersion
                    TaskState = $taskState
                    ManagementHTTP = Get-HttpCode $cpaHealth
                }
            }
        } catch {
            $results['CLIProxyAPI'] = @{
                Status = 'Failed'
                Error = $_.Exception.Message
            }
        }
    } else {
        $results['CLIProxyAPI'] = @{ Status = 'NotFound'; Path = $cpaScript }
    }
}

if ($Target -in @('all', 'keeper')) {
    $keeperScript = Join-Path $keeperRoot 'update.ps1'
    if (Test-Path -LiteralPath $keeperScript) {
        Write-Host "`n>>> Checking / Updating CPAUsageKeeper..." -ForegroundColor Green
        try {
            $params = @{}
            if ($Version -and $Target -eq 'keeper') { $params['Version'] = $Version }
            if ($Force) { $params['Force'] = $true }
            $res = & $keeperScript @params
            if ($null -ne $res) {
                $results['CPAUsageKeeper'] = @{
                    Status = 'Updated'
                    Version = $res.Version
                    TaskState = $res.TaskState
                    ManagementHTTP = $res.ManagementHTTP
                }
            } else {
                $taskState = (Get-ScheduledTask -TaskName 'CPAUsageKeeper' -ErrorAction SilentlyContinue).State
                $results['CPAUsageKeeper'] = @{
                    Status = 'AlreadyLatest'
                    Version = Get-KeeperInstalledVersion
                    TaskState = $taskState
                    ManagementHTTP = Get-HttpCode $keeperHealth
                }
            }
        } catch {
            $results['CPAUsageKeeper'] = @{
                Status = 'Failed'
                Error = $_.Exception.Message
            }
        }
    } else {
        $results['CPAUsageKeeper'] = @{ Status = 'NotFound'; Path = $keeperScript }
    }
}

Write-Host "`n================ Update Summary ================" -ForegroundColor Cyan
foreach ($key in $results.Keys) {
    $item = $results[$key]
    if ($item.Status -in @('Updated', 'AlreadyLatest')) {
        Write-Host " [OK] $key : $($item.Status) | Version $($item.Version) | Task: $($item.TaskState) | HTTP: $($item.ManagementHTTP)" -ForegroundColor Green
    } elseif ($item.Status -eq 'NotFound') {
        Write-Host " [ERR] $key : NotFound - $($item.Path)" -ForegroundColor Red
    } else {
        Write-Host " [ERR] $key : $($item.Status) - $($item.Error)" -ForegroundColor Red
    }
}
Write-Host '================================================' -ForegroundColor Cyan

$failed = @($results.Values | Where-Object { $_.Status -notin @('Updated', 'AlreadyLatest') })
if ($failed.Count -gt 0) { exit 1 }
exit 0
