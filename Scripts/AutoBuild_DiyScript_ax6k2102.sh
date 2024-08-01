#!/bin/bash
# AutoBuild Module by Hyy2001 <https://github.com/Hyy2001X/AutoBuild-Actions-BETA>
# AutoBuild DiyScript

Firmware_Diy_Core() {

	Author=AUTO
	# 作者名称, AUTO: [自动识别]
	Author_URL=AUTO
	# 自定义作者网站或域名, AUTO: [自动识别]
	Default_Flag=AUTO
	# 固件标签 (名称后缀), 适用不同配置文件, AUTO: [自动识别]
	Default_IP="192.168.8.1"
	# 固件 IP 地址
	Default_Title="Powered by AutoBuild-Actions"
	# 固件终端首页显示的额外信息
	
	Short_Fw_Date=true
	# 简短的固件日期, true: [20210601]; false: [202106012359]
	x86_Full_Images=false
	# 额外上传已检测到的 x86 虚拟磁盘镜像, true: [上传]; false: [不上传]
	Fw_MFormat=AUTO
	# 自定义固件格式, AUTO: [自动识别]
	Regex_Skip="packages|buildinfo|sha256sums|manifest|kernel|rootfs|factory|itb|profile|ext4|json"
	# 输出固件时丢弃包含该内容的固件/文件
	AutoBuild_Features=true
	# 添加 AutoBuild 固件特性, true: [开启]; false: [关闭]
	
	AutoBuild_Features_Patch=false
	AutoBuild_Features_Kconfig=false
}

