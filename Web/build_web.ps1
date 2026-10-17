# Exporta el juego a Web (preset "Web" de export_presets.cfg) en build/web
# y copia mushin.ar adentro, en build/web/mushin.
#
# Uso:
#   powershell -NoProfile -ExecutionPolicy Bypass -File Web/build_web.ps1 -Godot "C:\ruta\Godot_v4.7.2-stable_win64.exe"
# Después, para probarlo: Web/demo.ps1 -Root build/web
param(
  [Parameter(Mandatory = $true)][string]$Godot
)

$project = Split-Path -Parent $PSScriptRoot
$out = Join-Path $project "build\web"
$log = Join-Path $project "build\export.log"

if (Test-Path $out) { Remove-Item $out -Recurse -Force }
New-Item -ItemType Directory -Force $out | Out-Null

Write-Host "Exportando a $out ..."
$p = Start-Process -FilePath $Godot -Wait -PassThru -WindowStyle Hidden -ArgumentList @(
  '--headless', '--path', "`"$project`"", '--export-release', 'Web', "`"$out\index.html`"", '--log-file', "`"$log`""
)
if ($p.ExitCode -ne 0 -or -not (Test-Path "$out\index.wasm")) {
  Write-Host "Falló la exportación (código $($p.ExitCode)). Revisá $log"
  exit 1
}

Copy-Item -Recurse (Join-Path $PSScriptRoot "mushin") (Join-Path $out "mushin")
# GitHub Pages: sin esto ignora archivos y carpetas que empiezan con _
New-Item -ItemType File -Force (Join-Path $out ".nojekyll") | Out-Null

Write-Host "Listo: $out"
