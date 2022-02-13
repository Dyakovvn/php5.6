FROM php:5.6-fpm
WORKDIR /var/www

# Additional extensions
RUN apt-get update \
    && apt-get install -y unzip \
        ca-certificates \
        libicu-dev \
        libmcrypt-dev \
        libssl-dev \
        librabbitmq-dev \
        libsodium-dev \
        libmemcached-dev \
        libpq-dev \
        libxml2 \
        libxml2-dev \
	zlib1g-dev \
	libmcrypt4 \
    && pecl install amqp \
    && pecl install memcached-2.2.0 \
    && pecl install redis-2.2.8 \
    && docker-php-ext-configure bcmath --enable-bcmath \
    && docker-php-ext-configure intl --enable-intl \
    && docker-php-ext-configure pcntl --enable-pcntl \
    && docker-php-ext-configure pdo_mysql --with-pdo-mysql \
    && docker-php-ext-configure pdo_pgsql --with-pgsql \
    && docker-php-ext-configure mbstring --enable-mbstring \
    && docker-php-ext-configure soap --enable-soap \
    && docker-php-ext-install \
        bcmath \
        intl \
        mcrypt \
        pcntl \
        pdo_mysql \
        pdo_pgsql \
        mbstring \
        soap \
    && sed -i '/^mozilla\/DST_Root_CA_X3/s/^/!/' /etc/ca-certificates.conf \
    && update-ca-certificates -f

# Possible values for ext-name:
# bcmath bz2 calendar ctype curl dba dom enchant exif fileinfo filter ftp gd gettext gmp hash iconv imap interbase intl
# json ldap mbstring mcrypt mssql mysql mysqli oci8 odbc opcache pcntl pdo pdo_dblib pdo_firebird pdo_mysql pdo_oci
# pdo_odbc pdo_pgsql pdo_sqlite pgsql phar posix pspell readline recode reflection session shmop simplexml snmp soap
# sockets spl standard sybase_ct sysvmsg sysvsem sysvshm tidy tokenizer wddx xml xmlreader xmlrpc xmlwriter xsl zip

RUN apt-get update && apt-get install -q -y --no-install-recommends \
        git \
	openssh-client \
	rsync \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libssl-dev \
        libz-dev \
        mysql-client \
        zlib1g-dev \
        libsqlite3-dev \
        zip \
        libxml2-dev \
        libcurl3-dev \
        libedit-dev \
        libpspell-dev \
        libldap2-dev \
        unixodbc-dev \
        libpq-dev \
	nodejs \
	vim \
	libgd-dev \
	libmagickwand-dev \
	libfreetype6-dev \
        libjpeg-dev \
        libxpm-dev \
        libpng-dev \
        libicu-dev \
        libxslt1-dev \
        libmemcached-dev \
        libxml2-dev \
	libxpm-dev \
	libvpx-dev \
	ssmtp mailutils \
	procps

# https://bugs.php.net/bug.php?id=49876
RUN ln -fs /usr/lib/x86_64-linux-gnu/libldap.so /usr/lib/

#    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-png-dir=/usr/include/ --with-xpm-dir=/usr/include/ --enable-gd-jis-conv \
RUN echo "Installing PHP extensions" \
    && pecl install imagick mongo \
    && docker-php-ext-configure gd  \
    --with-freetype-dir=/usr/lib/x86_64-linux-gnu/ \
    --with-jpeg-dir=/usr/lib/x86_64-linux-gnu/ \
    --with-xpm-dir=/usr/lib/x86_64-linux-gnu/ \
    --with-vpx-dir=/usr/lib/x86_64-linux-gnu/ \
    --with-png-dir=/usr/lib/x86_64-linux-gnu/ \
    --enable-gd-jis-conv \
    && docker-php-ext-install iconv mcrypt pdo_mysql pdo_pgsql pdo_sqlite pcntl zip bcmath simplexml xmlrpc soap pspell ldap mbstring mysql mysqli zip sockets bz2 gettext gd \
    && docker-php-ext-enable  iconv mcrypt mongo pdo_mysql pdo_pgsql pdo_sqlite pcntl zip bcmath simplexml xmlrpc soap pspell ldap mbstring mysql mysqli zip sockets bz2 gettext imagick gd \
    && ldconfig

# install composer
RUN curl -sS https://getcomposer.org/installer | php -- --filename=composer --install-dir=/bin
ENV PATH /root/.composer/vendor/bin:$PATH

 # Copy configuration

COPY config/php.ini /usr/local/etc/php/

COPY config/amqp.ini /usr/local/etc/php/conf.d/

COPY config/fpm/php-fpm.conf /usr/local/etc/

COPY config/fpm/pool.d /usr/local/etc/pool.d

COPY config/redis.ini /usr/local/etc/php/conf.d/

COPY config/memcached.ini /usr/local/etc/php/conf.d/

COPY config/mongodb.ini /usr/local/etc/php/conf.d/

# Clean up, try to reduce image size (much as you can on Debian..)
RUN apt-get autoremove -y \
&& apt-get clean all \
&& rm -rf /var/lib/apt/lists/* \
&& rm -rf /usr/share/doc /usr/share/man /usr/share/locale \
&& rm -f /usr/local/etc/php-fpm.d/*.conf \
&& rm -rf /usr/src/php \
&& rm -rf /var/www \
&& mkdir -p /var/www

EXPOSE 9000
