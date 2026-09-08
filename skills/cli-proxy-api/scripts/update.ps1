[CmdletBinding()]
param(
    [ValidateSet('all', 'cpa', 'keeper')]
    [string]$Target = 'all',

    [string]$Version,

    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# 1. 自动发现本地代理并设置环境变量（curl.exe 下载 GitHub Releases 需要）
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

$cpaRoot = "C:\Users\38993\AppData\Local\CLIProxyAPI"
$keeperRoot = "C:\Users\38993\AppData\Local\CPAUsageKeeper"

$results = [ordered]@{}

# 2. 更新 CLIProxyAPI
if ($Target -in @('all', 'cpa')) {
    $cpaScript = Join-Path $cpaRoot "update.ps1"
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
                $httpCode = & curl.exe --silent --output NUL --write-out "%{http_code}" --max-time 3 http://127.0.0.1:8317/management.html
                $results['CLIProxyAPI'] = @{
                    Status = 'AlreadyLatest'
                    Version = '7.2.155'
                    TaskState = $taskState
                    ManagementHTTP = $httpCode
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

# 3. 更新 CPAUsageKeeper
if ($Target -in @('all', 'keeper')) {
    $keeperScript = Join-Path $keeperRoot "update.ps1"
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
                $httpCode = & curl.exe --silent --output NUL --write-out "%{http_code}" --max-time 3 http://127.0.0.1:8080/
                $results['CPAUsageKeeper'] = @{
                    Status = 'AlreadyLatest'
                    Version = '1.15.2'
                    TaskState = $taskState
                    ManagementHTTP = $httpCode
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
    } else {
        Write-Host " [ERR] $key : $($item.Status) - $($item.Error)" -ForegroundColor Red
    }
}
Write-Host "================================================" -ForegroundColor Cyan
