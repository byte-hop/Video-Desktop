# 影视窗 打包脚本：把当前源码的 out 打回安装版 app.asar，并重启安装版
# 用法：在 E:\影视窗Windows 下执行 & .\.tmp-pack.ps1
# 输出：pack exit / asar / running 三行
$ErrorActionPreference = 'Stop'

$root = 'E:\影视窗Windows'
$inst = 'C:\Users\Administrator\AppData\Local\Programs\影视窗'
$exe = Join-Path $inst '影视窗.exe'
$asarTarget = Join-Path $inst 'resources\app.asar'
$stage = Join-Path $root '.tmp-asar\app'
$stageAsar = Join-Path $root '.tmp-asar\app.asar'
$asarCmd = Join-Path $root 'node_modules\.bin\asar.cmd'

# 1) 关掉正在跑的安装版，免得文件被占用
Get-Process -Name '影视窗' -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Milliseconds 800

# 2) 暂存目录：首次要准备 package.json + 生产依赖，之后每次只换 out
if (-not (Test-Path -LiteralPath (Join-Path $stage 'node_modules'))) {
  if (Test-Path -LiteralPath $stage) { Remove-Item -LiteralPath $stage -Recurse -Force }
  New-Item -ItemType Directory -Path $stage | Out-Null
  Copy-Item -LiteralPath (Join-Path $root 'package.json') -Destination $stage
  Copy-Item -LiteralPath (Join-Path $root 'package-lock.json') -Destination $stage
  Push-Location $stage
  & npm install --omit=dev --ignore-scripts --no-audit --no-fund --silent
  $npmExit = $LASTEXITCODE
  Pop-Location
  if ($npmExit -ne 0) { throw "生产依赖安装失败：$npmExit" }
}

$outStage = Join-Path $stage 'out'
if (Test-Path -LiteralPath $outStage) { Remove-Item -LiteralPath $outStage -Recurse -Force }
Copy-Item -LiteralPath (Join-Path $root 'out') -Destination $outStage -Recurse
# package.json 每次都覆盖：版本号 / 依赖声明变化时，装进去的必须是当前这份
Copy-Item -LiteralPath (Join-Path $root 'package.json') -Destination $stage -Force

# 3) 打包成 asar
if (Test-Path -LiteralPath $stageAsar) { Remove-Item -LiteralPath $stageAsar -Force }
& $asarCmd pack $stage $stageAsar | Out-Null
$packExit = $LASTEXITCODE

# 4) 覆盖安装版，先按时间戳备份旧的（备份放安装目录 resources\backup，跟着版本走）
if (Test-Path -LiteralPath $asarTarget) {
  $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
  $backupDir = Join-Path $inst 'resources\backup'
  if (-not (Test-Path -LiteralPath $backupDir)) { New-Item -ItemType Directory -Path $backupDir -Force | Out-Null }
  Copy-Item -LiteralPath $asarTarget -Destination (Join-Path $backupDir "app.asar.$stamp") -Force
}
Copy-Item -LiteralPath $stageAsar -Destination $asarTarget -Force

# 4.5) 窗口 / 任务栏 / 托盘图标：resources\icon.ico 不进 asar，单独同步
$iconSrc = Join-Path $root 'build\icon.ico'
$iconDst = Join-Path $inst 'resources\icon.ico'
if (Test-Path -LiteralPath $iconSrc) {
  Copy-Item -LiteralPath $iconSrc -Destination $iconDst -Force
}

# 5) 正常启动安装版（不带调试端口），等进程起来
Start-Process -FilePath $exe -ArgumentList '' -WorkingDirectory $inst
Start-Sleep -Seconds 6
$running = @(Get-Process -Name '影视窗' -ErrorAction SilentlyContinue).Count

"pack exit: $packExit"
"asar: $((Get-Item -LiteralPath $asarTarget).Length)"
"running: $running"
