#! /bin/bash
mv /tmp/puma.service /etc/systemd/system/puma.service
git clone -b monolith https://github.com/express42/reddit.git
cd reddit && bundle install
systemctl enable puma
systemctl start puma
