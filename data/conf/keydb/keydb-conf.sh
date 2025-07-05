#!/bin/sh

cat <<EOF > /keydb.conf
user quota_notify on nopass ~QW_* -@all +get +hget +ping
EOF

if [ -n "$KEYDBPASS" ]; then
  echo "requirepass $KEYDBPASS" >> /keydb.conf
fi

if [ -n "$KEYDBMASTERPASS" ]; then
  echo "masterauth $KEYDBMASTERPASS" >> /keydb.conf
fi

# Add KeyDB-specific configuration
if [ -n "$KEYDB_THREADS" ]; then
  echo "server-threads $KEYDB_THREADS" >> /keydb.conf
  echo "Using KeyDB with $KEYDB_THREADS threads"
fi

echo "Starting KeyDB server..."
exec keydb-server /keydb.conf
