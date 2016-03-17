#!/bin/bash

# Supervisor
/usr/bin/supervisord -n -c /etc/supervisord.conf

# SSH
mkdir -p -m 0700 /root/.ssh
echo -e "Host *\n\tStrictHostKeyChecking no\n" >> /root/.ssh/config
/etc/init.d/ssh restart

# Site
cd /root/code/experiment
swift build -Xcc -fblocks -Xlinker -ldispatch

# Run
#make
#nohup .build/debug/Example
