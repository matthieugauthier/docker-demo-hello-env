#!/bin/bash -i
set -e

module load php81

php-fpm # Must be launched

exec "$@"
