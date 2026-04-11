<<<<<<< HEAD
#!/bin/sh
# emby-proxy-toolbox.sh
if [ -z "${BASH_VERSION:-}" ]; then
  if command -v bash >/dev/null 2>&1; then
    exec bash "$0" "$@"
  fi
  echo "This script requires bash. On Alpine, run: apk add --no-cache bash" >&2
  exit 1
fi
set -euo pipefail
# 一体化 Emby 反代工具箱（单站反代管理器 + 通用反代网关）

# -------------------- 通用配置 --------------------
BACKUP_ROOT="/root"
DISTRO_ID=""
DISTRO_NAME=""
PKG_MANAGER=""
NGINX_SITE_DIR=""
NGINX_SNIPPETS_DIR=""
NGINX_ACME_ROOT=""

# 单站管理器
SINGLE_PREFIX="emby-"
SINGLE_HTPASSWD="/etc/nginx/.htpasswd-emby"

# 通用网关
GW_PREFIX="emby-gw-"
GW_MAP_CONF=""
GW_SNIP_CONF=""
=======
﻿#!/usr/bin/env bash
# emby-proxy-toolbox.sh
# 涓€浣撳寲 Emby 鍙嶄唬宸ュ叿绠憋紙鍗曠珯鍙嶄唬绠＄悊鍣?+ 閫氱敤鍙嶄唬缃戝叧锛?set -euo pipefail

# -------------------- 閫氱敤閰嶇疆 --------------------
SITES_AVAIL="/etc/nginx/sites-available"
SITES_ENAB="/etc/nginx/sites-enabled"
BACKUP_ROOT="/root"

# 鍗曠珯绠＄悊鍣?SINGLE_PREFIX="emby-"
SINGLE_HTPASSWD="/etc/nginx/.htpasswd-emby"

# 閫氱敤缃戝叧
GW_PREFIX="emby-gw-"
GW_MAP_CONF="/etc/nginx/conf.d/emby-gw-map.conf"
GW_SNIP_CONF="/etc/nginx/snippets/emby-gw-locations.conf"
>>>>>>> 6f143a6 (Update gateway URL format and deployment links)
GW_HTPASSWD="/etc/nginx/.htpasswd-emby-gw"

TOOL_NAME="emby-proxy-toolbox"
# ------------------------------------------------

<<<<<<< HEAD
need_root() { [[ "${EUID}" -eq 0 ]] || { echo "请使用 root 运行：sudo bash $0"; exit 1; }; }
=======
need_root() { [[ "${EUID}" -eq 0 ]] || { echo "璇风敤 root 杩愯锛歴udo bash $0"; exit 1; }; }
>>>>>>> 6f143a6 (Update gateway URL format and deployment links)
has_cmd() { command -v "$1" >/dev/null 2>&1; }

prompt() {
  local __var="$1" __msg="$2" __def="${3:-}"
  local input=""
  if [[ -n "$__def" ]]; then
    read -r -p "$__msg [$__def]: " input
    input="${input:-$__def}"
  else
    read -r -p "$__msg: " input
  fi
  printf -v "$__var" "%s" "$input"
}

yesno() {
  local __var="$1" __msg="$2" __def="${3:-y}"
  local input=""
  read -r -p "$__msg (y/n) [$__def]: " input
  input="${input:-$__def}"
  input="$(echo "$input" | tr '[:upper:]' '[:lower:]')"
  [[ "$input" == "y" || "$input" == "yes" ]] && printf -v "$__var" "y" || printf -v "$__var" "n"
}

strip_scheme() { local s="$1"; s="${s#http://}"; s="${s#https://}"; echo "$s"; }
sanitize_name() { echo "$1" | tr -cd '[:alnum:]._-' | sed 's/^\.*//;s/\.*$//'; }

is_port() { local p="$1"; [[ "$p" =~ ^[0-9]+$ ]] || return 1; (( p>=1 && p<=65535 )) || return 1; }
normalize_ports_csv() { local csv="$1"; csv="$(echo "$csv" | tr -d ' ')"; csv="${csv#,}"; csv="${csv%,}"; echo "$csv"; }

os_info() {
  local name="unknown" ver="unknown" codename="unknown"
  if [[ -r /etc/os-release ]]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    name="${NAME:-unknown}"
    ver="${VERSION_ID:-unknown}"
    codename="${VERSION_CODENAME:-${DEBIAN_CODENAME:-unknown}}"
  fi
  echo "$name|$ver|$codename"
}

<<<<<<< HEAD
detect_platform() {
  local id="unknown" name="unknown"
  if [[ -r /etc/os-release ]]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    id="${ID:-unknown}"
    name="${NAME:-unknown}"
  fi

  DISTRO_ID="$id"
  DISTRO_NAME="$name"

  if has_cmd apk; then
    PKG_MANAGER="apk"
    NGINX_SITE_DIR="/etc/nginx/http.d"
    GW_MAP_CONF="${NGINX_SITE_DIR}/emby-gw-map.conf"
  elif has_cmd apt-get; then
    PKG_MANAGER="apt"
    NGINX_SITE_DIR="/etc/nginx/sites-available"
    GW_MAP_CONF="/etc/nginx/conf.d/emby-gw-map.conf"
  else
    echo "不支持当前系统的包管理器，仅支持 apt-get 和 apk。"
    exit 1
  fi

  NGINX_SNIPPETS_DIR="/etc/nginx/snippets"
  NGINX_ACME_ROOT="/var/www/html"
  GW_SNIP_CONF="${NGINX_SNIPPETS_DIR}/emby-gw-locations.conf"
}

pkg_install() {
  if [[ "$PKG_MANAGER" == "apt" ]]; then
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -y >/dev/null
    apt-get install -y "$@" >/dev/null
  elif [[ "$PKG_MANAGER" == "apk" ]]; then
    apk add --no-cache "$@" >/dev/null
  else
    echo "不支持的包管理器：$PKG_MANAGER"
    return 1
  fi
}

ensure_deps() {
  pkg_install nginx curl ca-certificates rsync openssl
}

ensure_certbot() {
  if [[ "$PKG_MANAGER" == "apt" ]]; then
    pkg_install certbot python3-certbot-nginx
  elif [[ "$PKG_MANAGER" == "apk" ]]; then
    pkg_install certbot certbot-nginx
  fi
}

write_htpasswd_file() {
  local file="$1" user="$2" pass="$3" hash=""
  hash="$(openssl passwd -apr1 "$pass")"
  printf '%s:%s\n' "$user" "$hash" >"$file"
}

