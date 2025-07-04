#!/bin/bash
# Custom entrypoint script to fix the "Bad file descriptor" error in SOGo

# Ensure standard file descriptors are properly set up
exec 1>/proc/1/fd/1
exec 2>/proc/1/fd/2

# Set environment variables with proper quoting
# This ensures that variables with spaces or special characters are handled correctly
for var in $(env | cut -d= -f1); do
  export "$var"="$(printenv "$var")"
done

# Fix for specific environment variables that might be causing issues
export DBNAME="${DBNAME:-}"
export DBUSER="${DBUSER:-}"
export DBPASS="${DBPASS:-}"
export TZ="${TZ:-}"
export LOG_LINES="${LOG_LINES:-9999}"
export PHREAKMAIL_HOSTNAME="${PHREAKMAIL_HOSTNAME:-}"
export PHREAKMAIL_PASS_SCHEME="${PHREAKMAIL_PASS_SCHEME:-BLF-CRYPT}"
export ACL_ANYONE="${ACL_ANYONE:-disallow}"
export ALLOW_ADMIN_EMAIL_LOGIN="${ALLOW_ADMIN_EMAIL_LOGIN:-n}"
export IPV4_NETWORK="${IPV4_NETWORK:-172.22.1}"
export SOGO_EXPIRE_SESSION="${SOGO_EXPIRE_SESSION:-480}"
export SKIP_SOGO="${SKIP_SOGO:-n}"
export MASTER="${MASTER:-y}"
export REDIS_SLAVEOF_IP="${REDIS_SLAVEOF_IP:-}"
export REDIS_SLAVEOF_PORT="${REDIS_SLAVEOF_PORT:-}"
export REDISPASS="${REDISPASS:-}"

# Log that we're using the custom entrypoint
echo "Using custom entrypoint script for SOGo to fix 'Bad file descriptor' error"

# Call the original entrypoint with all arguments
if [ -f /docker-entrypoint.sh ]; then
  exec /docker-entrypoint.sh "$@"
else
  # If no entrypoint script exists, just run the command
  exec "$@"
fi
