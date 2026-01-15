@echo off
chcp 65001 >nul
title 更新博客并发布（update）

echo ===============================
echo 🚀 开始更新博客
echo 目录：%~dp0
echo ===============================

:: 切到脚本所在目录
cd /d "%~dp0"
if errorlevel 1 (
  echo ❌ 无法切换到脚本目录
  pause
  exit /b 1
)

:: 确保能找到 git（有些机器双击时 PATH 不完整）
where git >nul 2>&1
if errorlevel 1 (
  echo ⚠️ 未在 PATH 中找到 git，尝试添加常见 Git 路径...
  if exist "C:\Program Files\Git\cmd" set "PATH=%PATH%;C:\Program Files\Git\cmd"
  if exist "C:\Program Files (x86)\Git\cmd" set "PATH=%PATH%;C:\Program Files (x86)\Git\cmd"
)

where git >nul 2>&1
if errorlevel 1 (
  echo ❌ 仍找不到 git。请先安装 Git for Windows 或把 git 加入 PATH。
  echo 你可以在 PowerShell 里运行：git --version 验证
  pause
  exit /b 1
)

echo ✅ Git： 
git --version

:: 检查是否是 Git 仓库
git rev-parse --is-inside-work-tree >nul 2>&1
if errorlevel 1 (
  echo ❌ 当前目录不是 Git 仓库（没有 .git）
  pause
  exit /b 1
)

:: 检查是否有改动
for /f "delims=" %%A in ('git status --porcelain') do set "HASCHANGES=1"
if not defined HASCHANGES (
  echo ℹ️ 没有检测到任何改动，不需要更新
  pause
  exit /b 0
)

:: 生成提交信息（时间）
set "MSG=update: %date% %time%"
echo 📌 提交信息：%MSG%

git add -A
if errorlevel 1 (
  echo ❌ git add 失败
  pause
  exit /b 1
)

git commit -m "%MSG%"
if errorlevel 1 (
  echo ❌ git commit 失败（可能没有 staged 改动或提交信息问题）
  pause
  exit /b 1
)

echo 🔄 同步远端（rebase）...
git pull --rebase
if errorlevel 1 (
  echo ❌ git pull --rebase 失败（可能有冲突或网络问题）
  pause
  exit /b 1
)

echo ⬆️ 推送到 GitHub...
git push
if errorlevel 1 (
  echo ❌ git push 失败（网络/权限/远端冲突）
  pause
  exit /b 1
)

echo ===============================
echo ✅ 更新完成！Cloudflare Pages 将自动部署
echo ===============================
pause
