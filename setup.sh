#!/bin/bash

if [ "$1" == "" ]; then
  FILES=($(ls | grep -v "\."))
else
  FILES=( "$@" )
fi


# Setup docker environment
echo Setup docker environment
docker network create -d bridge --attachable --gateway 10.0.1.254 --subnet 10.0.1.0/24 --ipv6 --subnet fd00:0000:0001:0002::/64 internal

# Add services to hosts file
echo Add services to hosts file

for service in "${FILES[@]}"; do
  if [ "$(grep $service.lan /etc/hosts)" == "" ]; then 
    echo "127.0.0.1      $service.lan" >> /etc/hosts
  fi
done


# Pre Install
echo Pre install
for service in "${FILES[@]}"; do

  if [ "$(grep $service /root/.iv)" != "" ]; then
    continue
  fi

  # MySQL pre install
  if [ "$service" == "mysql" ]; then
    echo Initilize SQL database
    echo creating SQL init dump
    SVC=($(ls | grep -v "\."))
    for name in "${SVC[@]}"; do
      if [ -f "$name/init.sql" ]; then
        cat $name/init.sql >> /tmp/sql.tmp
      fi
    done
    docker run -d --rm --net internal --name mysql -v /opt/configs/mysql/data:/var/lib/mysql -v /tmp/sql.tmp:/docker-entrypoint-initdb.d/dump.sql -e MYSQL_ROOT_PASSWORD=supersecret mysql:5.7 &> /dev/null
    echo initializing SQL database
    sleep 10
    echo cleaning up
    docker stop mysql 2>&1 > /dev/null
    rm -f /tmp/sql.tmp
  fi
  # MISP pre install
    if [ "$service" == "misp" ]; then
    echo Initialize MISP database
    docker run --rm --name misp --net internal --ip 10.0.1.8 -v /opt/configs/misp/data:/var/lib/mysql harvarditsecurity/misp:latest /init-db
    sleep 10
  fi

  # NGINX pre setup
  if [ "$service" == "nginx" ]; then
    echo NGINX generate keys
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout nginx/config/key.pem -out nginx/config/cert.pem -subj "/C=GB/ST=SomeCity/O=SomeOrganization/CN=*"
  fi
done


# Install
echo Install services
for service in "${FILES[@]}"; do

  if [ "$(grep $service /root/.iv)" != "" ]; then
    continue
  fi

  # All setup
  if [ -f "$service/$service.service" ]; then 
    cp $service/$service.service /usr/lib/systemd/system/$service.service &> /dev/null
    systemctl enable $service &> /dev/null
    systemctl start $service  &> /dev/null
  fi
done


# Post install
echo Post install

# Restart nginx to due to order of install
if [ -f "/usr/lib/systemd/system/nginx.service" ]; then
  systemctl restart nginx
fi

for service in "${FILES[@]}"; do

  if [ "$(grep $service /root/.iv)" != "" ]; then
    continue
  fi

  # Owncloud post setup
  if [ "$service" == "owncloud" ]; then
    echo Owncloud setup
    sleep 15
    curl -s -k -X POST -F "install=true" -F "adminlogin=Administrator" -F "adminpass=supersecret" -F "adminpass-clone=supersecret" -F "directory=/var/www/html/data" -F "dbtype=mysql" -F "dbuser=owncloud" -F "dbpass=owncloud" -F "dbpass-clone=owncloud" -F "dbname=owncloud" -F "dbhost=mysql" https://owncloud.lan/index.php
  fi

  # Freeipa
  

  # Mark service as installed
  echo $service >> /root/.iv

done

