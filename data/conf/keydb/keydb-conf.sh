#!/bin/sh

cat <<EOF > /keydb.conf
requirepass ${KEYDBPASS:-}
user quota_notify on nopass ~QW_* -@all +get +hget +ping
EOF

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
