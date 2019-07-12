
if [ "$1" == "" ]; then
  FILES=($(ls | grep -v "\."))
else
  FILES=( "$@" )
fi

for service in "${FILES[@]}"; do

  # Stop services and remove service files
  echo [$service] Stop service and remove service files
  if [ -f "/usr/lib/systemd/system/$service.service" ]; then 
    systemctl stop $service
    systemctl disable $service
    rm -f /usr/lib/systemd/system/$service
  fi


  # Remove listing in hosts file
  echo [$service] Remove listing in hosts file
  grep -v $service /etc/hosts > /tmp/hosts.tmp
  mv -f /tmp/hosts.tmp /etc/hosts


  # Remove data
  echo [$service] Remove data
  if [ -d "$service/data" ]; then 
    rm -rf $service/data/*
  fi

  if [ "$service" == "owncloud" ]; then
    rm -rf owncloud/config/*
  fi

  if [ "$service" == "mattermost" ]; then
    rm -rf mattermost/plugins/*
  fi

  if [ "$service" == "nginx" ]; then
    rm -f nginx/config/cert.pem
    rm -f nginx/config/key.pem
  fi


  # Mark service as uninstalled
  grep -v $service /root/.iv > /tmp/.iv
  mv /tmp/.iv /root/.iv

done
