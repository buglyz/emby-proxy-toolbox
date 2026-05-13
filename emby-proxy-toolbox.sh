cat > /root/install_emby_gateway.sh <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "请使用 root 运行"
  exit 1
fi

read -rp "请输入域名（例如 auto.emby.com）: " DOMAIN
if [[ -z "${DOMAIN}" ]]; then
  echo "域名不能为空"
  exit 1
fi

read -rp "是否开启 SSL？[y/N]: " ENABLE_SSL
ENABLE_SSL="${ENABLE_SSL,,}"

BACKUP_DIR="/root/nginx-backup-$(date +%F-%H%M%S)"
ACME_WEBROOT="/var/www/certbot"

mkdir -p "$BACKUP_DIR"
mkdir -p "$ACME_WEBROOT"

apt update
apt install -y nginx certbot curl ca-certificates openssl

cp -a /etc/nginx/nginx.conf "$BACKUP_DIR/nginx.conf.bak" 2>/dev/null || true
cp -a /etc/nginx/conf.d "$BACKUP_DIR/conf.d" 2>/dev/null || true

rm -f /etc/nginx/sites-enabled/default
rm -f /etc/nginx/conf.d/default.conf

cat > /etc/nginx/conf.d/00-gateway-map.conf <<'MAP'
map $http_upgrade $connection_upgrade {
    default upgrade;
    '' close;
}

map $up_target $up_host_only {
    default $up_target;
    ~^(?<h>\[[0-9A-Fa-f:.]+\]|[^:]+):\d+$ $h;
}
MAP

if [[ "$ENABLE_SSL" == "y" || "$ENABLE_SSL" == "yes" ]]; then

cat > /etc/nginx/conf.d/${DOMAIN}.acme.conf <<EOF2
server {
    listen 80;
    listen [::]:80;
    server_name ${DOMAIN};

    location ^~ /.well-known/acme-challenge/ {
        root ${ACME_WEBROOT};
        try_files \$uri =404;
    }

    location / {
        return 200 "OK\n";
    }
}
EOF2

nginx -t
systemctl enable nginx
systemctl restart nginx

certbot certonly \
--webroot \
-w ${ACME_WEBROOT} \
-d ${DOMAIN} \
--agree-tos \
--register-unsafely-without-email \
--non-interactive

rm -f /etc/nginx/conf.d/${DOMAIN}.acme.conf

cat > /etc/nginx/conf.d/${DOMAIN}.conf <<EOF3
server {
    listen 80;
    listen [::]:80;
    server_name ${DOMAIN};

    location ^~ /.well-known/acme-challenge/ {
        root ${ACME_WEBROOT};
        try_files \$uri =404;
    }

    location / {
        return 301 https://\$host\$request_uri;
    }
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name ${DOMAIN};

    ssl_certificate /etc/letsencrypt/live/${DOMAIN}/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/${DOMAIN}/privkey.pem;

    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    aio threads;

    keepalive_timeout 65;
    keepalive_requests 10000;

    proxy_http_version 1.1;

    proxy_set_header Upgrade \$http_upgrade;
    proxy_set_header Connection \$connection_upgrade;

    proxy_set_header Range \$http_range;
    proxy_set_header If-Range \$http_if_range;

    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$scheme;
    proxy_set_header X-Forwarded-Host \$host;

    proxy_buffering off;
    proxy_request_buffering off;

    proxy_read_timeout 3600s;
    proxy_send_timeout 3600s;
    send_timeout 3600s;

    client_max_body_size 500m;

    resolver 1.1.1.1 8.8.8.8 valid=300s ipv6=off;
    resolver_timeout 5s;

    location = / {
        default_type text/plain;

        return 200 "OK\n\n通用反代网关使用方式：\n\nhttps://${DOMAIN}/<上游主机:端口>\nhttps://${DOMAIN}/http/<上游主机:端口>\n\n默认按 https 回源；若需 http 回源请使用 /http 前缀。\n";
    }

    location ~ ^/http/(?<up_target>[A-Za-z0-9.\\-_:]+)$ {
        return 301 /http/\$up_target/;
    }

    location ~ ^/https/(?<up_target>[A-Za-z0-9.\\-_:]+)$ {
        return 301 /https/\$up_target/;
    }

    location ~ ^/(?<up_target>[A-Za-z0-9.\\-_:]+)$ {
        return 301 /\$up_target/;
    }

    location ~ ^/http/(?<up_target>[A-Za-z0-9.\\-_:]+)(?<up_rest>/.*)?$ {

        set \$up_scheme http;

        if (\$up_rest = "") {
            set \$up_rest "/";
        }

        proxy_set_header Host \$up_host_only;

        proxy_ssl_server_name on;

        proxy_redirect ~^http://([^/]+)(/.*)$  https://\$host/http/\$1\$2;
        proxy_redirect ~^https://([^/]+)(/.*)$ https://\$host/https/\$1\$2;

        proxy_redirect ~^/(.*)$ https://\$host/http/\$up_target/\$1;
        proxy_redirect ~^([^/].*)$ https://\$host/http/\$up_target/\$1;

        proxy_pass \$up_scheme://\$up_target\$up_rest\$is_args\$args;
    }

    location ~ ^/https/(?<up_target>[A-Za-z0-9.\\-_:]+)(?<up_rest>/.*)?$ {

        set \$up_scheme https;

        if (\$up_rest = "") {
            set \$up_rest "/";
        }

        proxy_set_header Host \$up_host_only;

        proxy_ssl_server_name on;

        proxy_redirect ~^http://([^/]+)(/.*)$  https://\$host/http/\$1\$2;
        proxy_redirect ~^https://([^/]+)(/.*)$ https://\$host/https/\$1\$2;

        proxy_redirect ~^/(.*)$ https://\$host/https/\$up_target/\$1;
        proxy_redirect ~^([^/].*)$ https://\$host/https/\$up_target/\$1;

        proxy_pass \$up_scheme://\$up_target\$up_rest\$is_args\$args;
    }

    location ~ ^/(?<up_target>[A-Za-z0-9.\\-_:]+)(?<up_rest>/.*)?$ {

        set \$up_scheme https;

        if (\$up_rest = "") {
            set \$up_rest "/";
        }

        proxy_set_header Host \$up_host_only;

        proxy_ssl_server_name on;

        proxy_redirect ~^http://([^/]+)(/.*)$  https://\$host/http/\$1\$2;
        proxy_redirect ~^https://([^/]+)(/.*)$ https://\$host/https/\$1\$2;

        proxy_redirect ~^/(.*)$ https://\$host/\$up_target/\$1;
        proxy_redirect ~^([^/].*)$ https://\$host/\$up_target/\$1;

        proxy_pass \$up_scheme://\$up_target\$up_rest\$is_args\$args;
    }
}
EOF3

