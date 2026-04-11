<<<<<<< HEAD

# Emby反代-Emby Proxy Toolbox（单站反代 + 通用反代网关，一体化脚本）

一个菜单式脚本，用于在 VPS 上部署 **Nginx 反向代理**，让 Emby / Jellyfin 等媒体访问 **走你的 VPS 出口**。

支持两种模式：

- **单站反代管理器**：为某个入口域名（可选子路径）配置固定源站，支持新增/查看/修改/删除，支持额外高端口入口。
- **通用反代网关（Universal Gateway）**：只需部署一次网关，客户端按格式填写  
  `https://你的网关域名/源站域名:端口`  
  即可临时反代任意源站，无需为每个源站单独写 Nginx 站点配置。

> ⚠️ **安全警告：通用网关是“可变上游反代”，不加保护会变成开放代理（Open Proxy）。**  
> 强烈建议开启 **IP 白名单**；BasicAuth 作为可选（部分客户端不支持）。

---

## 功能特性

- ✅ Debian 友好（默认使用系统 nginx；不强行覆盖 nginx.conf，避免 QUIC/http3 指令不兼容）
- ✅ 菜单交互（中文界面）
- ✅ 自动安装依赖（nginx/curl/rsync/certbot/apache2-utils 等）
- ✅ Nginx 配置校验 `nginx -t` + 自动回滚（配置错误自动恢复）
- ✅ 可选自动申请 Let’s Encrypt 证书（Certbot）
- ✅ 解决 Cloudflare/Host 依赖源站的 421 问题（动态 Host 头处理）
- ✅ 支持 WebSocket、Range、长超时（适配 Emby 播放/刮削/转码）
- ✅ 通用网关支持：
  - `https://网关域名/源站host:port`（**默认 HTTPS 回源**）
  - `https://网关域名/http/源站host:port`（**强制 HTTP 回源**）
  - `https://网关域名/https/源站host:port`（显式 HTTPS 回源；部分客户端可能不支持该路径）

---

## 一键使用

### 方式 A：curl 直接运行（推荐）


```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/buglyz/emby-proxy-toolbox/refs/heads/main/emby-proxy-toolbox.sh)"
````

### 方式 B：下载后运行

```bash
curl -fsSL -o emby-proxy-toolbox.sh \
  https://raw.githubusercontent.com/buglyz/emby-proxy-toolbox/refs/heads/main/emby-proxy-toolbox.sh
=======
﻿
# Emby鍙嶄唬-Emby Proxy Toolbox锛堝崟绔欏弽浠?+ 閫氱敤鍙嶄唬缃戝叧锛屼竴浣撳寲鑴氭湰锛?
涓€涓彍鍗曞紡鑴氭湰锛岀敤浜庡湪 VPS 涓婇儴缃?**Nginx 鍙嶅悜浠ｇ悊**锛岃 Emby / Jellyfin 绛夊獟浣撹闂?**璧颁綘鐨?VPS 鍑哄彛**銆?
鏀寔涓ょ妯″紡锛?
- **鍗曠珯鍙嶄唬绠＄悊鍣?*锛氫负鏌愪釜鍏ュ彛鍩熷悕锛堝彲閫夊瓙璺緞锛夐厤缃浐瀹氭簮绔欙紝鏀寔鏂板/鏌ョ湅/淇敼/鍒犻櫎锛屾敮鎸侀澶栭珮绔彛鍏ュ彛銆?- **閫氱敤鍙嶄唬缃戝叧锛圲niversal Gateway锛?*锛氬彧闇€閮ㄧ讲涓€娆＄綉鍏筹紝瀹㈡埛绔寜鏍煎紡濉啓  
  `https://浣犵殑缃戝叧鍩熷悕/https://婧愮珯鍩熷悕:绔彛`  
  鍗冲彲涓存椂鍙嶄唬浠绘剰婧愮珯锛屾棤闇€涓烘瘡涓簮绔欏崟鐙啓 Nginx 绔欑偣閰嶇疆銆?
