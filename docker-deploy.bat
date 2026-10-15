@echo off
setlocal

echo ============================================
echo  StarKids - Docker 部署
echo  模式: 本地构建
echo ============================================
echo.

echo 构建应用镜像（复用依赖和 Next.js 缓存）...
docker compose --progress=plain build app
if errorlevel 1 exit /b 1

echo 启动服务...
docker compose up -d --no-build
if errorlevel 1 exit /b 1

echo.
echo ============================================
echo  部署完成！
echo  访问: http://localhost:3000
echo.
echo  常用命令:
echo    docker compose logs -f    查看日志
echo    docker compose down       停止服务
echo    docker compose up -d      启动服务
echo.
echo ============================================
pause
