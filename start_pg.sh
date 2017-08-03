#!/bin/bash
echo "Starting PostgreSQL..."
exec setuser postgres /usr/lib/postgresql/9.5/bin/postgres -D /etc/postgresql/9.5/main -c config_file=/etc/postgresql/9.5/main/postgresql.conf >> /var/log/postgresql.log 2>&1