> 鈿狅笍 **瀹夊叏璀﹀憡锛氶€氱敤缃戝叧鏄€滃彲鍙樹笂娓稿弽浠ｂ€濓紝涓嶅姞淇濇姢浼氬彉鎴愬紑鏀句唬鐞嗭紙Open Proxy锛夈€?*  
> 寮虹儓寤鸿寮€鍚?**IP 鐧藉悕鍗?*锛汢asicAuth 浣滀负鍙€夛紙閮ㄥ垎瀹㈡埛绔笉鏀寔锛夈€?
---

## 鍔熻兘鐗规€?
- 鉁?Debian 鍙嬪ソ锛堥粯璁や娇鐢ㄧ郴缁?nginx锛涗笉寮鸿瑕嗙洊 nginx.conf锛岄伩鍏?QUIC/http3 鎸囦护涓嶅吋瀹癸級
- 鉁?鑿滃崟浜や簰锛堜腑鏂囩晫闈級
- 鉁?鑷姩瀹夎渚濊禆锛坣ginx/curl/rsync/certbot/apache2-utils 绛夛級
- 鉁?Nginx 閰嶇疆鏍￠獙 `nginx -t` + 鑷姩鍥炴粴锛堥厤缃敊璇嚜鍔ㄦ仮澶嶏級
- 鉁?鍙€夎嚜鍔ㄧ敵璇?Let鈥檚 Encrypt 璇佷功锛圕ertbot锛?- 鉁?瑙ｅ喅 Cloudflare/Host 渚濊禆婧愮珯鐨?421 闂锛堝姩鎬?Host 澶村鐞嗭級
- 鉁?鏀寔 WebSocket銆丷ange銆侀暱瓒呮椂锛堥€傞厤 Emby 鎾斁/鍒墛/杞爜锛?- 鉁?閫氱敤缃戝叧鏀寔锛?  - `https://缃戝叧鍩熷悕/https://婧愮珯host:port`锛?*榛樿 HTTPS 鍥炴簮**锛?  - `https://缃戝叧鍩熷悕/http://婧愮珯host:port`锛?*寮哄埗 HTTP 鍥炴簮**锛?  - `https://缃戝叧鍩熷悕/https://婧愮珯host:port`锛堟樉寮?HTTPS 鍥炴簮锛涢儴鍒嗗鎴风鍙兘涓嶆敮鎸佽璺緞锛?
---

## 涓€閿娇鐢?
### 鏂瑰紡 A锛歝url 鐩存帴杩愯锛堟帹鑽愶級


```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/buglyz/emby-proxy-toolbox/main/emby-proxy-toolbox.sh)"
````

### 鏂瑰紡 B锛氫笅杞藉悗杩愯

```bash
curl -fsSL -o emby-proxy-toolbox.sh \
  https://raw.githubusercontent.com/buglyz/emby-proxy-toolbox/main/emby-proxy-toolbox.sh
>>>>>>> 6f143a6 (Update gateway URL format and deployment links)

chmod +x emby-proxy-toolbox.sh
sudo ./emby-proxy-toolbox.sh
```

---

<<<<<<< HEAD
## 使用说明

### 1）单站反代（固定源站）

适合：你有一个固定 Emby 源站，要长期使用。

脚本里选择 **单站反代管理器** → 添加/修改 → 填入：

* 入口域名（指向 VPS 的域名）
* 源站域名/IP + 端口（例如 8096/8920/443 等）
* 是否启用 TLS（Let’s Encrypt）
* 可选：IP 白名单 / BasicAuth / 子路径 / 额外高端口入口等

完成后，客户端填写：

* `https://你的入口域名/`（如果开启 TLS）
* 或 `http://你的入口域名/`（未开启 TLS）

如启用“额外端口入口”，也可用：

* `http://你的入口域名:高端口/`
* `http://VPS_IP:高端口/`（注意是明文 HTTP）

> 注意：**IP + HTTPS 会证书不匹配（正常现象）**，推荐 **域名 + HTTPS**。

---

### 2）通用反代网关（可变上游）

适合：你临时反代多个不同源站，不想每个都配置 Nginx。

部署一次网关后，在 Emby 客户端“服务器地址”里直接写：

#### ✅ 上游是 HTTPS（常见：443 / 8920 / 18099* 也可能是 HTTP）

