#!/bin/bash

sleep 30

apt-get update -y
apt-get install -y nginx

cat > /var/www/html/index.html <<EOF
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate">
<meta http-equiv="Pragma" content="no-cache">
<meta http-equiv="Expires" content="0">
<title>Producción</title>
</head>
<body>
<h1>Bienvenido al Servicio Principal - Version Produccion</h1>
</body>
</html>
EOF

systemctl enable nginx
systemctl restart nginx