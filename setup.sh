#!/bin/bash

if [ -f /root/.iv ]; then
  exit 0;
fi 

# Setup docker environment
docker network create -d bridge internal
find /opt/configs/* -name init.sql | xargs -I X docker run --rm --net internal --name mysql -v /opt/mysql/data:/var/lib/mysql -v X:/dump.sql mysql:5.7 echo /bin/bash -c "mysql --password=supersecret < /dump.sql"


# Install service files
find ./ -name *.service | xargs -I X echo X X | sed -e 's/.\/[a-z0-9]*\/\([a-z0-9]*.service\)$/\/usr\/lib\/systemd\/system\/\1/' | xargs -I X bash -c "cp X"

find ./ -name *.service | sed -e 's/.\/[a-z0-9]*\/\([a-z0-9]*.service\)$/\1/' | xargs -I X bash -c "systemctl enable X; systemctl start X"

# Prevent setup from running again
touch /root/.iv

find ./ -name *.service | sed -e 's/.\/[a-z0-9]*\/\([a-z0-9]*.service\)$/\1/' | xargs -I X bash -c "systemctl stop X; systemctl disable X"