* 默认（HTTPS 回源）：

  * `https://gw.example.com/emby.example.net:443`
  * `https://gw.example.com/emby.example.net:8920`

#### ✅ 上游是 HTTP（常见：8096 / 18099*）

* 强制 HTTP 回源（**推荐用于“端口实际是 HTTP”的情况**）：

  * `https://gw.example.com/http/203.0.113.10:8096`
  * `https://gw.example.com/http/emby.example.net:18099`

#### （可选）显式 HTTPS 回源

* `https://gw.example.com/https/emby.example.net:443`

> ⭐ **如何判断该用 `/http/` 还是默认？**
> 在 VPS 上测试：
>
> * `curl -vk https://目标:端口/` 如果出现 `wrong version number` / TLS 握手失败 → **该端口不是 HTTPS**，用 `/http/`。
> * `curl -v http://目标:端口/` 能正常 200/302 → 也说明是 **HTTP**，用 `/http/`。

> ✅ 兼容建议
>
> * 某些客户端/转发器不支持 `.../https/...` 路径：直接用默认 `https://网关域名/源站:端口`（默认就是 HTTPS 回源）。
> * 某些客户端不支持 BasicAuth：建议关闭 BasicAuth，改用 **IP 白名单**（更稳、更安全）。

---

## BasicAuth 是什么？会不会影响 Emby 登录？

* **BasicAuth** 是 **Nginx 在最外层加的一道“网关密码”**。访问网关时会先要求输入用户名/密码。
* **Emby 自己的账号密码** 是第二层（源站应用层登录），两者不冲突。
* 但：部分播放器/转发器 **不支持 BasicAuth**（不会弹窗、不支持 `user:pass@` 形式），这时建议使用 **IP 白名单** 替代。

---

## Cloudflare 小黄云能不能反代？

取决于你用的入口方式：

* 入口是 **80/443**：一般没问题（常规 Web 代理端口）。
* 入口是 **高端口**：Cloudflare 仅代理其“允许的端口列表”。不在列表内的端口即使开橙云也可能访问失败。
* 建议：

  * 高端口入口想走 IP:port → DNS 记录用 **灰云（DNS only）**
  * 或改用 Cloudflare 支持的端口
  * 或只用 **域名 443 入口**（最稳）

> 端口列表以 Cloudflare 官方文档为准（可能随时间变化）。

---

## 如何确认“播放走 VPS 流量”？

最简单的三种方法：

1. 播放时看连接（你会看到 VPS 同时连着客户端与源站）：
=======
## 浣跨敤璇存槑

### 1锛夊崟绔欏弽浠ｏ紙鍥哄畾婧愮珯锛?
閫傚悎锛氫綘鏈変竴涓浐瀹?Emby 婧愮珯锛岃闀挎湡浣跨敤銆?
鑴氭湰閲岄€夋嫨 **鍗曠珯鍙嶄唬绠＄悊鍣?* 鈫?娣诲姞/淇敼 鈫?濉叆锛?
* 鍏ュ彛鍩熷悕锛堟寚鍚?VPS 鐨勫煙鍚嶏級
* 婧愮珯鍩熷悕/IP + 绔彛锛堜緥濡?8096/8920/443 绛夛級
* 鏄惁鍚敤 TLS锛圠et鈥檚 Encrypt锛?* 鍙€夛細IP 鐧藉悕鍗?/ BasicAuth / 瀛愯矾寰?/ 棰濆楂樼鍙ｅ叆鍙ｇ瓑

瀹屾垚鍚庯紝瀹㈡埛绔～鍐欙細

* `https://浣犵殑鍏ュ彛鍩熷悕/`锛堝鏋滃紑鍚?TLS锛?* 鎴?`http://浣犵殑鍏ュ彛鍩熷悕/`锛堟湭寮€鍚?TLS锛?
濡傚惎鐢ㄢ€滈澶栫鍙ｅ叆鍙ｂ€濓紝涔熷彲鐢細

