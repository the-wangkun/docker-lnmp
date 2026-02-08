# check_docker_network.sh
#!/bin/bash

echo "🔍 检查Docker网络配置..."

# 检查是否可以解析aliyun.com
echo "1. 测试DNS解析:"
docker run --rm alpine nslookup mirrors.aliyun.com

echo ""
echo "2. 测试网络连接:"
docker run --rm alpine ping -c 3 mirrors.aliyun.com

echo ""
echo "3. 检查Docker DNS配置:"
docker network inspect bridge | grep -A 5 "DNS"

echo ""
echo "4. 检查系统DNS:"
cat /etc/resolv.conf

echo ""
echo "5. 测试直接使用archive.debian.org:"
docker run --rm debian:buster-slim bash -c "echo 'deb http://archive.debian.org/debian buster main' > /etc/apt/sources.list && apt-get update && echo '✅ 更新成功' || echo '❌ 更新失败'"