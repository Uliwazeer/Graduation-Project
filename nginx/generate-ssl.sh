#!/bin/bash
mkdir -p ssl
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout ssl/nginx.key \
  -out ssl/nginx.crt \
  -subj "/C=eg/ST=cairo/L=cairo/O=MyProject/CN=localhost"
echo "✅ SSL certificate generated in ssl/"
