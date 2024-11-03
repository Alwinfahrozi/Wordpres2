#!/usr/bin/env bash

# Arguments
DB_NAME=$1
DB_USER=$2
DB_PASS=$3
DB_HOST=${4-localhost}
WP_VERSION=${5-latest}

# Directory for test library
WP_TESTS_DIR=${WP_TESTS_DIR:-/tmp/wordpress-tests-lib}
WP_CORE_DIR=${WP_CORE_DIR:-/tmp/wordpress}

# Download WordPress if not already downloaded
if [ ! -d "$WP_CORE_DIR" ]; then
  mkdir -p $WP_CORE_DIR
  curl -o /tmp/wordpress.tar.gz https://wordpress.org/wordpress-$WP_VERSION.tar.gz
  tar -zxvf /tmp/wordpress.tar.gz -C /tmp/
fi

# Download WordPress testing library
if [ ! -d "$WP_TESTS_DIR" ]; then
  mkdir -p $WP_TESTS_DIR
  svn co --quiet https://develop.svn.wordpress.org/trunk/tests/phpunit/ $WP_TESTS_DIR
fi

# Create a wp-tests-config.php file with DB credentials
cp $WP_TESTS_DIR/wp-tests-config-sample.php $WP_TESTS_DIR/wp-tests-config.php
sed -i "s/youremptytestdbnamehere/$DB_NAME/" $WP_TESTS_DIR/wp-tests-config.php
sed -i "s/yourusernamehere/$DB_USER/" $WP_TESTS_DIR/wp-tests-config.php
sed -i "s/yourpasswordhere/$DB_PASS/" $WP_TESTS_DIR/wp-tests-config.php
sed -i "s|localhost|${DB_HOST}|" $WP_TESTS_DIR/wp-tests-config.php

# Install the test database
mysql -u"$DB_USER" -p"$DB_PASS" -h"$DB_HOST" -e "CREATE DATABASE IF NOT EXISTS $DB_NAME;"
 