ensure_htpasswd_cmd() {
  return 0
=======
apt_install() { export DEBIAN_FRONTEND=noninteractive; apt-get update -y >/dev/null; apt-get install -y "$@" >/dev/null; }
ensure_deps() { apt_install nginx curl ca-certificates rsync apache2-utils openssl; }
ensure_certbot() { apt_install certbot python3-certbot-nginx; }

ensure_htpasswd_cmd() {
  if ! has_cmd htpasswd; then
    echo "鏈娴嬪埌 htpasswd锛屾鍦ㄥ畨瑁?apache2-utils..."
    apt_install apache2-utils
  fi
>>>>>>> 6f143a6 (Update gateway URL format and deployment links)
}

backup_nginx() {
  local ts dir
  ts="$(date +%Y%m%d_%H%M%S)"
  dir="${BACKUP_ROOT}/nginx-backup-${ts}"
  mkdir -p "$dir/nginx"
  rsync -a /etc/nginx/ "$dir/nginx/"
  echo "$dir"
}
restore_nginx() { local dir="$1"; rsync -a --delete "$dir/nginx/" /etc/nginx/; }

validate_nginx() { local dumpfile="$1"; nginx -t >/dev/null; nginx -T >"$dumpfile" 2>/dev/null; }
<<<<<<< HEAD

enable_nginx_service() {
  systemctl enable nginx >/dev/null 2>&1 && return 0
  rc-update add nginx default >/dev/null 2>&1 && return 0
  return 0
}

reload_nginx() {
  enable_nginx_service
  systemctl reload nginx >/dev/null 2>&1 && return 0
  systemctl restart nginx >/dev/null 2>&1 && return 0
  rc-service nginx reload >/dev/null 2>&1 && return 0
  rc-service nginx restart >/dev/null 2>&1 && return 0
  service nginx reload >/dev/null 2>&1 && return 0
  service nginx restart >/dev/null 2>&1 && return 0
  nginx -s reload >/dev/null 2>&1 && return 0
  return 0
}

status_nginx() {
  systemctl status nginx --no-pager >/dev/null 2>&1 && { systemctl status nginx --no-pager; return 0; }
  rc-service nginx status >/dev/null 2>&1 && { rc-service nginx status; return 0; }
  service nginx status >/dev/null 2>&1 && { service nginx status; return 0; }
  echo "当前系统无法获取 nginx 服务状态。"
}
=======
reload_nginx() { systemctl enable nginx >/dev/null 2>&1 || true; systemctl reload nginx >/dev/null 2>&1 || systemctl restart nginx >/dev/null 2>&1 || true; }
>>>>>>> 6f143a6 (Update gateway URL format and deployment links)

apply_with_rollback() {
  local backup_dir="$1" dumpfile="$2"
  set +e
  validate_nginx "$dumpfile"
  local rc=$?
  set -e
  if [[ $rc -ne 0 ]]; then
<<<<<<< HEAD
    echo "❌ nginx 校验失败（nginx -t/-T），开始回滚..."
    echo "---- nginx -T 输出已保存到：$dumpfile ----"
    restore_nginx "$backup_dir"
    nginx -t >/dev/null 2>&1 || true
    reload_nginx
    echo "✅ 已回滚并恢复 Nginx。"
=======
    echo "鉂?nginx 鏍￠獙澶辫触锛坣ginx -t/-T锛夛紝寮€濮嬪洖婊?.."
    echo "---- nginx -T 杈撳嚭锛堝惈閿欒锛夊凡淇濆瓨锛?dumpfile ----"
    restore_nginx "$backup_dir"
    nginx -t >/dev/null 2>&1 || true
    reload_nginx
    echo "鉁?宸插洖婊氬苟鎭㈠ Nginx銆?
>>>>>>> 6f143a6 (Update gateway URL format and deployment links)
    return 1
  fi
  reload_nginx
}

ensure_sites_enabled_include() {
<<<<<<< HEAD
  [[ "$PKG_MANAGER" == "apk" ]] && return 0
=======
>>>>>>> 6f143a6 (Update gateway URL format and deployment links)
  local main="/etc/nginx/nginx.conf"
  [[ -f "$main" ]] || return 0
  grep -qE 'include\s+/etc/nginx/sites-enabled/\*;' "$main" && return 0

  cp -a "$main" "${main}.bak.$(date +%F_%H%M%S)"
  if grep -qE 'include\s+/etc/nginx/conf\.d/\*\.conf;' "$main"; then
    sed -i '/include\s\+\/etc\/nginx\/conf\.d\/\*\.conf;/a\    include /etc/nginx/sites-enabled/*;' "$main"
  else
    sed -i '/http\s*{/a\    include /etc/nginx/sites-enabled/*;' "$main"
  fi
}

nginx_self_heal_compat() {
  local ts main changed
  ts="$(date +%F_%H%M%S)"
  main="/etc/nginx/nginx.conf"
  changed="n"
  [[ -f "$main" ]] || return 0

<<<<<<< HEAD
  # 注释掉不兼容的 $http3
=======
  # 娉ㄩ噴 $http3
>>>>>>> 6f143a6 (Update gateway URL format and deployment links)
  local http3_files
  http3_files="$(grep -RIl '\$http3\b' /etc/nginx 2>/dev/null || true)"
  if [[ -n "$http3_files" ]]; then
    while read -r f; do
      [[ -z "$f" ]] && continue
      cp -a "$f" "${f}.bak.${ts}"
      sed -i '/\$http3\b/s/^/# /' "$f"
    done <<< "$http3_files"
    changed="y"
  fi

<<<<<<< HEAD
  # 注释掉不兼容的 quic/http3/ssl_reject_handshake
=======
  # 娉ㄩ噴 quic/http3/ssl_reject_handshake
>>>>>>> 6f143a6 (Update gateway URL format and deployment links)
  if grep -qiE '\b(quic_bpf|http3|ssl_reject_handshake)\b' "$main"; then
    cp -a "$main" "${main}.bak.${ts}"
    sed -i -E '
      s/^\s*quic_bpf\b/# quic_bpf/;
      s/^\s*http3\b/# http3/;
      s/^\s*ssl_reject_handshake\b/# ssl_reject_handshake/;
      s/^\s*(listen .*quic.*;)\s*$/# \1  # disabled by emby-proxy-toolbox/;
    ' "$main"
    changed="y"
  fi

<<<<<<< HEAD
  # 删除 nginx.conf 中监听 443 但未配置证书的 default_server
=======
  # 鍒犻櫎 nginx.conf 涓?443 ssl default_server 浣嗘棤璇佷功鐨?server{}
>>>>>>> 6f143a6 (Update gateway URL format and deployment links)
  if grep -qE 'listen\s+443\s+ssl\s+default_server' "$main"; then
    if ! awk '
      BEGIN{inside=0;has_listen=0;has_cert=0;}
      /server[[:space:]]*\{/ {inside=1;has_listen=0;has_cert=0;}
      inside && /listen[[:space:]]+443[[:space:]]+ssl[[:space:]]+default_server/ {has_listen=1;}
      inside && /ssl_certificate[[:space:]]+/ {has_cert=1;}
      inside && /\}/ {
        if (has_listen && !has_cert) exit 10;
        inside=0;
      }
      END{exit 0;}
    ' "$main"; then
      cp -a "$main" "${main}.bak.${ts}"
      awk '
        BEGIN{state=0;lvl=0;match=0;}
        {
          if (state==0 && $0 ~ /server[[:space:]]*\{/){
            buf[0]=$0; n=1; state=1; lvl=1; match=0; next
          }
          if (state==1){
            buf[n++]=$0
            if ($0 ~ /listen[[:space:]]+443[[:space:]]+ssl[[:space:]]+default_server/) match=1
            if ($0 ~ /\{/) lvl++
            if ($0 ~ /\}/){
              lvl--;
              if (lvl==0){
                if (match==1){
                  has_cert=0
                  for(i=0;i<n;i++){ if (buf[i] ~ /ssl_certificate[[:space:]]+/) has_cert=1 }
                  if (has_cert==0){ state=0; next }
                }
                for(i=0;i<n;i++) print buf[i]
                state=0; next
              }
            }
            next
          }
          if (state==0) print
        }
      ' "$main" > /tmp/nginx.conf.healed && mv /tmp/nginx.conf.healed "$main"
      changed="y"
    fi
  fi

  ensure_sites_enabled_include || true

  if [[ "$changed" == "y" ]]; then
<<<<<<< HEAD
    nginx -t >/dev/null 2>&1 && reload_nginx
=======
    nginx -t >/dev/null 2>&1 && (systemctl restart nginx >/dev/null 2>&1 || true)
>>>>>>> 6f143a6 (Update gateway URL format and deployment links)
  fi
}

certbot_enable_tls() {
  local domain="$1" email="$2"
  ensure_certbot
  ensure_sites_enabled_include
<<<<<<< HEAD
  nginx -t >/dev/null 2>&1 && reload_nginx || true
=======
  nginx -t >/dev/null 2>&1 && systemctl reload nginx >/dev/null 2>&1 || true
>>>>>>> 6f143a6 (Update gateway URL format and deployment links)
  certbot --nginx -d "$domain" --agree-tos -m "$email" --non-interactive --redirect
}

random_pass() { openssl rand -hex 10 2>/dev/null; }

<<<<<<< HEAD
# ========================= 单站反代 =========================
single_conf_path_for_domain() { local d="$1"; echo "${NGINX_SITE_DIR}/${SINGLE_PREFIX}$(sanitize_name "$d").conf"; }
single_enabled_path_for_domain() {
  local d="$1"
  if [[ "$PKG_MANAGER" == "apk" ]]; then
    echo "${NGINX_SITE_DIR}/${SINGLE_PREFIX}$(sanitize_name "$d").conf"
  else
    echo "/etc/nginx/sites-enabled/${SINGLE_PREFIX}$(sanitize_name "$d").conf"
  fi
}
=======
# ========================= 鍗曠珯鍙嶄唬 =========================
single_conf_path_for_domain() { local d="$1"; echo "${SITES_AVAIL}/${SINGLE_PREFIX}$(sanitize_name "$d").conf"; }
single_enabled_path_for_domain(){ local d="$1"; echo "${SITES_ENAB}/${SINGLE_PREFIX}$(sanitize_name "$d").conf"; }
>>>>>>> 6f143a6 (Update gateway URL format and deployment links)

warn_cf_ports_http_only() {
  local ports_csv; ports_csv="$(normalize_ports_csv "${1:-}")"
  [[ -z "$ports_csv" ]] && return 0
  local ok="80 8080 8880 2052 2082 2086 2095"
  IFS=',' read -r -a arr <<<"$ports_csv"
  for p in "${arr[@]}"; do
    [[ -z "$p" ]] && continue
    for a in $ok; do [[ "$p" == "$a" ]] && continue 2; done
<<<<<<< HEAD
    echo "提示：端口 ${p} 可能不受 Cloudflare 代理支持，必要时改用 8080/8880/2052/2082/2086/2095 或直接灰云。"
=======
    echo "鈿狅笍 鎻愮ず锛氱鍙?${p} 鍙兘涓嶈 Cloudflare 灏忛粍浜戜唬鐞嗘敮鎸併€傚紑鍚浜戝悗鑻ヤ笉鍙敤锛氭敼鐢?8080/8880/2052/2082/2086/2095 鎴栫伆浜戠洿杩炪€?
>>>>>>> 6f143a6 (Update gateway URL format and deployment links)
  done
}

single_write_site_conf() {
  local domain="$1" origin_host="$2" origin_port="$3" origin_scheme="$4"
  local enable_basicauth="$5" basic_user="$6" basic_pass="$7"
  local use_subpath="$8" subpath="$9"
  local upstream_insecure="${10}" extra_ports_csv="${11}"

  local conf enabled origin safe_ports auth_snip location_block
  conf="$(single_conf_path_for_domain "$domain")"
  enabled="$(single_enabled_path_for_domain "$domain")"
  origin="${origin_host}:${origin_port}"
  safe_ports="$(normalize_ports_csv "$extra_ports_csv")"

  auth_snip=""
  if [[ "$enable_basicauth" == "y" ]]; then
<<<<<<< HEAD
    write_htpasswd_file "$SINGLE_HTPASSWD" "$basic_user" "$basic_pass"
=======
    ensure_htpasswd_cmd
    htpasswd -bc "$SINGLE_HTPASSWD" "$basic_user" "$basic_pass" >/dev/null
>>>>>>> 6f143a6 (Update gateway URL format and deployment links)
    auth_snip=$'auth_basic "Restricted";\n        auth_basic_user_file '"$SINGLE_HTPASSWD"$';\n'
  fi

  if [[ "$use_subpath" == "y" ]]; then
    location_block=$(cat <<EOF
    location = $subpath { return 301 $subpath/; }

    location ^~ $subpath/ {
        ${auth_snip}proxy_pass $origin_scheme://$origin/;

        proxy_http_version 1.1;
        proxy_set_header Host \$proxy_host;
        proxy_set_header X-Forwarded-Host \$host;

        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;

        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection \$connection_upgrade;

        proxy_set_header Range \$http_range;
        proxy_set_header If-Range \$http_if_range;
        proxy_buffering off;
        proxy_request_buffering off;
        proxy_read_timeout 3600s;
        proxy_send_timeout 3600s;

        client_max_body_size 500m;

        rewrite ^$subpath/(.*)\$ /\$1 break;
        proxy_redirect ~^(/.*)\$ $subpath\$1;
EOF
)
    if [[ "$origin_scheme" == "https" ]]; then
      [[ "$upstream_insecure" == "y" ]] && location_block+=$'\n        proxy_ssl_verify off;\n'
      location_block+=$'        proxy_ssl_server_name on;\n'
    fi
    location_block+=$'    }\n'
  else
    location_block=$(cat <<EOF
    location / {
        ${auth_snip}proxy_pass $origin_scheme://$origin;

        proxy_http_version 1.1;
        proxy_set_header Host \$proxy_host;
        proxy_set_header X-Forwarded-Host \$host;

        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;

        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection \$connection_upgrade;

        proxy_set_header Range \$http_range;
        proxy_set_header If-Range \$http_if_range;
        proxy_buffering off;
        proxy_request_buffering off;
        proxy_read_timeout 3600s;
        proxy_send_timeout 3600s;

        client_max_body_size 500m;
EOF
)
    if [[ "$origin_scheme" == "https" ]]; then
      [[ "$upstream_insecure" == "y" ]] && location_block+=$'\n        proxy_ssl_verify off;\n'
      location_block+=$'        proxy_ssl_server_name on;\n'
    fi
    location_block+=$'    }\n'
  fi

  cat >"$conf" <<EOF
<<<<<<< HEAD
# ${TOOL_NAME} / 单站反代：${domain}
=======
# ${TOOL_NAME} / 鍗曠珯鍙嶄唬锛?{domain}
>>>>>>> 6f143a6 (Update gateway URL format and deployment links)
# Managed by ${TOOL_NAME}
# META domain=${domain} origin=${origin_scheme}://${origin} subpath=${subpath} extra_ports=${safe_ports} basicauth=${enable_basicauth}

map \$http_upgrade \$connection_upgrade {
  default upgrade;
  ''      close;
}

server {
  listen 80;
  listen [::]:80;
  server_name ${domain};

${location_block}
}
EOF

  if [[ -n "${safe_ports// /}" ]]; then
    IFS=',' read -r -a ports <<<"$safe_ports"
    for p in "${ports[@]}"; do
      [[ -z "$p" ]] && continue
<<<<<<< HEAD
      is_port "$p" || { echo "端口不合法：$p"; return 1; }
      [[ "$p" == "80" || "$p" == "443" ]] && { echo "额外端口不允许使用 80/443：$p"; return 1; }
=======
      is_port "$p" || { echo "绔彛闈炴硶锛?p"; return 1; }
      [[ "$p" == "80" || "$p" == "443" ]] && { echo "棰濆绔彛涓嶅厑璁镐娇鐢?80/443锛?p"; return 1; }
>>>>>>> 6f143a6 (Update gateway URL format and deployment links)
      cat >>"$conf" <<EOF

server {
  listen ${p};
  listen [::]:${p};
  server_name _;
${location_block}
}
EOF
    done
  fi

<<<<<<< HEAD
  if [[ "$enabled" != "$conf" ]]; then
    mkdir -p "$(dirname "$enabled")"
    ln -sf "$conf" "$enabled"
    rm -f "/etc/nginx/sites-enabled/default" >/dev/null 2>&1 || true
  fi
=======
  ln -sf "$conf" "$enabled"
  rm -f "${SITES_ENAB}/default" >/dev/null 2>&1 || true
>>>>>>> 6f143a6 (Update gateway URL format and deployment links)
}

single_print_usage_hint() {
  local domain="$1" subpath="$2" enable_ssl="$3" ports_csv="$4"
  local main="http://${domain}"
  [[ "$enable_ssl" == "y" ]] && main="https://${domain}"
  if [[ "$subpath" != "/" && -n "$subpath" ]]; then main="${main}${subpath}"; else main="${main}/"; fi

  echo
<<<<<<< HEAD
  echo "================ 使用方式 ================"
  echo "主入口："
  echo "  浏览器：${main}"
  echo "  Emby 客户端：服务器地址填 ${main%/}"
  if [[ -n "${ports_csv// /}" ]]; then
    ports_csv="$(normalize_ports_csv "$ports_csv")"
    echo
    echo "额外端口入口（HTTP 明文）："
=======
  echo "================ 浣跨敤鏂规硶 ================"
  echo "涓诲叆鍙ｏ細"
  echo "  娴忚鍣細${main}"
  echo "  Emby 瀹㈡埛绔細鏈嶅姟鍣ㄥ湴鍧€濉?${main%/}"
  if [[ -n "${ports_csv// /}" ]]; then
    ports_csv="$(normalize_ports_csv "$ports_csv")"
    echo
    echo "棰濆绔彛鍏ュ彛锛圚TTP 鏄庢枃锛夛細"
>>>>>>> 6f143a6 (Update gateway URL format and deployment links)
    IFS=',' read -r -a ports <<<"$ports_csv"
    for p in "${ports[@]}"; do
      [[ -z "$p" ]] && continue
      echo "  - http://${domain}:${p}/"
      echo "  - http://VPS_IP:${p}/"
    done
  fi
  echo
<<<<<<< HEAD
  echo "注意：IP + HTTPS 证书不会匹配，这是正常现象，建议使用域名 + HTTPS。"
=======
  echo "娉ㄦ剰锛欼P + HTTPS 浼氳瘉涔︿笉鍖归厤锛堟甯革級锛屾帹鑽愬煙鍚?+ HTTPS銆?
>>>>>>> 6f143a6 (Update gateway URL format and deployment links)
  echo "=========================================="
  echo
}

single_action_add_or_edit() {
  local DOMAIN ORIGIN_HOST ORIGIN_PORT ORIGIN_SCHEME
  local ENABLE_SSL EMAIL ENABLE_UFW
  local ENABLE_BASICAUTH BASIC_USER BASIC_PASS
  local USE_SUBPATH SUBPATH UPSTREAM_INSECURE EXTRA_PORTS

<<<<<<< HEAD
  prompt DOMAIN "访问域名（只填域名，不要带 https://）"
  DOMAIN="$(strip_scheme "$DOMAIN")"
  prompt ORIGIN_HOST "源站域名或 IP（可输入 http(s)://，会自动去掉）"
  ORIGIN_HOST="$(strip_scheme "$ORIGIN_HOST")"
  prompt ORIGIN_PORT "源站端口" "8096"
  is_port "$ORIGIN_PORT" || { echo "端口不合法：$ORIGIN_PORT"; return 1; }
  prompt ORIGIN_SCHEME "源站协议 http/https" "http"
  [[ "$ORIGIN_SCHEME" == "http" || "$ORIGIN_SCHEME" == "https" ]] || { echo "协议只能是 http 或 https"; return 1; }

  yesno ENABLE_SSL "为主入口申请 Let's Encrypt（启用 443 并 80 跳转 443）" "y"
  EMAIL="admin@${DOMAIN}"
  [[ "$ENABLE_SSL" == "y" ]] && prompt EMAIL "证书邮箱" "$EMAIL"

  yesno ENABLE_UFW "自动使用 UFW 放行 80/443 和额外端口（不影响云安全组）" "n"

  yesno ENABLE_BASICAUTH "启用 BasicAuth（额外一层访问密码，可选）" "n"
  BASIC_USER="emby"; BASIC_PASS=""
  if [[ "$ENABLE_BASICAUTH" == "y" ]]; then
    prompt BASIC_USER "BasicAuth 用户名" "emby"
    prompt BASIC_PASS "BasicAuth 密码"
  fi

  yesno USE_SUBPATH "使用子路径（例如 /emby）" "n"
  SUBPATH="/"
  if [[ "$USE_SUBPATH" == "y" ]]; then
    prompt SUBPATH "子路径（以 / 开头，且不以 / 结尾）" "/emby"
    [[ "$SUBPATH" == /* ]] || SUBPATH="/$SUBPATH"
    [[ "$SUBPATH" != */ ]] || { echo "子路径不能以 / 结尾"; return 1; }
=======
  prompt DOMAIN "璁块棶鍩熷悕锛堝彧濉煙鍚嶏紝涓嶈 https://锛?
  DOMAIN="$(strip_scheme "$DOMAIN")"
  prompt ORIGIN_HOST "婧愮珯鍩熷悕鎴朓P锛堝彲璇緭 http(s)://锛屼細鑷姩鍘绘帀锛?
  ORIGIN_HOST="$(strip_scheme "$ORIGIN_HOST")"
  prompt ORIGIN_PORT "婧愮珯绔彛" "8096"
  is_port "$ORIGIN_PORT" || { echo "绔彛涓嶅悎娉曪細$ORIGIN_PORT"; return 1; }
  prompt ORIGIN_SCHEME "婧愮珯鍗忚 http/https" "http"
  [[ "$ORIGIN_SCHEME" == "http" || "$ORIGIN_SCHEME" == "https" ]] || { echo "鍗忚鍙兘鏄?http 鎴?https"; return 1; }

  yesno ENABLE_SSL "涓轰富鍏ュ彛鐢宠 Let's Encrypt锛堝惎鐢?443 骞?80->443锛? "y"
  EMAIL="admin@${DOMAIN}"
  [[ "$ENABLE_SSL" == "y" ]] && prompt EMAIL "璇佷功閭" "$EMAIL"

  yesno ENABLE_UFW "鑷姩鐢?UFW 鏀鹃€?80/443 + 棰濆绔彛锛堜笉褰卞搷浜戝畨鍏ㄧ粍锛? "n"

  yesno ENABLE_BASICAUTH "鍚敤 BasicAuth锛堥澶栦竴灞傞棬绂侊紝鍙€夛級" "n"
  BASIC_USER="emby"; BASIC_PASS=""
  if [[ "$ENABLE_BASICAUTH" == "y" ]]; then
    prompt BASIC_USER "BasicAuth 鐢ㄦ埛鍚? "emby"
    prompt BASIC_PASS "BasicAuth 瀵嗙爜"
  fi

  yesno USE_SUBPATH "浣跨敤瀛愯矾寰勶紙渚嬪 /emby锛? "n"
  SUBPATH="/"
  if [[ "$USE_SUBPATH" == "y" ]]; then
    prompt SUBPATH "瀛愯矾寰勶紙浠?/ 寮€澶达紝涓嶄互 / 缁撳熬锛? "/emby"
    [[ "$SUBPATH" == /* ]] || SUBPATH="/$SUBPATH"
    [[ "$SUBPATH" != */ ]] || { echo "瀛愯矾寰勪笉鑳戒互 / 缁撳熬"; return 1; }
>>>>>>> 6f143a6 (Update gateway URL format and deployment links)
  fi

  UPSTREAM_INSECURE="n"
  if [[ "$ORIGIN_SCHEME" == "https" ]]; then
<<<<<<< HEAD
    yesno UPSTREAM_INSECURE "源站 HTTPS 为自签或不受信证书（跳过校验）" "n"
  fi

  prompt EXTRA_PORTS "额外端口入口（逗号分隔，可留空，例如 18443,28096）" ""
=======
    yesno UPSTREAM_INSECURE "婧愮珯 HTTPS 涓鸿嚜绛?涓嶅彈淇¤瘉涔︼紙璺宠繃楠岃瘉锛? "n"
  fi

  prompt EXTRA_PORTS "棰濆绔彛鍏ュ彛锛堥€楀彿鍒嗛殧锛屽彲绌猴紱濡?18443,28096锛? ""
>>>>>>> 6f143a6 (Update gateway URL format and deployment links)
  EXTRA_PORTS="$(normalize_ports_csv "$EXTRA_PORTS")"
  if [[ -n "${EXTRA_PORTS// /}" ]]; then
    IFS=',' read -r -a arr <<<"$EXTRA_PORTS"
    for p in "${arr[@]}"; do
      [[ -z "$p" ]] && continue
<<<<<<< HEAD
      is_port "$p" || { echo "额外端口不合法：$p"; return 1; }
      [[ "$p" == "80" || "$p" == "443" ]] && { echo "额外端口不能使用 80/443：$p"; return 1; }
=======
      is_port "$p" || { echo "棰濆绔彛涓嶅悎娉曪細$p"; return 1; }
      [[ "$p" == "80" || "$p" == "443" ]] && { echo "棰濆绔彛涓嶈兘鐢?80/443锛?p"; return 1; }
>>>>>>> 6f143a6 (Update gateway URL format and deployment links)
    done
  fi

  warn_cf_ports_http_only "$EXTRA_PORTS"

  echo
<<<<<<< HEAD
  echo "---- 配置确认 ----"
  echo "入口域名:     $DOMAIN"
  echo "回源地址:     $ORIGIN_SCHEME://$ORIGIN_HOST:$ORIGIN_PORT"
  echo "子路径:       $SUBPATH"
  echo "主入口 HTTPS: $ENABLE_SSL"
  echo "BasicAuth:    $ENABLE_BASICAUTH"
  echo "UFW:          $ENABLE_UFW"
  echo "额外端口:     ${EXTRA_PORTS:-（无）} (HTTP)"
=======
  echo "---- 閰嶇疆纭 ----"
  echo "鍏ュ彛鍩熷悕:     $DOMAIN"
  echo "鍥炴簮:         $ORIGIN_SCHEME://$ORIGIN_HOST:$ORIGIN_PORT"
  echo "瀛愯矾寰?       $SUBPATH"
  echo "涓诲叆鍙?HTTPS: $ENABLE_SSL"
  echo "BasicAuth:    $ENABLE_BASICAUTH"
  echo "UFW:          $ENABLE_UFW"
  echo "棰濆绔彛:     ${EXTRA_PORTS:-锛堟棤锛墋 (HTTP)"
>>>>>>> 6f143a6 (Update gateway URL format and deployment links)
  echo "------------------"
  echo

  ensure_deps
  ensure_sites_enabled_include
  nginx_self_heal_compat

  local backup dump
  backup="$(backup_nginx)"
  dump="$(mktemp)"
  trap 'rm -f "$dump"' RETURN

  set +e
  single_write_site_conf "$DOMAIN" "$ORIGIN_HOST" "$ORIGIN_PORT" "$ORIGIN_SCHEME" \
    "$ENABLE_BASICAUTH" "$BASIC_USER" "$BASIC_PASS" \
    "$USE_SUBPATH" "$SUBPATH" \
    "$UPSTREAM_INSECURE" "$EXTRA_PORTS"
  local rc_write=$?
  set -e
  if [[ $rc_write -ne 0 ]]; then
<<<<<<< HEAD
    echo "❌ 写入配置失败，开始回滚..."
=======
    echo "鉂?鍐欏叆閰嶇疆澶辫触锛屽洖婊?.."
>>>>>>> 6f143a6 (Update gateway URL format and deployment links)
    restore_nginx "$backup"
    reload_nginx
    return 1
  fi

  apply_with_rollback "$backup" "$dump" || return 1

  if [[ "$ENABLE_UFW" == "y" ]]; then
<<<<<<< HEAD
    if has_cmd ufw || [[ "$PKG_MANAGER" == "apt" ]]; then
      if ! has_cmd ufw; then pkg_install ufw; fi
      ufw allow 80/tcp >/dev/null || true
      ufw allow 443/tcp >/dev/null || true
      if [[ -n "${EXTRA_PORTS// /}" ]]; then
        IFS=',' read -r -a arr <<<"$EXTRA_PORTS"
        for p in "${arr[@]}"; do [[ -z "$p" ]] && continue; ufw allow "${p}/tcp" >/dev/null || true; done
      fi
    else
      echo "UFW not available on ${DISTRO_NAME}; skipping firewall changes."
=======
    if ! has_cmd ufw; then apt_install ufw; fi
    ufw allow 80/tcp >/dev/null || true
    ufw allow 443/tcp >/dev/null || true
    if [[ -n "${EXTRA_PORTS// /}" ]]; then
      IFS=',' read -r -a arr <<<"$EXTRA_PORTS"
      for p in "${arr[@]}"; do [[ -z "$p" ]] && continue; ufw allow "${p}/tcp" >/dev/null || true; done
>>>>>>> 6f143a6 (Update gateway URL format and deployment links)
    fi
  fi

  if [[ "$ENABLE_SSL" == "y" ]]; then
    set +e
    certbot_enable_tls "$DOMAIN" "$EMAIL"
    local rc_cert=$?
    set -e
    if [[ $rc_cert -ne 0 ]]; then
<<<<<<< HEAD
      echo "❌ certbot 配置失败，开始回滚..."
=======
      echo "鉂?certbot 閰嶇疆澶辫触锛屽洖婊?.."
>>>>>>> 6f143a6 (Update gateway URL format and deployment links)
      restore_nginx "$backup"
      reload_nginx
      return 1
    fi
    apply_with_rollback "$backup" "$dump" || return 1
  fi

<<<<<<< HEAD
  echo "✅ 已生效：$DOMAIN"
  echo "站点配置：$(single_conf_path_for_domain "$DOMAIN")"
  echo "备份目录：$backup"
  [[ "$USE_SUBPATH" == "y" ]] && echo "提示：建议在 Emby 后台把 Base URL 设置为 $SUBPATH，并重启 Emby。"
=======
  echo "鉁?宸茬敓鏁堬細$DOMAIN"
  echo "绔欑偣閰嶇疆锛?(single_conf_path_for_domain "$DOMAIN")"
  echo "澶囦唤鐩綍锛?backup"
  [[ "$USE_SUBPATH" == "y" ]] && echo "鈿狅笍 瀛愯矾寰勶細寤鸿鍦?Emby 鍚庡彴 Base URL 璁剧疆涓?$SUBPATH 骞堕噸鍚?Emby銆?
>>>>>>> 6f143a6 (Update gateway URL format and deployment links)
  single_print_usage_hint "$DOMAIN" "$SUBPATH" "$ENABLE_SSL" "$EXTRA_PORTS"
}

single_action_list() {
<<<<<<< HEAD
  echo "=== 现有单站反代（${NGINX_SITE_DIR}/${SINGLE_PREFIX}*.conf）==="
  shopt -s nullglob
  local files=("${NGINX_SITE_DIR}/${SINGLE_PREFIX}"*.conf)
  if [[ ${#files[@]} -eq 0 ]]; then echo "（空）"; return 0; fi
=======
  echo "=== 鐜版湁鍗曠珯鍙嶄唬锛?{SITES_AVAIL}/${SINGLE_PREFIX}*.conf锛?=="
  shopt -s nullglob
  local files=("${SITES_AVAIL}/${SINGLE_PREFIX}"*.conf)
  if [[ ${#files[@]} -eq 0 ]]; then echo "锛堢┖锛?; return 0; fi
>>>>>>> 6f143a6 (Update gateway URL format and deployment links)
  for f in "${files[@]}"; do
    local meta domain origin subpath ports basicauth
    meta="$(grep -E '^# META ' "$f" | head -n1 || true)"
    domain="$(echo "$meta" | sed -n 's/.*domain=\([^ ]*\).*/\1/p')"
    origin="$(echo "$meta" | sed -n 's/.*origin=\([^ ]*\).*/\1/p')"
    subpath="$(echo "$meta" | sed -n 's/.*subpath=\([^ ]*\).*/\1/p')"
    ports="$(echo "$meta" | sed -n 's/.*extra_ports=\([^ ]*\).*/\1/p')"
    basicauth="$(echo "$meta" | sed -n 's/.*basicauth=\([^ ]*\).*/\1/p')"
    [[ -z "$subpath" ]] && subpath="/"
<<<<<<< HEAD
    [[ -z "$ports" ]] && ports="（无）"
    [[ -z "$basicauth" ]] && basicauth="n"
    echo "- ${domain:-（未知域名）}"
    echo "    回源: ${origin:-（未知）}"
    echo "    子路径: $subpath"
    echo "    额外端口: $ports (HTTP)"
=======
    [[ -z "$ports" ]] && ports="锛堟棤锛?
    [[ -z "$basicauth" ]] && basicauth="n"
    echo "- ${domain:-锛堟湭鐭ュ煙鍚嶏級}"
    echo "    鍥炴簮: ${origin:-锛堟湭鐭ワ級}"
    echo "    瀛愯矾寰? $subpath"
    echo "    棰濆绔彛: $ports (HTTP)"
>>>>>>> 6f143a6 (Update gateway URL format and deployment links)
    echo "    BasicAuth: $basicauth"
    echo "    conf: $f"
  done
}

single_action_delete() {
  local DOMAIN DEL_CERT
<<<<<<< HEAD
  prompt DOMAIN "要删除的访问域名（server_name）"
=======
  prompt DOMAIN "瑕佸垹闄ょ殑璁块棶鍩熷悕锛坰erver_name锛?
>>>>>>> 6f143a6 (Update gateway URL format and deployment links)
  DOMAIN="$(strip_scheme "$DOMAIN")"

  local conf enabled
  conf="$(single_conf_path_for_domain "$DOMAIN")"
  enabled="$(single_enabled_path_for_domain "$DOMAIN")"

<<<<<<< HEAD
  if [[ ! -f "$conf" && ! -L "$enabled" ]]; then echo "未找到该站点：$DOMAIN"; return 1; fi
  yesno DEL_CERT "是否同时删除证书（仍需你手动执行 certbot delete）" "n"
=======
  if [[ ! -f "$conf" && ! -L "$enabled" ]]; then echo "娌℃壘鍒拌绔欑偣锛?DOMAIN"; return 1; fi
  yesno DEL_CERT "鏄惁鍚屾椂鍒犻櫎璇佷功锛堜粛闇€浣犳墜鍔ㄦ墽琛?certbot delete锛? "n"
>>>>>>> 6f143a6 (Update gateway URL format and deployment links)

  ensure_deps
  ensure_sites_enabled_include
  nginx_self_heal_compat

  local backup dump
  backup="$(backup_nginx)"
  dump="$(mktemp)"
  trap 'rm -f "$dump"' RETURN

  rm -f "$enabled" "$conf"
  apply_with_rollback "$backup" "$dump" || return 1

<<<<<<< HEAD
  echo "✅ 已删除站点：$DOMAIN"
  echo "备份目录：$backup"
  if [[ "$DEL_CERT" == "y" ]] && has_cmd certbot; then
    echo "如需删除证书，请手动执行：certbot delete --cert-name $DOMAIN"
=======
  echo "鉁?宸插垹闄ょ珯鐐癸細$DOMAIN"
  echo "澶囦唤鐩綍锛?backup"
  if [[ "$DEL_CERT" == "y" ]] && has_cmd certbot; then
    echo "璇佷功鍒犻櫎璇锋墜鍔ㄦ墽琛岋細certbot delete --cert-name $DOMAIN"
>>>>>>> 6f143a6 (Update gateway URL format and deployment links)
  fi
}

single_menu() {
  IFS="|" read -r OS_NAME OS_VER OS_CODE < <(os_info)
  echo
<<<<<<< HEAD
  echo "=== 单站反代管理器 ==="
  echo "系统：${OS_NAME} / ${OS_VER} / ${OS_CODE}"
  echo
  while true; do
    echo "========== 单站菜单 =========="
    echo "1) 添加/覆盖单站反代（可选额外端口）"
    echo "2) 查看现有单站反代"
    echo "3) 修改单站反代（覆盖同域名）"
    echo "4) 删除单站反代"
    echo "5) Nginx 测试与状态"
    echo "0) 返回上级"
    echo "=============================="
    read -r -p "请选择: " c
=======
  echo "=== 鍗曠珯鍙嶄唬绠＄悊鍣?==="
  echo "绯荤粺锛?{OS_NAME} / ${OS_VER} / ${OS_CODE}"
  echo
  while true; do
    echo "========== 鍗曠珯鑿滃崟 =========="
    echo "1) 娣诲姞/瑕嗙洊鍗曠珯鍙嶄唬锛堝彲閫夐澶栫鍙ｏ級"
    echo "2) 鏌ョ湅鐜版湁鍗曠珯鍙嶄唬"
    echo "3) 淇敼鍗曠珯鍙嶄唬锛? 瑕嗙洊鍚屽煙鍚嶏級"
    echo "4) 鍒犻櫎鍗曠珯鍙嶄唬"
    echo "5) Nginx 娴嬭瘯涓庣姸鎬?
    echo "0) 杩斿洖涓婄骇"
    echo "=============================="
    read -r -p "璇烽€夋嫨: " c
>>>>>>> 6f143a6 (Update gateway URL format and deployment links)
    case "$c" in
      1) single_action_add_or_edit ;;
      2) single_action_list ;;
      3) single_action_add_or_edit ;;
      4) single_action_delete ;;
<<<<<<< HEAD
      5) echo "nginx -t：" && nginx -t && echo && (status_nginx || true) ;;
      0) return 0 ;;
      *) echo "无效选项" ;;
=======
      5) echo "nginx -t锛? && nginx -t && echo && (systemctl status nginx --no-pager || true) ;;
      0) return 0 ;;
      *) echo "鏃犳晥閫夐」" ;;
>>>>>>> 6f143a6 (Update gateway URL format and deployment links)
    esac
  done
}

