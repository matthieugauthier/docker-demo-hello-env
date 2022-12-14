FROM registry.access.redhat.com/ubi8/ubi:8.6


ENV PHP_VERSION="8.1.7-1.el8.remi"


RUN yum update  -y \
    # Install Apache
    && yum install -y httpd \
    && groupmod -g 2000 apache \
    && usermod -u 2000 apache \
    && echo 'ServerSignature Off' >> /etc/httpd/conf/httpd.conf \
    && echo 'ServerTokens Prod' >> /etc/httpd/conf/httpd.conf \
     # Install PHP \
    && dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm \
    && dnf install -y https://rpms.remirepo.net/enterprise/remi-release-8.rpm
RUN yum install -y \
        php81-php \
        php81-php-cli \
        php81-php-fpm \
        php81-php-pgsql \
        php81-php-pdo \
    && echo "module load php81" >> ~/.bashrc \
    && sed -i 's/expose_php = On/expose_php = Off/' /etc/opt/remi/php81/php.ini \
    && echo 'env[APP_HELLO] = $APP_HELLO' >> /etc/opt/remi/php81/php-fpm.d/www.conf
    # Instapp psql client
RUN dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-8-x86_64/pgdg-redhat-repo-latest.noarch.rpm
RUN dnf install -y postgresql12 \
    # Clean
    && rm /etc/yum.repos.d/*
ADD app-vhost.conf /etc/httpd/conf.d/app-vhost.conf

RUN mkdir /var/www/app/
ADD index.php /var/www/app/index.php


WORKDIR /var/www/

ADD entrypoint.sh /root
RUN ["chmod", "+x", "/root/entrypoint.sh"]
ENTRYPOINT ["/root/entrypoint.sh"]
CMD ["/usr/sbin/httpd", "-DFOREGROUND"]
