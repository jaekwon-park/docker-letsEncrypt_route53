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

file_env 'AWS_ACCESS_KEY'
file_env 'AWS_SECRET_KEY'

# Setup Default AWS Configure
aws configure set aws_access_key_id "$AWS_ACCESS_KEY"
aws configure set aws_secret_access_key "$AWS_SECRET_KEY"
aws configure set default.region ap-northeast-2
aws configure set output text

file_env 'EMAIL'


while (true); do
  if [ $(ls /etc/letsencrypt/archive/ | wc -l) -eq 0 ]; then
    if !  certbot certonly -n --agree-tos --email "$EMAIL" --dns-route53 --server https://acme-v02.api.letsencrypt.org/directory --expand -d "$DNS_LIST"
    then
      echo "DNS Auth Failed" 
      exit
    fi
  else
    if !  certbot renew
    then
      echo "DNS Auth Failed" 
      exit
    fi
  fi
  echo "DNS Auth Success"
  echo "i will Sleep two month"
  #pause to 2 month
  sleep 5184000
done
