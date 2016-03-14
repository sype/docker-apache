#!/bin/bash
mkdir -p /etc/supervisord.d/

# setup supervisor configs
cat > /etc/supervisord.d/apache.ini <<EOF
[program:apache]
priority=20
directory=/var/log/httpd
command=/usr/sbin/apachectl start
user=apache
autostart=true
autorestart=false
EOF
