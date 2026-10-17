# Sirve mushin.ar en http://localhost:8080/ para la demo.
# Con esto corriendo, la pestaña "Invertir" de la compu (juego en el editor, F5) abre el módulo
# en el navegador. Cerrar esta ventana apaga el servidor.
#
# Uso: clic derecho > "Ejecutar con PowerShell", o:
#   powershell -NoProfile -ExecutionPolicy Bypass -File Web/demo.ps1
# Para servir un export Web completo: -Root build/web
param(
  [int]$Port = 8080,
  [string]$Root = (Join-Path $PSScriptRoot "mushin")
)

$Root = (Resolve-Path $Root).Path
$types = @{
  '.html' = 'text/html; charset=utf-8'; '.css' = 'text/css'; '.js' = 'application/javascript'
  '.json' = 'application/json'; '.png' = 'image/png'; '.svg' = 'image/svg+xml'
  '.wasm' = 'application/wasm'; '.pck' = 'application/octet-stream'
}

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$Port/")
$listener.Start()
Write-Host "mushin.ar listo en http://localhost:$Port/  (sirviendo $Root)"
Write-Host "Dejá esta ventana abierta durante la demo."

while ($listener.IsListening) {
  $ctx = $listener.GetContext()
  $path = [Uri]::UnescapeDataString($ctx.Request.Url.AbsolutePath.TrimStart('/'))
  if ($path -eq '' -or $path.EndsWith('/')) { $path += 'index.html' }
  $file = [IO.Path]::GetFullPath((Join-Path $Root $path))
  # No servir nada fuera de la carpeta
  if ($file.StartsWith($Root) -and (Test-Path $file -PathType Leaf)) {
    $bytes = [IO.File]::ReadAllBytes($file)
    $ext = [IO.Path]::GetExtension($file).ToLower()
    $ctx.Response.ContentType = if ($types[$ext]) { $types[$ext] } else { 'application/octet-stream' }
    $ctx.Response.OutputStream.Write($bytes, 0, $bytes.Length)
  } else {
    $ctx.Response.StatusCode = 404
  }
  $ctx.Response.Close()
}