<<<<<<< HEAD
# ========================= 通用网关 =========================
gw_conf_path_for_domain() { local d="$1"; echo "${NGINX_SITE_DIR}/${GW_PREFIX}$(sanitize_name "$d").conf"; }
gw_enabled_path_for_domain() {
  local d="$1"
  if [[ "$PKG_MANAGER" == "apk" ]]; then
    echo "${NGINX_SITE_DIR}/${GW_PREFIX}$(sanitize_name "$d").conf"
  else
    echo "/etc/nginx/sites-enabled/${GW_PREFIX}$(sanitize_name "$d").conf"
  fi
}

gw_write_map_conf() {
  mkdir -p "$NGINX_SITE_DIR"
  cat > "$GW_MAP_CONF" <<'EOF'
# Managed by emby-proxy-toolbox (universal gateway)
# Loaded under http{} via nginx site include
=======
# ========================= 閫氱敤缃戝叧 =========================
gw_conf_path_for_domain() { local d="$1"; echo "${SITES_AVAIL}/${GW_PREFIX}$(sanitize_name "$d").conf"; }
gw_enabled_path_for_domain(){ local d="$1"; echo "${SITES_ENAB}/${GW_PREFIX}$(sanitize_name "$d").conf"; }

gw_write_map_conf() {
  mkdir -p /etc/nginx/conf.d
  cat > "$GW_MAP_CONF" <<'EOF'
# Managed by emby-proxy-toolbox (universal gateway)
# Loaded under http{} via /etc/nginx/conf.d/*.conf
>>>>>>> 6f143a6 (Update gateway URL format and deployment links)

map $http_upgrade $connection_upgrade {
  default upgrade;
  ""      close;
}

map $up_target $up_host_only {
  default                                $up_target;
  ~^\[(?<h>[A-Fa-f0-9:.]+)\](:\d+)?$     [$h];
  ~^(?<h>[^:]+)(:\d+)?$                  $h;
}
EOF
}
gw_write_locations_snippet() {
  local enable_basicauth="$1" enable_ip_whitelist="$2" whitelist_csv="$3"

<<<<<<< HEAD
  mkdir -p "$NGINX_SNIPPETS_DIR"
=======
  mkdir -p /etc/nginx/snippets
>>>>>>> 6f143a6 (Update gateway URL format and deployment links)

  # build auth/allow blocks into temp files (no awk; avoids multiline escaping issues)
  local tmp_auth tmp_allow
  tmp_auth="$(mktemp)"
  tmp_allow="$(mktemp)"

  # auth block
  if [[ "$enable_basicauth" == "y" ]]; then
    cat >"$tmp_auth" <<'EOF'
    auth_basic "Restricted";
    auth_basic_user_file /etc/nginx/.htpasswd-emby-gw;
EOF
  else
    : >"$tmp_auth"
  fi

  # allowlist block
  if [[ "$enable_ip_whitelist" == "y" ]]; then
    : >"$tmp_allow"
    local csv="${whitelist_csv// /}"
    IFS=',' read -r -a arr <<<"$csv"
    for cidr in "${arr[@]}"; do
      [[ -z "$cidr" ]] && continue
      printf '    allow %s;\n' "$cidr" >>"$tmp_allow"
    done
    printf '    deny all;\n' >>"$tmp_allow"
  else
    : >"$tmp_allow"
  fi

  cat > "$GW_SNIP_CONF" <<'EOF'
# Managed by emby-proxy-toolbox (universal gateway)
<<<<<<< HEAD
# Included inside server{}（这里不能出现 map 指令）
=======
# Included inside server{} (杩欓噷涓嶈兘鍑虹幇 map 鎸囦护)
>>>>>>> 6f143a6 (Update gateway URL format and deployment links)

proxy_http_version 1.1;

proxy_set_header Upgrade $http_upgrade;
proxy_set_header Connection $connection_upgrade;

proxy_set_header Range $http_range;
proxy_set_header If-Range $http_if_range;

proxy_buffering off;
proxy_request_buffering off;

proxy_read_timeout 3600s;
proxy_send_timeout 3600s;

client_max_body_size 500m;

# Nginx resolver for variable proxy_pass (do NOT use 127.0.0.1 unless you run local DNS)
resolver 1.1.1.1 8.8.8.8 valid=60s;
resolver_timeout 5s;

# Normalize (avoid "Location: web/index.html" losing target)
<<<<<<< HEAD
location ~ ^/http/(?<up_target>[A-Za-z0-9.\-_\[\]:]+)$  { return 301 /http/$up_target/; }
location ~ ^/https/(?<up_target>[A-Za-z0-9.\-_\[\]:]+)$ { return 301 /https/$up_target/; }
location ~ ^/(?<up_target>[A-Za-z0-9.\-_\[\]:]+)$       { return 301 /$up_target/; }

# /http/<target>/...
location ~ ^/http/(?<up_target>[A-Za-z0-9.\-_\[\]:]+)(?<up_rest>/.*)?$ {
    set $up_scheme http;
=======
location ~ ^/(?<up_scheme>https?)://(?<up_target>[A-Za-z0-9.\-_\[\]:]+)$ {
    return 301 /$up_scheme://$up_target/;
}

# /http://<target>/... or /https://<target>/...
location ~ ^/(?<up_scheme>https?)://(?<up_target>[A-Za-z0-9.\-_\[\]:]+)(?<up_rest>/.*)?$ {
>>>>>>> 6f143a6 (Update gateway URL format and deployment links)
    if ($up_rest = "") { set $up_rest "/"; }

#@@AUTH@@
#@@ALLOW@@

    proxy_set_header Host $up_host_only;
    proxy_set_header X-Forwarded-Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;

    proxy_ssl_server_name on;

    # Rewrite redirects back to gateway to prevent client bypass.
    # Many clients require ABSOLUTE Location; we emit https://$host/...
<<<<<<< HEAD
    # NOTE: 不要同时使用 `proxy_redirect off` 和其他 proxy_redirect 规则，否则会触发 duplicate 错误。
    proxy_redirect ~^http://([^/]+)(/.*)$  https://$host/http/$1$2;
    proxy_redirect ~^https://([^/]+)(/.*)$ https://$host/https/$1$2;
    proxy_redirect ~^/(.*)$               https://$host/http/$up_target/$1;
    proxy_redirect ~^([^/].*)$            https://$host/http/$up_target/$1;
=======
    # NOTE: 涓嶈鍚屾椂浣跨敤 `proxy_redirect off` 鍜屽叾浠?proxy_redirect 瑙勫垯锛屽惁鍒欎細瑙﹀彂鈥渄irective is duplicate鈥濄€?
    proxy_redirect ~^http://([^/]+)(/.*)$  https://$host/http://$1$2;
    proxy_redirect ~^https://([^/]+)(/.*)$ https://$host/https://$1$2;
    proxy_redirect ~^/(.*)$                https://$host/$up_scheme://$up_target/$1;
    proxy_redirect ~^([^/].*)$             https://$host/$up_scheme://$up_target/$1;
>>>>>>> 6f143a6 (Update gateway URL format and deployment links)

    proxy_pass $up_scheme://$up_target$up_rest$is_args$args;
}

<<<<<<< HEAD
# /https/<target>/...
location ~ ^/https/(?<up_target>[A-Za-z0-9.\-_\[\]:]+)(?<up_rest>/.*)?$ {
    set $up_scheme https;
    if ($up_rest = "") { set $up_rest "/"; }

#@@AUTH@@
#@@ALLOW@@

    proxy_set_header Host $up_host_only;
    proxy_set_header X-Forwarded-Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;

    proxy_ssl_server_name on;
    proxy_redirect ~^http://([^/]+)(/.*)$  https://$host/http/$1$2;
    proxy_redirect ~^https://([^/]+)(/.*)$ https://$host/https/$1$2;
    proxy_redirect ~^/(.*)$               https://$host/https/$up_target/$1;
    proxy_redirect ~^([^/].*)$            https://$host/https/$up_target/$1;

    proxy_pass $up_scheme://$up_target$up_rest$is_args$args;
}

# Default: /<target>/... (scheme defaults to https)
location ~ ^/(?<up_target>[A-Za-z0-9.\-_\[\]:]+)(?<up_rest>/.*)?$ {
    set $up_scheme https;
    if ($up_rest = "") { set $up_rest "/"; }

#@@AUTH@@
#@@ALLOW@@

    proxy_set_header Host $up_host_only;
    proxy_set_header X-Forwarded-Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;

    proxy_ssl_server_name on;
    proxy_redirect ~^http://([^/]+)(/.*)$  https://$host/http/$1$2;
    proxy_redirect ~^https://([^/]+)(/.*)$ https://$host/https/$1$2;
    proxy_redirect ~^/(.*)$               https://$host/$up_target/$1;
    proxy_redirect ~^([^/].*)$            https://$host/$up_target/$1;

    proxy_pass $up_scheme://$up_target$up_rest$is_args$args;
}
=======
>>>>>>> 6f143a6 (Update gateway URL format and deployment links)
EOF

  # Insert blocks (multiline safe)
  if [[ -s "$tmp_auth" ]]; then
    sed -i "/^#@@AUTH@@/r $tmp_auth" "$GW_SNIP_CONF"
  fi
  sed -i "/^#@@AUTH@@/d" "$GW_SNIP_CONF"

  if [[ -s "$tmp_allow" ]]; then
    sed -i "/^#@@ALLOW@@/r $tmp_allow" "$GW_SNIP_CONF"
  fi
  sed -i "/^#@@ALLOW@@/d" "$GW_SNIP_CONF"

  rm -f "$tmp_auth" "$tmp_allow"
}


