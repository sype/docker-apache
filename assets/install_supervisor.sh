#!/bin/bash
mkdir -p /etc/supervisord.d/

# setup supervisor configs
cat > /etc/supervisord.d/apache.ini <<EOF
[program:apache]
priority=20
directory=/var/log/httpd
command=/usr/sbin/httpd -c "ErrorLog /dev/stdout" -DFOREGROUND
redirect_stderr=true
user=root
autostart=true
autorestart=false
EOF
