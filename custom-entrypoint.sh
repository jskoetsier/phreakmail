#!/bin/bash
# Custom entrypoint script that completely replaces the original entrypoint

# Set environment variables with proper quoting
for var in $(env | cut -d= -f1); do
  export "$var"="$(printenv "$var")"
done

# Set default values for all environment variables that might be used in conditionals
export ADDITIONAL_SERVER_NAMES="${ADDITIONAL_SERVER_NAMES:-}"
export SKIP_SOGO="${SKIP_SOGO:-n}"
export SKIP_RSPAMD="${SKIP_RSPAMD:-n}"
export SKIP_CLAMD="${SKIP_CLAMD:-n}"
export SKIP_OLEFY="${SKIP_OLEFY:-n}"
export DISABLE_IPv6="${DISABLE_IPv6:-n}"
export HTTP_REDIRECT="${HTTP_REDIRECT:-n}"
export PHPFPMHOST="${PHPFPMHOST:-}"
export SOGOHOST="${SOGOHOST:-}"
export RSPAMDHOST="${RSPAMDHOST:-}"
export KEYDBHOST="${KEYDBHOST:-keydb-phreakmail}"
export REDISHOST="keydb-phreakmail"
export REDIS_HOST="keydb-phreakmail"
export REDIS_PORT="6379"

# Create hosts file entries to map redis-mailcow to keydb-phreakmail
if [ -w /etc/hosts ]; then
  echo "127.0.0.1 redis-mailcow" >> /etc/hosts
  echo "127.0.0.1 keydb-mailcow" >> /etc/hosts
  echo "127.0.0.1 keydb-phreakmail" >> /etc/hosts
fi

# Log that we're using the custom entrypoint
echo "Using custom entrypoint script that bypasses the original entrypoint"

# Start PHP-FPM directly with the provided arguments
if [ "$1" = "php-fpm" ]; then
  # If the command is php-fpm, execute it with any additional arguments
  echo "Starting PHP-FPM directly..."
  exec php-fpm "$@"
else
  # Otherwise, execute the command as is
  echo "Executing command: $@"
  exec "$@"
fi
