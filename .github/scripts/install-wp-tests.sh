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

# Check for required dependencies
command -v curl >/dev/null 2>&1 || { echo >&2 "curl is required but not installed. Aborting."; exit 1; }
command -v svn >/dev/null 2>&1 || { echo >&2 "svn is required but not installed. Aborting."; exit 1; }

# Download WordPress if not already downloaded
if [ ! -d "$WP_CORE_DIR" ]; then
  echo "Downloading WordPress version $WP_VERSION..."
  mkdir -p $WP_CORE_DIR
  curl -o /tmp/wordpress.tar.gz https://wordpress.org/wordpress-$WP_VERSION.tar.gz
  tar -zxvf /tmp/wordpress.tar.gz -C $WP_CORE_DIR --strip-components=1
fi

# Download WordPress testing library
if [ ! -d "$WP_TESTS_DIR" ]; then
  echo "Downloading WordPress testing library..."
  mkdir -p $WP_TESTS_DIR
  svn co --quiet https://develop.svn.wordpress.org/trunk/tests/phpunit/ $WP_TESTS_DIR
fi

# Ensure wp-tests-config-sample.php exists
if [ ! -f "$WP_TESTS_DIR/wp-tests-config-sample.php" ]; then
  echo "Downloading wp-tests-config-sample.php..."
 
