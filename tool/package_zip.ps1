# =============================================================
# zip 版（インストール不要版）を作るスクリプト
#
# 使い方（プロジェクトのフォルダで）：
#   flutter build windows --release --dart-define-from-file=env.json
#   powershell -ExecutionPolicy Bypass -File tool\package_zip.ps1
#
# build\installer\FusenTask-portable.zip ができる。
# 展開したフォルダの flutter_d_app.exe を起動すれば使える。
# =============================================================
$ErrorActionPreference = 'Stop'

$release = Join-Path $PSScriptRoot '..\build\windows\x64\runner\Release'
$outDir  = Join-Path $PSScriptRoot '..\build\installer'
$zip     = Join-Path $outDir 'FusenTask-portable.zip'

if (-not (Test-Path $release)) {
  throw "先に flutter build windows --release --dart-define-from-file=env.json を実行してください"
}
New-Item -ItemType Directory -Force $outDir | Out-Null
if (Test-Path $zip) { Remove-Item $zip }

Compress-Archive -Path (Join-Path $release '*') -DestinationPath $zip
Write-Host "作成しました: $zip"
