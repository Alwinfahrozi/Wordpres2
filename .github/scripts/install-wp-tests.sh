#!/usr/bin/env bash

# Arguments (gunakan parameter atau default)
DB_NAME=${1:-wordpress_test}
DB_USER=${2:-root}
DB_PASS=${3:-Af@050602}
DB_HOST=${4:-127.0.0.1}  # Pastikan untuk menerima host dan port, misalnya: 127.0.0.1:3307
WP_VERSION=${5:-latest}

echo "Database Name: $DB_NAME"
echo "Database User: $DB_USER"
echo "Database Password: $DB_PASS"
echo "Database Host: $DB_HOST"
echo "WordPress Version: $WP_VERSION"

# Directory for test library
WP_TESTS_DIR=${WP_TESTS_DIR:-/tmp/wordpress-tests-lib}
WP_CORE_DIR=${WP_CORE_DIR:-/tmp/wordpress}

# Check for required dependencies
command -v curl >/dev/null 2>&1 || { echo >&2 "Error: curl is required but not installed. Aborting."; exit 1; }
command -v svn >/dev/null 2>&1 || { echo >&2 "Error: svn is required but not installed. Aborting."; exit 1; }

# Download WordPress if not already downloaded
if [ ! -d "$WP_CORE_DIR" ]; then
  echo "Downloading WordPress version $WP_VERSION..."
  mkdir -p "$WP_CORE_DIR"
  curl -o /tmp/wordpress.tar.gz https://wordpress.org/wordpress-$WP_VERSION.tar.gz
  tar -zxvf /tmp/wordpress.tar.gz -C "$WP_CORE_DIR" --strip-components=1
fi

# Download WordPress testing library
if [ ! -d "$WP_TESTS_DIR" ]; then
  echo "Downloading WordPress testing library..."
  mkdir -p "$WP_TESTS_DIR"
  svn co --quiet https://develop.svn.wordpress.org/trunk/tests/phpunit/ "$WP_TESTS_DIR"
fi

# Ensure wp-tests-config-sample.php exists
if [ ! -f "$WP_TESTS_DIR/wp-tests-config-sample.php" ]; then
  echo "Downloading wp-tests-config-sample.php..."
  curl -o "$WP_TESTS_DIR/wp-tests-config-sample.php" https://raw.githubusercontent.com/WordPress/wordpress-develop/master/tests/phpunit/includes/wp-tests-config-sample.php
fi

# Create a wp-tests-config.php file with DB credentials
if [ ! -f "$WP_TESTS_DIR/wp-tests-config.php" ]; then
  echo "Setting up wp-tests-config.php with database credentials..."
  cp "$WP_TESTS_DIR/wp-tests-config-sample.php" "$WP_TESTS_DIR/wp-tests-config.php"
  sed -i "s/youremptytestdbnamehere/$DB_NAME/" "$WP_TESTS_DIR/wp-tests-config.php"
  sed -i "s/yourusernamehere/$DB_USER/" "$WP_TESTS_DIR/wp-tests-config.php"
  sed -i "s/yourpasswordhere/$DB_PASS/" "$WP_TESTS_DIR/wp-tests-config.php"
  sed -i "s|localhost|${DB_HOST}|" "$WP_TESTS_DIR/wp-tests-config.php"
fi

# Install the test database
echo "Creating test database..."
for attempt in {1..5}; do
  if mysql -u"$DB_USER" -p"$DB_PASS" -h"$DB_HOST" -e "CREATE DATABASE IF NOT EXISTS $DB_NAME;"; then
    echo "Test database created successfully."
    break
  else
    echo "Attempt $attempt: Unable to create test database. Retrying in 5 seconds..."
    sleep 5
  fi
done

if [ "$attempt" -eq 5 ]; then
  echo "Error: Could not create test database after multiple attempts."
  exit 1
fi

echo "Setup complete. WordPress testing environment is ready."
