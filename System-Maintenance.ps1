<#
.SYNOPSIS
    Script de diagnóstico de salud del sistema y mantenimiento preventivo.
.AUTHOR
    Sonia Herrera
.DESCRIPTION
    Automatiza la comprobación de espacio en disco, verificación de servicios críticos 
    y limpieza de archivos temporales en entornos Windows.
#>

# 1. Comprobación de privilegios de administrador
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) { Write-Warning "Se recomienda ejecutar como Administrador para obtener resultados completos." }

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  DIAGNÓSTICO Y MANTENIMIENTO DEL SISTEMA " -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# 2. Análisis de espacio en disco
Write-Host "[1/3] Comprobando espacio en unidades locales..." -ForegroundColor Yellow
Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" | Select-Object DeviceID, 
    @{Name="Tamaño Total (GB)"; Expression={[math]::round($_.Size/1GB, 2)}},
    @{Name="Espacio Libre (GB)"; Expression={[math]::round($_.FreeSpace/1GB, 2)}} | Format-Table -AutoSize

# 3. Verificación de servicios clave
Write-Host "[2/3] Verificando estado de servicios esenciales..." -ForegroundColor Yellow
$services = @("Dnscache", "W32Time", "Spooler", "WinDefend")
foreach ($service in $services) {
    $status = Get-Service -Name $service -ErrorAction SilentlyContinue
    if ($status) {
        $color = if ($status.Status -eq "Running") { "Green" } else { "Red" }
        Write-Host " -> Servicio $($service): $($status.Status)" -ForegroundColor $color
    }
}

# 4. Limpieza automatizada de temporales
Write-Host ""
Write-Host "[3/3] Ejecutando limpieza de archivos temporales..." -ForegroundColor Yellow
$tempPath = $env:TEMP
if (Test-Path $tempPath) {
    Remove-Item -Path "$tempPath\*" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host " -> Limpieza de temporales completada con éxito." -ForegroundColor Green
}