else

cat > /etc/nginx/conf.d/${DOMAIN}.conf <<EOF4
server {
    listen 80;
    listen [::]:80;

    server_name ${DOMAIN};

    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;

    aio threads;

    keepalive_timeout 65;
    keepalive_requests 10000;

    proxy_http_version 1.1;

    proxy_set_header Upgrade \$http_upgrade;
    proxy_set_header Connection \$connection_upgrade;

    proxy_set_header Range \$http_range;
    proxy_set_header If-Range \$http_if_range;

    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$scheme;
    proxy_set_header X-Forwarded-Host \$host;

    proxy_buffering off;
    proxy_request_buffering off;

    proxy_read_timeout 3600s;
    proxy_send_timeout 3600s;
    send_timeout 3600s;

    client_max_body_size 500m;

    resolver 1.1.1.1 8.8.8.8 valid=300s ipv6=off;
    resolver_timeout 5s;

    location = / {
        default_type text/plain;

        return 200 "OK\n\n通用反代网关使用方式：\n\nhttp://${DOMAIN}/<上游主机:端口>\nhttp://${DOMAIN}/http/<上游主机:端口>\n";
    }

    location ~ ^/http/(?<up_target>[A-Za-z0-9.\\-_:]+)$ {
        return 301 /http/\$up_target/;
    }

    location ~ ^/https/(?<up_target>[A-Za-z0-9.\\-_:]+)$ {
        return 301 /https/\$up_target/;
    }

    location ~ ^/(?<up_target>[A-Za-z0-9.\\-_:]+)$ {
        return 301 /\$up_target/;
    }

    location ~ ^/http/(?<up_target>[A-Za-z0-9.\\-_:]+)(?<up_rest>/.*)?$ {

        set \$up_scheme http;

        if (\$up_rest = "") {
            set \$up_rest "/";
        }

        proxy_set_header Host \$up_host_only;

        proxy_ssl_server_name on;

        proxy_pass \$up_scheme://\$up_target\$up_rest\$is_args\$args;
    }

    location ~ ^/https/(?<up_target>[A-Za-z0-9.\\-_:]+)(?<up_rest>/.*)?$ {

        set \$up_scheme https;

        if (\$up_rest = "") {
            set \$up_rest "/";
        }

        proxy_set_header Host \$up_host_only;

        proxy_ssl_server_name on;

        proxy_pass \$up_scheme://\$up_target\$up_rest\$is_args\$args;
    }

    location ~ ^/(?<up_target>[A-Za-z0-9.\\-_:]+)(?<up_rest>/.*)?$ {

        set \$up_scheme https;

        if (\$up_rest = "") {
            set \$up_rest "/";
        }

        proxy_set_header Host \$up_host_only;

        proxy_ssl_server_name on;

        proxy_pass \$up_scheme://\$up_target\$up_rest\$is_args\$args;
    }
}
EOF4

fi

grep -q "worker_processes" /etc/nginx/nginx.conf && \
sed -i 's/worker_processes.*/worker_processes auto;/g' /etc/nginx/nginx.conf

grep -q "worker_rlimit_nofile" /etc/nginx/nginx.conf || \
sed -i '/worker_processes/a worker_rlimit_nofile 65535;' /etc/nginx/nginx.conf

nginx -t
systemctl restart nginx

echo
echo "======================================"
echo "部署完成"
echo "域名: ${DOMAIN}"
echo "SSL: ${ENABLE_SSL}"
echo "======================================"

if [[ "$ENABLE_SSL" == "y" || "$ENABLE_SSL" == "yes" ]]; then
echo "使用方式:"
echo "https://${DOMAIN}/<上游IP:端口>"
echo "https://${DOMAIN}/http/<上游IP:端口>"
else
echo "使用方式:"
echo "http://${DOMAIN}/<上游IP:端口>"
echo "http://${DOMAIN}/http/<上游IP:端口>"
fi

EOF

bash /root/install_emby_gateway.sh
