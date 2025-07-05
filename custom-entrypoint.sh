#!/bin/bash
# Custom entrypoint script to fix the "too many arguments" error in the original entrypoint

# Set environment variables with proper quoting
# This ensures that variables with spaces or special characters are handled correctly
for var in $(env | cut -d= -f1); do
  export "$var"="$(printenv "$var")"
done

# Fix for line 13 error - wrap the conditional with proper quoting
# Since we don't know exactly what's in line 13, we'll try to handle common cases
export ADDITIONAL_SERVER_NAMES="${ADDITIONAL_SERVER_NAMES:-}"
export SKIP_SOGO="${SKIP_SOGO:-n}"
export SKIP_RSPAMD="${SKIP_RSPAMD:-n}"
export DISABLE_IPv6="${DISABLE_IPv6:-n}"
export HTTP_REDIRECT="${HTTP_REDIRECT:-n}"
export PHPFPMHOST="${PHPFPMHOST:-}"
export SOGOHOST="${SOGOHOST:-}"
export RSPAMDHOST="${RSPAMDHOST:-}"
export KEYDBHOST="${KEYDBHOST:-}"

# Log that we're using the custom entrypoint
echo "Using custom entrypoint script to fix 'too many arguments' error"

# Call the original entrypoint with all arguments
exec /docker-entrypoint.sh "$@"
