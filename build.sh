# build.sh
#!/bin/bash
echo "Building PHP 7.1 development environment..."

# 创建必要目录
mkdir -p logs/nginx logs/php www

# 构建PHP镜像
docker compose build --no-cache php71

if [ $? -eq 0 ]; then
    echo "Build successful!"
else
    echo "Build failed!"
    exit 1
fi