#!/bin/bash

function file_env() {
  local var="$1"
  local fileVar="${var}_FILE"
  local def="${2:-}"
  if [ "${!var:-}" ] && [ "${!fileVar:-}" ]; then
    echo >&2 "error: both $var and $fileVar are set (but are exclusive)"
    exit 1
  fi
  local val="$def"
  if [ "${!var:-}" ]; then
    val="${!var}"
  elif [ "${!fileVar:-}" ]; then
    val="$(<"${!fileVar}")"
  fi
  export "$var"="$val"
  unset "$fileVar"
}

function copied_file() {
  ls -alhd /etc/letsencrypt/archive/default/*
}

file_env 'AWS_ACCESS_KEY'
file_env 'AWS_SECRET_KEY'

# Setup Default AWS Configure
aws configure set aws_access_key_id "$AWS_ACCESS_KEY"
aws configure set aws_secret_access_key "$AWS_SECRET_KEY"
aws configure set default.region ap-northeast-2
aws configure set output text

file_env 'EMAIL'


while (true); do
  certification_path=$(echo /etc/letsencrypt/archive/"$(ls /etc/letsencrypt/archive | grep -v default)"/*)

  if [ $(ls /etc/letsencrypt/archive/ | wc -l) -eq 0 ]; then
    if !  certbot certonly -n --agree-tos --email "$EMAIL" --dns-route53 --server https://acme-v02.api.letsencrypt.org/directory --expand -d "$DNS_LIST" 
    then
      echo "$(date "+%F %H:%M") DNS Auth Failed" 
      exit
    fi
    echo "$(date "+%F %H:%M") DNS Auth Success"
  
    if [ ! -d /etc/letsencrypt/archive/default ]; then
  	  echo "$(date "+%F %H:%M") create default directory"
  	  mkdir /etc/letsencrypt/archive/default 
    fi
  
    echo "$(date "+%F %H:%M") copy certification file to /etc/letsencrypt/archive/default directory"
    if !  cp -rfp $certification_path /etc/letsencrypt/archive/default/
    then
        echo "$(date "+%F %H:%M") Certification copy failed" 
        exit
    else
        echo "$(date "+%F %H:%M") copied file list" 
        copied_file
    fi

  else
    if !  certbot renew
    then
      echo "$(date "+%F %H:%M") DNS Auth Failed" 
      exit
    fi
  
    if [ -f /etc/letsencrypt/archive/"$(ls /etc/letsencrypt/archive | grep -v default)"/cert2.pem ]; then
      # copy to default file
      cp -rfp /etc/letsencrypt/archive/"$(ls /etc/letsencrypt/archive | grep -v default)"/cert2.pem /etc/letsencrypt/archive/default/cert1.pem
      cp -rfp /etc/letsencrypt/archive/"$(ls /etc/letsencrypt/archive | grep -v default)"/chain2.pem /etc/letsencrypt/archive/default/chain1.pem
      cp -rfp /etc/letsencrypt/archive/"$(ls /etc/letsencrypt/archive | grep -v default)"/fullchain2.pem /etc/letsencrypt/archive/default/fullchain1.pem
      cp -rfp /etc/letsencrypt/archive/"$(ls /etc/letsencrypt/archive | grep -v default)"/privkey2.pem /etc/letsencrypt/archive/default/privkey1.pem
      # move to new SSL to old SSL file name
      echo "$(date "+%F %H:%M") Remove Old cetificate files"
      mv -f /etc/letsencrypt/archive/"$(ls /etc/letsencrypt/archive | grep -v default)"/cert2.pem /etc/letsencrypt/archive/"$(ls /etc/letsencrypt/archive | grep -v default)"/cert1.pem
      mv -f /etc/letsencrypt/archive/"$(ls /etc/letsencrypt/archive | grep -v default)"/chain2.pem /etc/letsencrypt/archive/"$(ls /etc/letsencrypt/archive | grep -v default)"/chain1.pem
      mv -f /etc/letsencrypt/archive/"$(ls /etc/letsencrypt/archive | grep -v default)"/fullchain2.pem /etc/letsencrypt/archive/"$(ls /etc/letsencrypt/archive | grep -v default)"/fullchain1.pem
      mv -f /etc/letsencrypt/archive/"$(ls /etc/letsencrypt/archive | grep -v default)"/privkey2.pem /etc/letsencrypt/archive/"$(ls /etc/letsencrypt/archive | grep -v default)"/privkey1.pem
      echo "$(date "+%F %H:%M") copied file list" 
      copied_file
    fi   
    echo "$(date "+%F %H:%M") Renew certificate Files Done."
    exit
  fi

  echo "$(date "+%F %H:%M") i will Sleep two month"
  #pause to 2 month
  sleep 5184000
done
