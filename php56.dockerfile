FROM gjchen/php56
MAINTAINER gjchen <gjchen.tw@gmail.com>

RUN	apk --no-cache --no-progress upgrade -f && \
	apk --no-cache --no-progress add coreutils ca-certificates \
	php5-ctype \
	php5-dom \
	php5-json \
	php5-openssl \
	php5-pdo \
	php5-phar \
	php5-xml \
	&& \
	apk --no-cache --no-progress add --virtual pecl-build-tools \
	php5-dev php5-pear autoconf build-base && \
	pear config-set php_ini /etc/php5/conf.d/xdebug.ini && \
	touch /etc/php5/conf.d/xdebug.ini && \
	php /usr/share/pear/peclcmd.php install xdebug && \
	rm -rf /tmp/pear && \
	apk --no-progress --force del pecl-build-tools && \
	COMPOSER_INSTALLER=$(wget -q -O- https://getcomposer.org/installer) && \
	test $(echo "${COMPOSER_INSTALLER}" | sha384sum | awk '{print $1}') = $(wget -q -O - https://composer.github.io/installer.sig) && \
	echo "${COMPOSER_INSTALLER}" | php -- --install-dir=/usr/bin &&\
	mkdir -p /app/public && mv /app/index.php /app/public

COPY	nginx_laravel_server.conf /etc/nginx/conf.d/default.conf

ENV	PHP_ERROR_LOG=syslog \
	PHP_LOG_ERRORS=1 \
	PHP_DISPLAY_ERRORS=1 \
	PHP_ERROR_REPORTING=-1 \
	PHP_TIMEZONE="UTC" \
	PHP_SHORT_OPEN_TAG=0 \
	PHP_MAX_EXECUTION_TIME=30 \
	PHP_MAX_INPUT_TIME=60 \
	PHP_MEMORY_LIMIT=256M \
	PHP_CLI_MEMORY_LIMIT=512M \
	PHP_POST_MAX_SIZE=8M \
	PHP_UPLOAD_MAX_FILESIZE=128M \
	PHP_SESSION_NAME=PHPSESSID \
	PHP_SESSION_SAVE_HANDLER=files \
	PHP_SESSION_SAVE_PATH=/tmp \
	PHPFPM_LISTEN=127.0.0.1:9000 \
	PHPFPM_USER=nobody \
	PHPFPM_GROUP=nobody \
	PHPFPM_PM=ondemand \
	PHPFPM_PM_MAX_CHILDREN=32 \
	PHPFPM_PM_START_SERVERS=4 \
	PHPFPM_PM_MIN_SPARE_SERVERS=2 \
	PHPFPM_PM_MAX_SPARE_SERVERS=6 \
	PHPFPM_PM_MAX_REQUESTS=16 \
	PHP_XDEBUG_HOST="172.17.0.1" \
	PHP_XDEBUG_PROFILER_ENABLE=On \
	PHP_XDEBUG_REMOTE_ENABLE=On \
	PHP_XDEBUG_REMOTE_PORT=9000 \
	PHP_XDEBUG_REMOTE_HANDLER=dbgp

VOLUME	["/app"]
EXPOSE	80