Firmware_Diy() {

	# 请在该函数内定制固件

	# 可用预设变量, 其他可用变量请参考运行日志
	# ${OP_AUTHOR}			OpenWrt 源码作者
	# ${OP_REPO}				OpenWrt 仓库名称
	# ${OP_BRANCH}			OpenWrt 源码分支
	# ${TARGET_PROFILE}		设备名称
	# ${TARGET_BOARD}			设备架构
	# ${TARGET_FLAG}			固件名称后缀

	# ${WORK}				OpenWrt 源码位置
	# ${CONFIG_FILE}			使用的配置文件名称
	# ${FEEDS_CONF}			OpenWrt 源码目录下的 feeds.conf.default 文件
	# ${CustomFiles}			仓库中的 /CustomFiles 绝对路径
	# ${Scripts}				仓库中的 /Scripts 绝对路径
	# ${FEEDS_LUCI}			OpenWrt 源码目录下的 package/feeds/luci 目录
	# ${FEEDS_PKG}			OpenWrt 源码目录下的 package/feeds/packages 目录
	# ${BASE_FILES}			OpenWrt 源码目录下的 package/base-files/files 目录


cat > package/base-files/files/etc/banner << EOF
  _______                     ________        __
 |       |.-----.-----.-----.|  |  |  |.----.|  |_
 |   -   ||  _  |  -__|     ||  |  |  ||   _||   _|
 |_______||   __|_____|__|__||________||__|  |____|
          |__| W I R E L E S S   B U D A I
 -----------------------------------------------------
 %D %V, %C
 -----------------------------------------------------
EOF

del_data="
package/feeds/luci/luci-app-passwall
package/feeds/luci/luci-app-ssr-plus
package/feeds/luci/luci-app-vssr
feeds/packages/net/v2ray-geodata
feeds/packages/net/v2ray-core
feeds/packages/net/v2ray-plugin
feeds/packages/net/xray-plugin
feeds/packages/net/xray-core
feeds/packages/lang/golang
feeds/packages/net/adguardhome
"

for cmd in $del_data;
do
 rm -rf $cmd
 echo "Deleted $cmd"
done

# ## update golang 20.x to 21.x
git clone https://github.com/sbwml/packages_lang_golang -b 22.x feeds/packages/lang/golang
# use
# cp ${GITHUB_WORKSPACE}/_modFiles/golang-values.mk feeds/packages/lang/golang/golang-values.mk
# 21.x to use 21.4
# sed -i 's/GO_VERSION_PATCH:=12/GO_VERSION_PATCH:=4/g;s/PKG_HASH:=30e68af27bc1f1df231e3ab74f3d17d3b8d52a089c79bcaab573b4f1b807ed4f/PKG_HASH:=47b26a83d2b65a3c1c1bcace273b69bee49a7a7b5168a7604ded3d26a37bd787/g' feeds/packages/lang/golang/golang/Makefile

# ## -------------- adguardhome ---------------------------
# rm -rf feeds/packages/net/adguardhome
rm -rf feeds/luci/applications/luci-app-adguardhome
git clone https://github.com/xiaoxiao29/luci-app-adguardhome package/diy/adguardhome
# sleep 1
# aghver=0.107.51
# aghsha256=($(curl -sL https://github.com/AdguardTeam/AdGuardHome/releases/download/v$aghver/AdGuardHome_linux_arm64.tar.gz | shasum -a 256))
# echo $aghsha256
# sed -i '10 s/.*/PKG_VERSION:='"$aghver"'/g;17 s/.*/PKG_MIRROR_HASH:='"$aghsha256"'/g' package/diy/adguardhome/AdguardHome/Makefile

# # mkdir -p package/diy/adguardhome/etc/config/adGuardConfig
# # curl -sL -m 30 --retry 2 https://github.com/AdguardTeam/AdGuardHome/releases/latest/download/AdGuardHome_linux_arm64.tar.gz -o /tmp/AdGuardHome_linux_arm64.tar.gz && tar -xzf /tmp/AdGuardHome_linux_arm64.tar.gz -C /tmp && mv /tmp/AdGuardHome/AdGuardHome package/diy/adguardhome/etc/config/adGuardConfig/AdGuardHome

# ## ---------------------------------------------------------

# ## -------------- alist ---------------------------
# replace alist
# rm -rf feeds/packages/net/alist
# rm -rf feeds/luci/applications/luci-app-alist
# # alist 3.36 requires go 1.22
# git clone https://github.com/sbwml/luci-app-alist.git package/diy/alist

# ## customize alist ver
# # sleep 1
# alver=3.35.0
# alwebver=3.35.0
# alsha256=($(curl -sL https://codeload.github.com/alist-org/alist/tar.gz/v$alver | shasum -a 256))
# alwebsha256=($(curl -sL https://github.com/alist-org/alist-web/releases/download/$alwebver/dist.tar.gz | shasum -a 256))
# echo alist $alver sha256=$alsha256
# echo alist-web $alver sha256=$alwebsha256
# sed -i 's/PKG_VERSION:=.*/PKG_VERSION:='"$alver"'/g;s/PKG_HASH:=.*/PKG_HASH:='"$alsha256"'/g;26 s/  HASH:=.*/  HASH:='"$alwebsha256"'/g' package/diy/alist/Makefile

# change default port: version 3.33.0 and up
# sed -i 's/5244/5246/g' package/diy/alist/files/alist.config
# sed -i 's/5244/5246/g' package/diy/alist/files/alist.init
# change default port: version 3.32.0 and below
# sed -i 's/5244/5246/g' package/diy/alist/luci-app-alist/root/etc/config/alist
# sed -i 's/5244/5246/g' package/diy/alist/luci-app-alist/root/etc/init.d/alist
# ## ---------------------------------------------------------

# ## -------------- ikoolproxy ---------------------------
# git clone -b main https://github.com/ilxp/luci-app-ikoolproxy.git package/diy/luci-app-ikoolproxy
## add video rule
# sleep 1
# sed -i 's/-traditional -aes256/-aes256/g' package/diy/luci-app-ikoolproxy/root/usr/share/koolproxy/data/gen_ca.sh
# curl -sL -m 30 --retry 2 https://gitlab.com/budaig/budaig.gitlab.io/-/raw/source/source/foto/kpupdate -o package/diy/luci-app-ikoolproxy/root/usr/share/koolproxy/kpupdate
# urlkp="https://cdn.jsdelivr.net/gh/ilxp/koolproxy@main/rules/koolproxy.txt"
# curl -sL -m 30 --retry 2 "$urlkp" -o package/diy/luci-app-ikoolproxy/root/usr/share/koolproxy/data/rules/koolproxy.txt >/dev/null 2>&1
# urldl="https://cdn.jsdelivr.net/gh/ilxp/koolproxy@main/rules/daily.txt"
# curl -sL -m 30 --retry 2 "$urldl" -o package/diy/luci-app-ikoolproxy/root/usr/share/koolproxy/data/rules/daily.txt >/dev/null 2>&1
# curl -sL -m 30 --retry 2 "$urlkpdat" -o /tmp/kp.dat
# mv /tmp/kp.dat package/diy/luci-app-ikoolproxy/root/usr/share/koolproxy/data/rules/kp.dat >/dev/null 2>&1
# ## ---------------------------------------------------------

# ## -------------- lucky ---------------------------
# rm -rf feeds/packages/net/lucky
rm -rf feeds/luci/applications/luci-app-lucky

# #/etc/config/lucky.daji/lucky.conf
git clone https://github.com/gdy666/luci-app-lucky.git package/diy/lucky
sleep 1
# ## customize lucky ver
# # wget https://www.daji.it:6/files/$(PKG_VERSION)/$(PKG_NAME)_$(PKG_VERSION)_Linux_$(LUCKY_ARCH).tar.gz
# lkver=2.6.2
# sed -i 's/PKG_VERSION:=.*/PKG_VERSION:='"$lkver"'/g;s/github.com\/gdy666\/lucky\/releases\/download\/v/www.daji.it\:6\/files\//g' package/diy/lucky/lucky/Makefile

# wget https://github.com/gdy666/lucky-files$(PKG_VERSION)/$(PKG_NAME)_$(PKG_VERSION)_Linux_$(LUCKY_ARCH).tar.gz
lkver=2.10.8
sed -i 's/PKG_VERSION:=.*/PKG_VERSION:='"$lkver"'/g;s/lucky\/releases\/download\/v/lucky-files\/raw\/main\//g' package/diy/lucky/lucky/Makefile

   #/etc/lucky/lucky.conf
# git clone https://github.com/sirpdboy/luci-app-lucky.git package/diy/lucky
# sleep 1
# ## customize lucky ver
# # wget https://www.daji.it:6/files/$(PKG_VERSION)/$(PKG_NAME)_$(PKG_VERSION)_Linux_$(LUCKY_ARCH).tar.gz
# lkver=2.6.2
# sed -i 's/PKG_VERSION:=.*/PKG_VERSION:='"$lkver"'/g;s/github.com\/gdy666\/lucky\/releases\/download\/v/www.daji.it\:6\/files\//g' package/diy/lucky/lucky/Makefile
# sed -i '/PKG_SOURCE_VERSION:=/d' package/diy/lucky/lucky/Makefile

# cat package/diy/lucky/lucky/Makefile
# ## ---------------------------------------------------------

# ## add chatgpt-web
# rm -rf feeds/packages/net/luci-app-chatgpt-web
# rm -rf feeds/luci/applications/luci-app-chatgpt-web
git clone https://github.com/sirpdboy/luci-app-chatgpt-web package/diy/chatgpt-web

# ## -------------- v2raya ---------------------------
rm -rf feeds/packages/net/v2raya
rm -rf feeds/luci/applications/luci-app-v2raya
git clone https://github.com/v2rayA/v2raya-openwrt package/diy/v2raya

# rm -rf package/diy/v2raya/v2ray-core

## customize v2raya ver
sleep 1
v2aver=2.2.5.8
v2asha256=($(curl -sL https://codeload.github.com/v2rayA/v2rayA/tar.gz/v$v2aver | shasum -a 256))
v2awebsha256=($(curl -sL https://github.com/v2rayA/v2rayA/releases/download/v$v2aver/web.tar.gz | shasum -a 256))
echo v2raya $v2aver sha256=$v2asha256
echo v2raya-web $v2aver sha256=$v2awebsha256
sed -i 's/PKG_VERSION:=.*/PKG_VERSION:='"$v2aver"'/g;s/PKG_HASH:=.*/PKG_HASH:='"$v2asha256"'/g;59 s/	HASH:=.*/	HASH:='"$v2awebsha256"'/g' package/diy/v2raya/v2raya/Makefile

# fix mijia cloud wrong dns (use xraycore)-------
cp ${GITHUB_WORKSPACE}/_modFiles/v2raya.init package/diy/v2raya/v2raya/files/v2raya.init
# sed -i 's/v2ray_bin"/v2ray_bin" "\/usr\/bin\/xray"/g;s/v2ray_confdir"/v2ray_confdir" "\/etc\/v2raya\/xray"/g' package/diy/v2raya/v2raya/files/v2raya.init
#or
# curl -sL -m 30 --retry 2 https://gitlab.com/budaig/budaig.gitlab.io/-/raw/source/source/foto/v2raya.init -o package/diy/v2raya/v2raya/files/v2raya.init
mkdir -p package/diy/v2raya/luci-app-v2raya/root/etc/v2raya/xray
cp ${GITHUB_WORKSPACE}/_modFiles/xrayconfig.json package/diy/v2raya/luci-app-v2raya/root/etc/v2raya/xray/config.json
# or
# curl -sL -m 30 --retry 2 https://gitlab.com/budaig/budaig.gitlab.io/-/raw/source/source/foto/xrayconfig.json -o package/diy/v2raya/luci-app-v2raya/root/etc/v2raya/xray/config.json
# # go 1.21.4
# cp ${GITHUB_WORKSPACE}/_modFiles/100-go-mod-ver.patch package/diy/v2raya/xray-core/patches/100-go-mod-ver.patch
# sed -i 's/1.21.7/1.21.9/g' package/diy/v2raya/xray-core/patches/100-go-mod-ver.patch

# sleep 1
# curl -sL -m 30 --retry 2 https://gitlab.com/budaig/budaig.gitlab.io/-/raw/source/source/foto/v2raya-static-config.js -o package/diy/v2raya/luci-app-v2raya/htdocs/luci-static/resources/view/v2raya/config.js
# curl -sL -m 30 --retry 2 https://gitlab.com/budaig/budaig.gitlab.io/-/raw/source/source/foto/mijia-hook.sh -o package/diy/v2raya/luci-app-v2raya/root/usr/share/mijia-hook.sh
# chmod +x package/diy/v2raya/luci-app-v2raya/root/usr/share/mijia-hook.sh
# rm package/diy/v2raya/v2raya/files/v2raya.init
# curl -sL -m 30 --retry 2 https://gitlab.com/budaig/budaig.gitlab.io/-/raw/source/source/foto/v2raya02.init -o package/diy/v2raya/v2raya/files/v2raya.init
# chmod +x package/diy/v2raya/v2raya/files/v2raya.init
# fix mijia cloud ------------------------

## customize xray
# use yicha xray status for 22.03 or up---------------
# rm -rf package/diy/v2raya/xray-core
# mkdir -p package/diy/v2raya/luci-app-xray
# git clone https://github.com/yichya/luci-app-xray package/diy/v2raya/luci-app-xray
# use yicha xray status ---------------

# use custom ver ----------------
sleep 1
# vrver=5.16.1
# vrsha256=($(curl -sL https://codeload.github.com/v2fly/v2ray-core/tar.gz/v$vrver | shasum -a 256))
# echo v2ray $vrver sha256=$vrsha256
# sed -i '8 s/.*/PKG_VERSION:='"$vrver"'/g;13 s/.*/PKG_HASH:='"$vrsha256"'/g' package/diy/v2raya/v2ray-core/Makefile

xrver=1.8.23
xrsha256=($(curl -sL https://codeload.github.com/XTLS/Xray-core/tar.gz/v$xrver | shasum -a 256))
echo xray $xrver sha256=$xrsha256
sed -i '8 s/.*/PKG_VERSION:='"$xrver"'/g;13 s/.*/PKG_HASH:='"$xrsha256"'/g' package/diy/v2raya/xray-core/Makefile

## 更新v2ra geoip geosite 数据库

datetime1=$(date +"%Y%m%d%H%M")
ipsha256=($(curl -sL https://github.com/v2fly/geoip/releases/latest/download/geoip.dat | shasum -a 256))
sed -i '15 s/.*/GEOIP_VER:='"$datetime1"'/g;18 s/.*/  URL:=https:\/\/github.com\/v2fly\/geoip\/releases\/latest\/download\//g;21 s/.*/  HASH:='"$ipsha256"'/g' package/diy/v2raya/v2fly-geodata/Makefile
# # https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat

datetime2=$(date +"%Y%m%d%H%M%S")
sitesha256=($(curl -sL https://github.com/v2fly/domain-list-community/releases/latest/download/dlc.dat | shasum -a 256))
sed -i '24 s/.*/GEOSITE_VER:='"$datetime2"'/g;27 s/.*/  URL:=https:\/\/github.com\/v2fly\/domain-list-community\/releases\/latest\/download\//g;30 s/.*/  HASH:='"$sitesha256"'/g' package/diy/v2raya/v2fly-geodata/Makefile

## GeoSite-GFWlist4v2ra数据库 
curl -sL -m 30 --retry 2 https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat -o /tmp/geosite.dat
sleep 1
mkdir -p package/diy/v2raya/luci-app-v2raya/root/usr/share/xray
# rm package/diy/v2raya/luci-app-v2raya/root/usr/share/xray/LoyalsoldierSite.dat
mv /tmp/geosite.dat package/diy/v2raya/luci-app-v2raya/root/usr/share/xray/LoyalsoldierSite.dat >/dev/null 2>&1
# mkdir -p package/diy/v2raya/luci-app-v2raya/root/usr/share/v2ray
# # rm package/diy/v2raya/luci-app-v2raya/root/usr/share/xray/LoyalsoldierSite.dat
# mv /tmp/geosite.dat package/diy/v2raya/luci-app-v2raya/root/usr/share/v2ray/LoyalsoldierSite.dat >/dev/null 2>&1
# ## ---------------------------------------------------------

# ## -------------- smartdns ---------------------------
rm -rf feeds/packages/net/smartdns
rm -rf feeds/luci/applications/luci-app-smartdns
git clone https://github.com/pymumu/openwrt-smartdns package/diy/smartdns
git clone https://github.com/pymumu/luci-app-smartdns -b master package/diy/luci-app-smartdns

## update to the newest
SMARTDNS_VER=$(echo -n `curl -sL https://api.github.com/repos/pymumu/smartdns/commits | jq .[0].commit.committer.date | awk -F "T" '{print $1}' | sed 's/\"//g' | sed 's/\-/\./g'`)
SMAERTDNS_SHA=$(echo -n `curl -sL https://api.github.com/repos/pymumu/smartdns/commits | jq .[0].sha | sed 's/\"//g'`)
echo smartdns $SMARTDNS_VER sha256=$SMAERTDNS_SHA

#customize ver
# SMARTDNS_VER=2024.05.08
# SMAERTDNS_SHA=f92fbb83cefb0446fc5dd1b0cd16fc6b2fc7664c
# ------
#fix 2024.05.09 ver
#failed sed -i 's/pymumu\/smartdns/zxlhhyccc\/smartdns\/tree\/patch-12/g' package/diy/smartdns/Makefile
#failed sed -i '33 s/.*/  URL:=https:\/\/github.com\/zxlhhyccc\/smartdns\/tree\/patch-12\//g' package/diy/smartdns/Makefile
# sed -i 's/.*/pymumu\/smartdns/zxlhhyccc\/smartdns\/tree\/patch-12.git/g' package/diy/smartdns/Makefile
# # ------

sed -i '/PKG_MIRROR_HASH:=/d' package/diy/smartdns/Makefile
sed -i 's/PKG_VERSION:=.*/PKG_VERSION:='"$SMARTDNS_VER"'/g' package/diy/smartdns/Makefile
sed -i 's/PKG_SOURCE_VERSION:=.*/PKG_SOURCE_VERSION:='"$SMAERTDNS_SHA"'/g' package/diy/smartdns/Makefile
sed -i 's/PKG_VERSION:=.*/PKG_VERSION:='"$SMARTDNS_VER"'/g' package/diy/luci-app-smartdns/Makefile
sed -i 's/..\/..\/luci.mk/$(TOPDIR)\/feeds\/luci\/luci.mk/g' package/diy/luci-app-smartdns/Makefile

## add anti-ad data
mkdir -p package/diy/luci-app-smartdns/root/etc/smartdns/domain-set
# ls -dR package/diy/luci-app-smartdns/root/etc/smartdns
sleep 1
urlreject="https://anti-ad.net/anti-ad-for-smartdns.conf"
curl -sL -m 30 --retry 2 "$urlreject" -o /tmp/reject.conf
mv /tmp/reject.conf package/diy/luci-app-smartdns/root/etc/smartdns/reject.conf >/dev/null 2>&1
## add githubhosts
urlgthosts="https://raw.githubusercontent.com/hululu1068/AdRules/main/rules/github-hosts.conf"
curl -sL -m 30 --retry 2 "$urlgthosts" -o package/diy/luci-app-smartdns/root/etc/smartdns/domain-set/gthosts.conf
# ls -l package/diy/luci-app-smartdns/root/etc/smartdns
# ## ---------------------------------------------------------

# ## replace a theme
# rm -rf ./feeds/luci/themes/luci-theme-argon
# git clone -b master https://github.com/jerrykuku/luci-theme-argon.git ./feeds/luci/themes/luci-theme-argon
# replace theme bg
rm feeds/luci/themes/luci-theme-argon/htdocs/luci-static/argon/img/bg1.jpg
cp ${GITHUB_WORKSPACE}/_modFiles/bg1.jpg feeds/luci/themes/luci-theme-argon/htdocs/luci-static/argon/img/bg1.jpg
# or
# curl -sL -m 30 --retry 2 https://gitlab.com/budaig/budaig.gitlab.io/-/raw/source/source/foto/bg1.jpg -o /tmp/bg1.jpg 
# mv /tmp/bg1.jpg feeds/luci/themes/luci-theme-argon/htdocs/luci-static/argon/img/bg1.jpg

# ## Enable Cache
# echo -e 'CONFIG_DEVEL=y\nCONFIG_CCACHE=y' >> .config


}