gw_write_site_conf() {
  local domain="$1"
  local conf enabled
  conf="$(gw_conf_path_for_domain "$domain")"
  enabled="$(gw_enabled_path_for_domain "$domain")"

  cat >"$conf" <<EOF
<<<<<<< HEAD
# ${TOOL_NAME} / 通用反代网关：${domain}
=======
# ${TOOL_NAME} / 閫氱敤鍙嶄唬缃戝叧锛?{domain}
>>>>>>> 6f143a6 (Update gateway URL format and deployment links)
# Managed by ${TOOL_NAME}

server {
  listen 80;
  listen [::]:80;
  server_name ${domain};

  location ^~ /.well-known/acme-challenge/ {
<<<<<<< HEAD
    root ${NGINX_ACME_ROOT};
=======
    root /var/www/html;
>>>>>>> 6f143a6 (Update gateway URL format and deployment links)
    try_files \$uri =404;
  }

  location = / {
    default_type text/plain;
<<<<<<< HEAD
    return 200 "OK\\n\\n通用反代网关使用方法（填到 Emby 客户端服务器地址）：\\n\\n  https://${domain}/<上游主机:端口>\\n  https://${domain}/http/<上游主机:端口>\\n\\n说明：默认按 https 回源；如果上游是 http，请使用 /http 前缀。\\n\\n安全提示：建议开启 BasicAuth 或 IP 白名单，避免 OPEN PROXY。\\n";
  }

  include ${GW_SNIP_CONF};
}
EOF

  if [[ "$enabled" != "$conf" ]]; then
    mkdir -p "$(dirname "$enabled")"
    ln -sf "$conf" "$enabled"
    rm -f "/etc/nginx/sites-enabled/default" >/dev/null 2>&1 || true
  fi
=======
    return 200 "OK\\n\\n閫氱敤鍙嶄唬缃戝叧浣跨敤鏂瑰紡锛堝～鍐欏埌 Emby 瀹㈡埛绔€滄湇鍔″櫒鍦板潃鈥濓級锛歕\n\\n  https://${domain}/https://<涓婃父涓绘満:绔彛>\\n  https://${domain}/http://<涓婃父涓绘満:绔彛>\\n\\n璇存槑锛氳矾寰勪腑闇€瑕佸啓瀹屾暣涓婃父 URL锛圚TTP 鎴?HTTPS锛夈€俓\n\\n瀹夊叏鎻愮ず锛氬缓璁紑鍚?BasicAuth 鎴?IP 鐧藉悕鍗曪紝閬垮厤 OPEN PROXY銆俓\n";
  }

  include /etc/nginx/snippets/emby-gw-locations.conf;
}
EOF

  ln -sf "$conf" "$enabled"
  rm -f "${SITES_ENAB}/default" >/dev/null 2>&1 || true