* `http://浣犵殑鍏ュ彛鍩熷悕:楂樼鍙?`
* `http://VPS_IP:楂樼鍙?`锛堟敞鎰忔槸鏄庢枃 HTTP锛?
> 娉ㄦ剰锛?*IP + HTTPS 浼氳瘉涔︿笉鍖归厤锛堟甯哥幇璞★級**锛屾帹鑽?**鍩熷悕 + HTTPS**銆?
---

### 2锛夐€氱敤鍙嶄唬缃戝叧锛堝彲鍙樹笂娓革級

閫傚悎锛氫綘涓存椂鍙嶄唬澶氫釜涓嶅悓婧愮珯锛屼笉鎯虫瘡涓兘閰嶇疆 Nginx銆?
閮ㄧ讲涓€娆＄綉鍏冲悗锛屽湪 Emby 瀹㈡埛绔€滄湇鍔″櫒鍦板潃鈥濋噷鐩存帴鍐欙細

#### 鉁?涓婃父鏄?HTTPS锛堝父瑙侊細443 / 8920 / 18099* 涔熷彲鑳芥槸 HTTP锛?
* 榛樿锛圚TTPS 鍥炴簮锛夛細

  * `https://gw.example.com/https://emby.example.net:443`
  * `https://gw.example.com/https://emby.example.net:8920`

#### 鉁?涓婃父鏄?HTTP锛堝父瑙侊細8096 / 18099*锛?
* 寮哄埗 HTTP 鍥炴簮锛?*鎺ㄨ崘鐢ㄤ簬鈥滅鍙ｅ疄闄呮槸 HTTP鈥濈殑鎯呭喌**锛夛細

  * `https://gw.example.com/http://203.0.113.10:8096`
  * `https://gw.example.com/http://emby.example.net:18099`

#### 锛堝彲閫夛級鏄惧紡 HTTPS 鍥炴簮

* `https://gw.example.com/https://emby.example.net:443`

> 猸?**濡備綍鍒ゆ柇璇ョ敤 `http://` 杩樻槸 `https://` 锛?*
> 鍦?VPS 涓婃祴璇曪細
>
> * `curl -vk https://鐩爣:绔彛/` 濡傛灉鍑虹幇 `wrong version number` / TLS 鎻℃墜澶辫触 鈫?**璇ョ鍙ｄ笉鏄?HTTPS**锛岀敤 `http://` 鍓嶇紑銆?> * `curl -v http://鐩爣:绔彛/` 鑳芥甯?200/302 鈫?涔熻鏄庢槸 **HTTP**锛岀敤 `http://` 鍓嶇紑銆?
> 鉁?鍏煎寤鸿
>
> * 鏌愪簺瀹㈡埛绔?杞彂鍣ㄤ笉鏀寔 `.../https://...` 璺緞锛氱洿鎺ョ敤榛樿 `https://缃戝叧鍩熷悕/https://婧愮珯:绔彛`銆?> * 鏌愪簺瀹㈡埛绔笉鏀寔 BasicAuth锛氬缓璁叧闂?BasicAuth锛屾敼鐢?**IP 鐧藉悕鍗?*锛堟洿绋炽€佹洿瀹夊叏锛夈€?
---

## BasicAuth 鏄粈涔堬紵浼氫笉浼氬奖鍝?Emby 鐧诲綍锛?
* **BasicAuth** 鏄?**Nginx 鍦ㄦ渶澶栧眰鍔犵殑涓€閬撯€滅綉鍏冲瘑鐮佲€?*銆傝闂綉鍏虫椂浼氬厛瑕佹眰杈撳叆鐢ㄦ埛鍚?瀵嗙爜銆?* **Emby 鑷繁鐨勮处鍙峰瘑鐮?* 鏄浜屽眰锛堟簮绔欏簲鐢ㄥ眰鐧诲綍锛夛紝涓よ€呬笉鍐茬獊銆?* 浣嗭細閮ㄥ垎鎾斁鍣?杞彂鍣?**涓嶆敮鎸?BasicAuth**锛堜笉浼氬脊绐椼€佷笉鏀寔 `user:pass@` 褰㈠紡锛夛紝杩欐椂寤鸿浣跨敤 **IP 鐧藉悕鍗?* 鏇夸唬銆?
---

