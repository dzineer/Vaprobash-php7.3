sudo openssl req -subj "/ON=personal/CN=$DOMAIN/" -x509 -nodes -days 730 -newkey rsa:2048 -keyout "$SSL_DIR/xip.io.key" -out "$SSL_DIR/xip.io.crt"


sudo openssl req -subj "/O=personal/CN=$DOMAIN/" -x509 -nodes -days 730 -newkey rsa:2048 -keyout "/etc/ssl/xip.io/xip.io.key" -out "/etc/ssl/xip.io/xip.io.crt"
