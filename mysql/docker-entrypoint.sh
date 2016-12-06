#!/usr/bin/env bash

# MAINTAINER Barcus <barcus@tou.nu>

if [ ! -f /etc/bareos/bareos-config.control ]
  then
  tar xfvz /bareos-dir.tgz

  # Copy profile for bareos-webui
  if [ ! -f /etc/bareos/bareos-dir.d/profile/webui-admin.conf ]
    then
    wget --no-check-certificate 'https://raw.githubusercontent.com/bareos/bareos-webui/master/install/bareos/bareos-dir.d/profile/webui-admin.conf' -P /etc/bareos/bareos-dir.d/profile/
  fi

  if [ ! -f /etc/bareos/bareos-dir.d/console/admin.conf ]
    then
    wget --no-check-certificate 'https://raw.githubusercontent.com/bareos/bareos-webui/master/install/bareos/bareos-dir.d/console/admin.conf.example' -O /etc/bareos/bareos-dir.d/console/admin.conf
  fi

  # Update bareos-director configs
  # Director / mycatalog & mail report
  sed -i "s#dbuser =.*#dbuser = root#" /etc/bareos/bareos-dir.d/catalog/MyCatalog.conf
  sed -i "s#dbpassword =.*#dbpassword = \"${DB_PASSWORD}\"#" /etc/bareos/bareos-dir.d/catalog/MyCatalog.conf
  sed -i "s#dbname = bareos#dbname = bareos\n  dbaddress = \"${DB_HOST}\"\n  dbport = \"${DB_PORT}\"#" /etc/bareos/bareos-dir.d/catalog/MyCatalog.conf
  sed -i "s#/usr/bin/bsmtp -h localhost#/usr/bin/bsmtp -h ${SMTP_HOST}#" /etc/bareos/bareos-dir.d/messages/Daemon.conf
  sed -i "s#mail = root@localhost#mail = ${ADMIN_MAIL}#" /etc/bareos/bareos-dir.d/messages/Daemon.conf
  sed -i "s#/usr/bin/bsmtp -h localhost#/usr/bin/bsmtp -h ${SMTP_HOST}#" /etc/bareos/bareos-dir.d/messages/Standard.conf
  sed -i "s#mail = root@localhost#mail = ${ADMIN_MAIL}#" /etc/bareos/bareos-dir.d/messages/Standard.conf
  # storage daemon
  sed -i "s#Address = .*#Address = \"${BAREOS_SD_HOST}\"#" /etc/bareos/bareos-dir.d/storage/File.conf
  sed -i "s#Password = .*#Password = \"${BAREOS_SD_PASSWORD}\"#" /etc/bareos/bareos-dir.d/storage/File.conf
  # client/file daemon
  sed -i "s#Address = .*#Address = \"${BAREOS_FD_HOST}\"#" /etc/bareos/bareos-dir.d/client/bareos-fd.conf
  sed -i "s#Password = .*#Password = \"${BAREOS_FD_PASSWORD}\"#" /etc/bareos/bareos-dir.d/client/bareos-fd.conf
  # console
  sed -i "s#Password = .*#Password = \"${BAREOS_WEBUI_PASSWORD}\"#" /etc/bareos/bareos-dir.d/console/admin.conf

  # Control file
  touch /etc/bareos/bareos-config.control
fi

if [ ! -f /etc/bareos/bareos-db.control ]
  then
  sleep 15
  # Init MySQL DB
  echo -e "[client]\nhost=${DB_HOST}\nuser=root\npassword=${DB_PASSWORD}" > /root/.my.cnf
  /usr/lib/bareos/scripts/create_bareos_database 
  /usr/lib/bareos/scripts/make_bareos_tables 
  #/usr/lib/bareos/scripts/grant_bareos_privileges

  # Control file
  touch /etc/bareos/bareos-db.control
fi

find /etc/bareos/bareos-dir.d ! -user bareos -exec chown bareos {} \;
exec "$@"
