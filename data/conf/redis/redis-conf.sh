#!/bin/sh

cat <<EOF > /redis.conf
requirepass $REDISPASS
user quota_notify on nopass ~QW_* -@all +get +hget +ping
EOF

if [ -n "$REDISMASTERPASS" ]; then
  echo "masterauth $REDISMASTERPASS" >> /redis.conf
fi

# Add KeyDB-specific configuration
if [ -n "$KEYDB_THREADS" ]; then
  echo "server-threads $KEYDB_THREADS" >> /redis.conf
  echo "Using KeyDB with $KEYDB_THREADS threads"
fi

# Check if we're using KeyDB or Redis
if command -v keydb-server > /dev/null 2>&1; then
  echo "Starting KeyDB server..."
  exec keydb-server /redis.conf
else
  echo "Starting Redis server..."
  exec redis-server /redis.conf
fi
