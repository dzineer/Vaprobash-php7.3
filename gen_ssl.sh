# This is the current one that works as of 2020/05/16
sudo openssl req -subj "/O=personal/CN=$DOMAIN/" -x509 -nodes -days 730 -newkey rsa:2048 -keyout "$SSL_DIR/xip.io.key" -out "$SSL_DIR/xip.io.crt"