## Cloudflare 灏忛粍浜戣兘涓嶈兘鍙嶄唬锛?
鍙栧喅浜庝綘鐢ㄧ殑鍏ュ彛鏂瑰紡锛?
* 鍏ュ彛鏄?**80/443**锛氫竴鑸病闂锛堝父瑙?Web 浠ｇ悊绔彛锛夈€?* 鍏ュ彛鏄?**楂樼鍙?*锛欳loudflare 浠呬唬鐞嗗叾鈥滃厑璁哥殑绔彛鍒楄〃鈥濄€備笉鍦ㄥ垪琛ㄥ唴鐨勭鍙ｅ嵆浣垮紑姗欎簯涔熷彲鑳借闂け璐ャ€?* 寤鸿锛?
  * 楂樼鍙ｅ叆鍙ｆ兂璧?IP:port 鈫?DNS 璁板綍鐢?**鐏颁簯锛圖NS only锛?*
  * 鎴栨敼鐢?Cloudflare 鏀寔鐨勭鍙?  * 鎴栧彧鐢?**鍩熷悕 443 鍏ュ彛**锛堟渶绋筹級

> 绔彛鍒楄〃浠?Cloudflare 瀹樻柟鏂囨。涓哄噯锛堝彲鑳介殢鏃堕棿鍙樺寲锛夈€?
---

## 濡備綍纭鈥滄挱鏀捐蛋 VPS 娴侀噺鈥濓紵

鏈€绠€鍗曠殑涓夌鏂规硶锛?
1. 鎾斁鏃剁湅杩炴帴锛堜綘浼氱湅鍒?VPS 鍚屾椂杩炵潃瀹㈡埛绔笌婧愮珯锛夛細
>>>>>>> 6f143a6 (Update gateway URL format and deployment links)

```bash
ss -ntp | grep nginx | head
```

<<<<<<< HEAD
2. 看实时网卡流量（播放时明显上涨）：

=======
2. 鐪嬪疄鏃剁綉鍗℃祦閲忥紙鎾斁鏃舵槑鏄句笂娑級锛?
>>>>>>> 6f143a6 (Update gateway URL format and deployment links)
```bash
apt-get update && apt-get install -y iftop
iftop
```

<<<<<<< HEAD
3. 看统计流量：
=======
3. 鐪嬬粺璁℃祦閲忥細
>>>>>>> 6f143a6 (Update gateway URL format and deployment links)

```bash
apt-get update && apt-get install -y vnstat
vnstat -l
```

---

<<<<<<< HEAD
## 卸载/回滚

脚本菜单内提供卸载选项（删除站点配置 / 删除网关配置）。
证书不会强制删除（避免误删），如需删除可手动执行：

```bash
sudo certbot delete --cert-name <你的域名>
=======
## 鍗歌浇/鍥炴粴

鑴氭湰鑿滃崟鍐呮彁渚涘嵏杞介€夐」锛堝垹闄ょ珯鐐归厤缃?/ 鍒犻櫎缃戝叧閰嶇疆锛夈€?璇佷功涓嶄細寮哄埗鍒犻櫎锛堥伩鍏嶈鍒狅級锛屽闇€鍒犻櫎鍙墜鍔ㄦ墽琛岋細

```bash
sudo certbot delete --cert-name <浣犵殑鍩熷悕>
>>>>>>> 6f143a6 (Update gateway URL format and deployment links)
```

---

<<<<<<< HEAD
## 免责声明

本项目仅用于合法用途与自用反代场景。
请勿用于任何违法用途或提供公共开放代理服务，否则可能导致封禁或法律风险。
=======
## 鍏嶈矗澹版槑

鏈」鐩粎鐢ㄤ簬鍚堟硶鐢ㄩ€斾笌鑷敤鍙嶄唬鍦烘櫙銆?璇峰嬁鐢ㄤ簬浠讳綍杩濇硶鐢ㄩ€旀垨鎻愪緵鍏叡寮€鏀句唬鐞嗘湇鍔★紝鍚﹀垯鍙兘瀵艰嚧灏佺鎴栨硶寰嬮闄┿€?

>>>>>>> 6f143a6 (Update gateway URL format and deployment links)


