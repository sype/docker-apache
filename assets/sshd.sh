#!/bin/bash

yum install -y openssh-server

cat > /etc/supervisord.d/sshd.ini <<EOF
[program:openssh]
priority=10
directory=/appli/supervisor/logs
command=/usr/sbin/sshd -D
user=root
autostart=true
autorestart=true
stdout_logfile=/appli/supervisor/logs/sshd.log
stderr_logfile=/appli/supervisor/logs/sshd_err.log
EOF