>>>>>>> 6f143a6 (Update gateway URL format and deployment links)
}

gw_print_usage() {
  local domain="$1" ssl="$2" user="${3:-}" pass="${4:-}"
  local base="http://${domain}"; [[ "$ssl" == "y" ]] && base="https://${domain}"
  echo
<<<<<<< HEAD
  echo "================ 通用网关用法 ================"
  echo "在 Emby 客户端服务器地址中填写："
  echo "  ${base}/<上游主机:端口>        （默认按 https 回源）"
  echo "  ${base}/http/<上游主机:端口>   （强制 http 回源）"
  echo
  echo "示例："
  echo "  ${base}/example.com:443"
  echo "  ${base}/http/203.0.113.10:8096"
  echo
  if [[ -n "$user" ]]; then
    echo "已开启 BasicAuth（网关额外一层密码，不影响上游 Emby 账号密码）："
    echo "  用户名: $user"
    echo "  密码:   $pass"
    echo "注意：部分客户端或转发器不支持 BasicAuth，可能导致无法使用。"
  else
    echo "未开启 BasicAuth。"
=======
  echo "================ 閫氱敤缃戝叧鐢ㄦ硶 ================"
  echo "鍦?Emby 瀹㈡埛绔湇鍔″櫒鍦板潃涓～鍐欙細"
  echo "  ${base}/https://<涓婃父涓绘満:绔彛>   锛堝己鍒?HTTPS 鍥炴簮锛?"
  echo "  ${base}/http://<涓婃父涓绘満:绔彛>    锛堝己鍒?HTTP 鍥炴簮锛?"
  echo
  echo "绀轰緥锛堜粎绀烘剰锛岄潪鐪熷疄鍦板潃锛夛細"
  echo "  ${base}/https://example.com:443"
  echo "  ${base}/http://203.0.113.10:8096"
  echo
  if [[ -n "$user" ]]; then
    echo "宸插紑鍚?BasicAuth锛堢綉鍏抽澶栭棬绂侊紱涓嶅奖鍝嶄笂娓?Emby 鑷韩璐﹀彿瀵嗙爜锛夛細"
    echo "  鐢ㄦ埛鍚? $user"
    echo "  瀵嗙爜:   $pass"
    echo "娉ㄦ剰锛氶儴鍒嗗鎴风锛堝鏌愪簺 SenPlayer/Forward 缁勫悎锛変笉鏀寔 BasicAuth锛屼細瀵艰嚧鏃犳硶浣跨敤銆?
  else
    echo "鏈紑鍚?BasicAuth銆?
>>>>>>> 6f143a6 (Update gateway URL format and deployment links)
  fi
  echo "=============================================="
  echo
}

