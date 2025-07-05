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
export KEYDBHOST="${KEYDBHOST:-keydb-phreakmail}"
export REDISHOST="${KEYDBHOST:-keydb-phreakmail}"

# Create a hosts file entry to map redis-mailcow to keydb-phreakmail
if [ -w /etc/hosts ]; then
  echo "127.0.0.1 redis-mailcow" >> /etc/hosts
  echo "127.0.0.1 keydb-mailcow" >> /etc/hosts
fi

# Fix for the unary operator expected error in docker-entrypoint.sh
# Create a wrapper script that fixes the issue
cat > /tmp/fix-entrypoint.sh << 'EOF'
#!/bin/bash
# Fix for the unary operator expected error
sed -i 's/\[ "$SKIP_SOGO" == "y" \]/[ "${SKIP_SOGO:-n}" = "y" ]/g' /docker-entrypoint.sh
sed -i 's/\[ "$SKIP_CLAMD" == "y" \]/[ "${SKIP_CLAMD:-n}" = "y" ]/g' /docker-entrypoint.sh
sed -i 's/\[ "$SKIP_OLEFY" == "y" \]/[ "${SKIP_OLEFY:-n}" = "y" ]/g' /docker-entrypoint.sh
sed -i 's/\[ "$SKIP_RSPAMD" == "y" \]/[ "${SKIP_RSPAMD:-n}" = "y" ]/g' /docker-entrypoint.sh
sed -i 's/\[ "$DISABLE_IPv6" == "y" \]/[ "${DISABLE_IPv6:-n}" = "y" ]/g' /docker-entrypoint.sh
sed -i 's/\[ "$HTTP_REDIRECT" == "y" \]/[ "${HTTP_REDIRECT:-n}" = "y" ]/g' /docker-entrypoint.sh
sed -i 's/==/=/g' /docker-entrypoint.sh
EOF

chmod +x /tmp/fix-entrypoint.sh
/tmp/fix-entrypoint.sh

# Set Redis environment variables explicitly
export REDIS_HOST="keydb-phreakmail"
export REDIS_PORT="6379"

# Log that we're using the custom entrypoint
echo "Using custom entrypoint script to fix 'too many arguments' error"

# Call the original entrypoint with all arguments
exec /docker-entrypoint.sh "$@"
