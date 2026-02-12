FROM php:7.1-fpm

# 设置时区和基础环境
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 首先更新sources.list使用archive.debian.org（因为buster已经EOL）
RUN echo "deb http://archive.debian.org/debian buster main" > /etc/apt/sources.list && \
    echo "deb http://archive.debian.org/debian buster-updates main" >> /etc/apt/sources.list && \
    echo "deb http://archive.debian.org/debian-security buster/updates main" >> /etc/apt/sources.list

# 第二步：更新+安装工具，保留原逻辑
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    apt-transport-https \
    gnupg \
    wget \
    curl \
    unzip && \
    rm -rf /var/lib/apt/lists/*

# 安装编译所需的基本工具和库
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    autoconf \
    automake \
    libtool \
    pkg-config \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libwebp-dev \
    libxpm-dev \
    libzip-dev \
    libicu-dev \
    libxml2-dev \
    libssl-dev \
    libcurl4-openssl-dev \
    libonig-dev \
    libedit-dev \
    libxslt-dev \
    libz-dev \
    libbz2-dev \
    libpq-dev && \
    rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-configure gd \
    --with-freetype-dir=/usr/include/ \
    --with-jpeg-dir=/usr/include/ \
    --with-png-dir=/usr/include/ \
    --with-webp-dir=/usr/include/ \
    --with-xpm-dir=/usr/include/

# 配置和安装PHP扩展
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ && \
    docker-php-ext-configure pgsql --with-pgsql=/usr/local/pgsql && \
    docker-php-ext-install -j$(nproc) \
    gd \
    bcmath \
    bz2 \
    calendar \
    exif \
    gettext \
    intl \
    mbstring \
    mysqli \
    pdo_mysql \
    pdo_pgsql \
    pgsql \
    soap \
    sockets \
    sysvmsg \
    sysvsem \
    sysvshm \
    xmlrpc \
    xsl \
    zip \
    opcache \
    pcntl

# 安装常用PECL扩展所需的构建工具
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libmemcached-dev \
    libmcrypt-dev && \
    rm -rf /var/lib/apt/lists/*

# 创建 Xdebug 日志目录并设置权限（归属www-data）
RUN mkdir -p /var/log/xdebug /tmp/xdebug && \
    chown -R www-data:www-data /var/log/xdebug /tmp/xdebug && \
    chmod -R 755 /var/log/xdebug /tmp/xdebug
    
# 从源码编译安装Xdebug 2.9.8
RUN cd /tmp && \
    wget --no-check-certificate https://xdebug.org/files/xdebug-2.9.8.tgz && \
    tar -xvzf xdebug-2.9.8.tgz && \
    cd xdebug-2.9.8 && \
    phpize && \
    ./configure && \
    make && \
    make install && \
    docker-php-ext-enable xdebug && \
    rm -rf /tmp/xdebug-2.9.8 /tmp/xdebug-2.9.8.tgz

# 从PECL编译安装redis扩展 4.3.0
RUN cd /tmp && \
    wget --no-check-certificate https://pecl.php.net/get/redis-4.3.0.tgz -O redis.tar.gz && \
    tar -xzf redis.tar.gz && \
    cd redis-4.3.0 && \
    phpize && \
    ./configure && \
    make && make install && \
    docker-php-ext-enable redis && \
    rm -rf /tmp/redis-4.3.0 /tmp/redis.tar.gz

# 安装Composer（使用国内镜像）
RUN curl -sS https://install.phpcomposer.com/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
    composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/

# ========== 关键修改1：统一目录和权限 ==========
# 1. 创建项目根目录
RUN mkdir -p /var/www/html && \
    chown -R www-data:www-data /var/www/html && \
    chmod 755 /var/www/html

# 2. 提前创建所有需要写入的目录（包括报错的debug_sql）
RUN mkdir -p /var/www/html/opc/src/image/cache \
    # 核心：创建debug_sql所在的cache目录及子目录
    && mkdir -p /var/www/html/opc/src/system/cache/debug_sql \
    # PHP日志目录
    && mkdir -p /var/log/php \
    # PHP-FPM运行目录
    && mkdir -p /var/run/php-fpm \
    # 统一设置所有目录归属www-data
    && chown -R www-data:www-data \
        /var/www/html/opc/src/image/cache \
        /var/www/html/opc/src/system/cache \
        /var/log/php \
        /var/run/php-fpm \
    && chmod 755 /var/log/php \
    && chmod 755 /var/run/php-fpm

# ========== 关键修改2：复制配置文件并确保权限 ==========
# 复制PHP自定义配置
COPY php.ini /usr/local/etc/php/conf.d/custom.ini
# 复制PHP-FPM配置（关键：里面指定运行用户为www-data）
COPY php-fpm.conf /usr/local/etc/php-fpm.d/zz-custom.conf
# 确保配置文件归属root，权限644（符合安全规范）
RUN chown root:root /usr/local/etc/php/conf.d/custom.ini /usr/local/etc/php-fpm.d/zz-custom.conf && \
    chmod 644 /usr/local/etc/php/conf.d/custom.ini /usr/local/etc/php-fpm.d/zz-custom.conf

# 清理
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/man/* /usr/share/doc/*

# 设置工作目录
WORKDIR /var/www/html

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD php -r "echo 'OK';" || exit 1

# 启动PHP-FPM（前台运行）
CMD ["php-fpm", "-F"]