gw_action_install_update() {
  local DOMAIN ENABLE_SSL EMAIL ENABLE_BASICAUTH BASIC_USER BASIC_PASS ENABLE_IPWL IPWL ok
<<<<<<< HEAD
  prompt DOMAIN "你的网关入口域名（例如 autoemby.example.com，只填域名，不要带 https://）"
  DOMAIN="$(strip_scheme "$DOMAIN")"
  [[ -n "$DOMAIN" ]] || { echo "域名不能为空"; return 1; }

  yesno ENABLE_SSL "为网关域名申请 Let's Encrypt（启用 443 并 80 跳转 443）" "y"
  EMAIL="admin@${DOMAIN}"
  [[ "$ENABLE_SSL" == "y" ]] && prompt EMAIL "证书邮箱" "$EMAIL"

  yesno ENABLE_BASICAUTH "启用 BasicAuth（强烈建议，但部分客户端可能不支持）" "y"
  BASIC_USER="emby"; BASIC_PASS=""
  if [[ "$ENABLE_BASICAUTH" == "y" ]]; then
    prompt BASIC_USER "BasicAuth 用户名" "emby"
    BASIC_PASS="$(random_pass)"
    prompt BASIC_PASS "BasicAuth 密码（直接回车=自动生成）" "$BASIC_PASS"
  fi

  yesno ENABLE_IPWL "启用 IP 白名单（可选）" "n"
  IPWL=""
  if [[ "$ENABLE_IPWL" == "y" ]]; then
    prompt IPWL "白名单（逗号分隔，例如 1.2.3.4/32,5.6.7.8/32）"
    [[ -n "$IPWL" ]] || { echo "白名单不能为空"; return 1; }
  fi

  if [[ "$ENABLE_BASICAUTH" == "n" && "$ENABLE_IPWL" == "n" ]]; then
    echo "警告：你同时关闭了 BasicAuth 和 IP 白名单，这会把网关变成开放代理（高风险）。"
    yesno ok "仍要继续安装吗" "n"
    [[ "$ok" == "y" ]] || { echo "已取消"; return 0; }
  fi

  echo
  echo "---- 配置确认 ----"
  echo "入口域名:   $DOMAIN"
  echo "网关 HTTPS: $ENABLE_SSL"
  echo "BasicAuth:  $ENABLE_BASICAUTH"
  echo "IP 白名单:  $ENABLE_IPWL"
=======
  prompt DOMAIN "浣犵殑缃戝叧鍏ュ彛鍩熷悕锛堜緥濡?autoemby.example.com锛涘彧濉煙鍚嶏紝涓嶈 https://锛?
  DOMAIN="$(strip_scheme "$DOMAIN")"
  [[ -n "$DOMAIN" ]] || { echo "鍩熷悕涓嶈兘涓虹┖"; return 1; }

  yesno ENABLE_SSL "涓虹綉鍏冲煙鍚嶇敵璇?Let's Encrypt锛堝惎鐢?443 骞?80->443锛? "y"
  EMAIL="admin@${DOMAIN}"
  [[ "$ENABLE_SSL" == "y" ]] && prompt EMAIL "璇佷功閭" "$EMAIL"

  yesno ENABLE_BASICAUTH "鍚敤 BasicAuth锛堝己鐑堝缓璁紱浣嗘敞鎰忛儴鍒嗗鎴风涓嶆敮鎸侊級" "y"
  BASIC_USER="emby"; BASIC_PASS=""
  if [[ "$ENABLE_BASICAUTH" == "y" ]]; then
    prompt BASIC_USER "BasicAuth 鐢ㄦ埛鍚? "emby"
    BASIC_PASS="$(random_pass)"
    prompt BASIC_PASS "BasicAuth 瀵嗙爜锛堢洿鎺ュ洖杞?鑷姩鐢熸垚锛? "$BASIC_PASS"
  fi

  yesno ENABLE_IPWL "鍚敤 IP 鐧藉悕鍗曪紙鍙€夛級" "n"
  IPWL=""
  if [[ "$ENABLE_IPWL" == "y" ]]; then
    prompt IPWL "鐧藉悕鍗曪紙閫楀彿鍒嗛殧锛屼緥濡?1.2.3.4/32,5.6.7.8/32锛?
    [[ -n "$IPWL" ]] || { echo "鐧藉悕鍗曚笉鑳戒负绌?; return 1; }
  fi

  if [[ "$ENABLE_BASICAUTH" == "n" && "$ENABLE_IPWL" == "n" ]]; then
    echo "鈿狅笍 璀﹀憡锛氫綘鍚屾椂鍏抽棴浜?BasicAuth 鍜?IP 鐧藉悕鍗曪紝杩欎細鎶婄綉鍏冲彉鎴?OPEN PROXY锛堥珮椋庨櫓锛夈€?
    yesno ok "浠嶈缁х画瀹夎鍚? "n"
    [[ "$ok" == "y" ]] || { echo "宸插彇娑?; return 0; }
  fi

  echo
  echo "---- 閰嶇疆纭 ----"
  echo "鍏ュ彛鍩熷悕:   $DOMAIN"
  echo "缃戝叧 HTTPS: $ENABLE_SSL"
  echo "BasicAuth:  $ENABLE_BASICAUTH"
  echo "IP 鐧藉悕鍗?  $ENABLE_IPWL"
>>>>>>> 6f143a6 (Update gateway URL format and deployment links)
  echo "------------------"
  echo

  ensure_deps
  ensure_sites_enabled_include
  nginx_self_heal_compat

  if [[ "$ENABLE_BASICAUTH" == "y" ]]; then
<<<<<<< HEAD
    write_htpasswd_file "$GW_HTPASSWD" "$BASIC_USER" "$BASIC_PASS"
=======
    ensure_htpasswd_cmd
    htpasswd -bc "$GW_HTPASSWD" "$BASIC_USER" "$BASIC_PASS" >/dev/null
>>>>>>> 6f143a6 (Update gateway URL format and deployment links)
  fi

  local backup dump
  backup="$(backup_nginx)"
  dump="$(mktemp)"
  trap 'rm -f "$dump"' RETURN

  gw_write_map_conf
  gw_write_locations_snippet "$ENABLE_BASICAUTH" "$ENABLE_IPWL" "$IPWL"
  gw_write_site_conf "$DOMAIN"

  apply_with_rollback "$backup" "$dump" || return 1

  if [[ "$ENABLE_SSL" == "y" ]]; then
    set +e
    certbot_enable_tls "$DOMAIN" "$EMAIL"
    local rc=$?
    set -e
    if [[ $rc -ne 0 ]]; then
<<<<<<< HEAD
      echo "❌ certbot 配置失败，开始回滚..."
=======
      echo "鉂?certbot 閰嶇疆澶辫触锛屽洖婊?.."
>>>>>>> 6f143a6 (Update gateway URL format and deployment links)
      restore_nginx "$backup"
      reload_nginx
      return 1
    fi
    apply_with_rollback "$backup" "$dump" || return 1
  fi

<<<<<<< HEAD
  echo "✅ 网关已生效：$DOMAIN"
  echo "站点配置：$(gw_conf_path_for_domain "$DOMAIN")"
  echo "备份目录：$backup"
=======
  echo "鉁?缃戝叧宸茬敓鏁堬細$DOMAIN"
  echo "绔欑偣閰嶇疆锛?(gw_conf_path_for_domain "$DOMAIN")"
  echo "澶囦唤鐩綍锛?backup"
>>>>>>> 6f143a6 (Update gateway URL format and deployment links)
  if [[ "$ENABLE_BASICAUTH" == "y" ]]; then gw_print_usage "$DOMAIN" "$ENABLE_SSL" "$BASIC_USER" "$BASIC_PASS"; else gw_print_usage "$DOMAIN" "$ENABLE_SSL"; fi
}

gw_action_status() {
<<<<<<< HEAD
  echo "=== 通用网关状态 ==="
  ls -l "${NGINX_SITE_DIR}/${GW_PREFIX}"*.conf 2>/dev/null || echo "（未发现网关站点配置）"
  echo
  nginx -t || true
  echo
  status_nginx || true
  echo
  [[ -f "$GW_MAP_CONF" ]] && echo "Map 文件：$GW_MAP_CONF（存在）" || echo "Map 文件：$GW_MAP_CONF（缺失）"
  [[ -f "$GW_SNIP_CONF" ]] && echo "Snippet：$GW_SNIP_CONF（存在）" || echo "Snippet：$GW_SNIP_CONF（缺失）"
  [[ -f "$GW_HTPASSWD" ]] && echo "BasicAuth：$GW_HTPASSWD（存在）" || echo "BasicAuth：$GW_HTPASSWD（缺失或未启用）"
=======
  echo "=== 閫氱敤缃戝叧鐘舵€?==="
  ls -l "${SITES_AVAIL}/${GW_PREFIX}"*.conf 2>/dev/null || echo "锛堟湭鍙戠幇缃戝叧绔欑偣閰嶇疆锛?
  echo
  nginx -t || true
  echo
  systemctl status nginx --no-pager || true
  echo
  [[ -f "$GW_MAP_CONF" ]] && echo "Map 鏂囦欢锛?GW_MAP_CONF锛堝瓨鍦級" || echo "Map 鏂囦欢锛?GW_MAP_CONF锛堢己澶憋級"
  [[ -f "$GW_SNIP_CONF" ]] && echo "Snippet锛?$GW_SNIP_CONF锛堝瓨鍦級" || echo "Snippet锛?$GW_SNIP_CONF锛堢己澶憋級"
  [[ -f "$GW_HTPASSWD" ]] && echo "BasicAuth锛?GW_HTPASSWD锛堝瓨鍦級" || echo "BasicAuth锛?GW_HTPASSWD锛堢己澶?鏈惎鐢級"
>>>>>>> 6f143a6 (Update gateway URL format and deployment links)
}

gw_action_change_auth() {
  local user pass
  if [[ ! -f "$GW_HTPASSWD" ]]; then
<<<<<<< HEAD
    echo "未找到 BasicAuth 文件：$GW_HTPASSWD"
    echo "请先在“安装/更新”中启用 BasicAuth。"
    return 1
  fi
  ensure_deps
  prompt user "新的 BasicAuth 用户名" "emby"
  pass="$(random_pass)"
  prompt pass "新的 BasicAuth 密码（直接回车=自动生成）" "$pass"
  write_htpasswd_file "$GW_HTPASSWD" "$user" "$pass"
  reload_nginx
  echo "✅ 已更新 BasicAuth。"
  echo "  用户名: $user"
  echo "  密码:   $pass"
=======
    echo "鏈壘鍒?BasicAuth 鏂囦欢锛?GW_HTPASSWD"
    echo "璇峰厛鍦ㄢ€滃畨瑁?鏇存柊鈥濅腑鍚敤 BasicAuth銆?
    return 1
  fi
  ensure_deps
  ensure_htpasswd_cmd
  prompt user "鏂扮殑 BasicAuth 鐢ㄦ埛鍚? "emby"
  pass="$(random_pass)"
  prompt pass "鏂扮殑 BasicAuth 瀵嗙爜锛堢洿鎺ュ洖杞?鑷姩鐢熸垚锛? "$pass"
  htpasswd -bc "$GW_HTPASSWD" "$user" "$pass" >/dev/null
  reload_nginx
  echo "鉁?宸叉洿鏂?BasicAuth锛?
  echo "  鐢ㄦ埛鍚? $user"
  echo "  瀵嗙爜:   $pass"
>>>>>>> 6f143a6 (Update gateway URL format and deployment links)
}

gw_action_uninstall() {
  local DOMAIN ok
<<<<<<< HEAD
  prompt DOMAIN "要卸载的网关域名（只填域名）"
=======
  prompt DOMAIN "瑕佸嵏杞界殑缃戝叧鍩熷悕锛堝彧濉煙鍚嶏級"
>>>>>>> 6f143a6 (Update gateway URL format and deployment links)
  DOMAIN="$(strip_scheme "$DOMAIN")"
  local conf enabled
  conf="$(gw_conf_path_for_domain "$DOMAIN")"
  enabled="$(gw_enabled_path_for_domain "$DOMAIN")"

<<<<<<< HEAD
  echo "将删除："
=======
  echo "灏嗗垹闄わ細"
>>>>>>> 6f143a6 (Update gateway URL format and deployment links)
  echo "  $conf"
  echo "  $enabled"
  echo "  $GW_MAP_CONF"
  echo "  $GW_SNIP_CONF"
  echo "  $GW_HTPASSWD"
  echo
<<<<<<< HEAD
  yesno ok "确认卸载" "n"
  [[ "$ok" == "y" ]] || { echo "已取消"; return 0; }
=======
  yesno ok "纭鍗歌浇" "n"
  [[ "$ok" == "y" ]] || { echo "宸插彇娑?; return 0; }
>>>>>>> 6f143a6 (Update gateway URL format and deployment links)

  ensure_deps
  ensure_sites_enabled_include
  nginx_self_heal_compat

  local backup dump
  backup="$(backup_nginx)"
  dump="$(mktemp)"
  trap 'rm -f "$dump"' RETURN

  rm -f "$enabled" "$conf" "$GW_MAP_CONF" "$GW_SNIP_CONF" "$GW_HTPASSWD" 2>/dev/null || true
  apply_with_rollback "$backup" "$dump" || true

<<<<<<< HEAD
  echo "✅ 已卸载网关。备份目录：$backup"
  echo "如需删除证书，请手动执行：certbot delete --cert-name $DOMAIN"
=======
  echo "鉁?宸插嵏杞界綉鍏炽€傚浠界洰褰曪細$backup"
  echo "濡傞渶鍒犻櫎璇佷功璇锋墜鍔ㄦ墽琛岋細certbot delete --cert-name $DOMAIN"
>>>>>>> 6f143a6 (Update gateway URL format and deployment links)
}

gw_menu() {
  IFS="|" read -r OS_NAME OS_VER OS_CODE < <(os_info)
  echo
<<<<<<< HEAD
  echo "=== 通用反代网关 ==="
  echo "系统：${OS_NAME} / ${OS_VER} / ${OS_CODE}"
  echo "提示：强烈建议开启 BasicAuth 或 IP 白名单，避免 OPEN PROXY。"
  echo
  while true; do
    echo "========== 网关菜单 =========="
    echo "1) 安装/更新通用反代网关"
    echo "2) 查看状态"
    echo "3) 修改 BasicAuth 用户名/密码"
    echo "4) 卸载"
    echo "0) 返回上级"
    echo "=============================="
    read -r -p "请选择: " c
=======
  echo "=== 閫氱敤鍙嶄唬缃戝叧 ==="
  echo "绯荤粺锛?{OS_NAME} / ${OS_VER} / ${OS_CODE}"
  echo "鎻愮ず锛氬己鐑堝缓璁紑鍚?BasicAuth 鎴?IP 鐧藉悕鍗曪紝閬垮厤 OPEN PROXY銆?
  echo
  while true; do
    echo "========== 缃戝叧鑿滃崟 =========="
    echo "1) 瀹夎/鏇存柊 閫氱敤鍙嶄唬缃戝叧"
    echo "2) 鏌ョ湅鐘舵€?
    echo "3) 淇敼 BasicAuth 璐﹀彿/瀵嗙爜"
    echo "4) 鍗歌浇"
    echo "0) 杩斿洖涓婄骇"
    echo "=============================="
    read -r -p "璇烽€夋嫨: " c
>>>>>>> 6f143a6 (Update gateway URL format and deployment links)
    case "$c" in
      1) gw_action_install_update ;;
      2) gw_action_status ;;
      3) gw_action_change_auth ;;
      4) gw_action_uninstall ;;
      0) return 0 ;;
<<<<<<< HEAD
      *) echo "无效选项" ;;
=======
      *) echo "鏃犳晥閫夐」" ;;
>>>>>>> 6f143a6 (Update gateway URL format and deployment links)
    esac
  done
}

main_menu() {
  IFS="|" read -r OS_NAME OS_VER OS_CODE < <(os_info)
<<<<<<< HEAD
  echo "=== ${TOOL_NAME}（一体化 Emby 反代工具箱）==="
  echo "系统识别：${OS_NAME} / ${OS_VER} / ${OS_CODE}"
  echo
  while true; do
    echo "========== 主菜单 =========="
    echo "1) 单站反代管理器（逐个域名配置）"
    echo "2) 通用反代网关（一个入口反代多个上游）"
    echo "0) 退出"
    echo "============================"
    read -r -p "请选择: " c
=======
  echo "=== ${TOOL_NAME}锛堜竴浣撳寲 Emby 鍙嶄唬宸ュ叿绠憋級==="
  echo "绯荤粺璇嗗埆锛?{OS_NAME} / ${OS_VER} / ${OS_CODE}"
  echo
  while true; do
    echo "========== 涓昏彍鍗?=========="
    echo "1) 鍗曠珯鍙嶄唬绠＄悊鍣紙閫愪釜鍩熷悕閰嶇疆锛?
    echo "2) 閫氱敤鍙嶄唬缃戝叧锛堜竴涓叆鍙ｅ弽浠ｅ涓笂娓革級"
    echo "0) 閫€鍑?
    echo "============================"
    read -r -p "璇烽€夋嫨: " c
>>>>>>> 6f143a6 (Update gateway URL format and deployment links)
    case "$c" in
      1) single_menu ;;
      2) gw_menu ;;
      0) exit 0 ;;
<<<<<<< HEAD
      *) echo "无效选项" ;;
=======
      *) echo "鏃犳晥閫夐」" ;;
>>>>>>> 6f143a6 (Update gateway URL format and deployment links)
    esac
  done
}

need_root
<<<<<<< HEAD
detect_platform
main_menu
=======
main_menu


>>>>>>> 6f143a6 (Update gateway URL format and deployment links)
