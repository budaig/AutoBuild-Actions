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

# pushd feeds/packages/net/xray-core/tools/po2lmo
# make && sudo make install
# popd
# sleep 3

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
package/feeds/telephony/asterisk
"

for cmd in $del_data;
do
 rm -rf $cmd
 echo "Deleted $cmd"
done

# ## update golang to 21.x
git clone https://github.com/sbwml/packages_lang_golang -b 22.x feeds/packages/lang/golang

# ## -------------- adguardhome ---------------------------
# rm -rf feeds/packages/net/adguardhome
# rm -rf feeds/luci/applications/luci-app-adguardhome
# git clone https://github.com/xiaoxiao29/luci-app-adguardhome package/diy/adguardhome
# ## ---------------------------------------------------------

# ## -------------- alist ---------------------------
# replace alist
# rm -rf feeds/packages/net/alist
# rm -rf feeds/luci/applications/luci-app-alist
# alist 3.36 requires go 1.22
# git clone https://github.com/sbwml/luci-app-alist.git feeds/packages/net/alist

## customize alist ver
# sleep 1
# alver=3.35.0
# alwebver=3.35.0
# alsha256=($(curl -sL https://codeload.github.com/alist-org/alist/tar.gz/v$alver | shasum -a 256))
# alwebsha256=($(curl -sL https://github.com/alist-org/alist-web/releases/download/$alwebver/dist.tar.gz | shasum -a 256))
# sed -i 's/PKG_VERSION:=.*/PKG_VERSION:='"$alver"'/g;s/PKG_HASH:=.*/PKG_HASH:='"$alsha256"'/g;26 s/  HASH:=.*/  HASH:='"$alwebsha256"'/g' package/diy/alist/Makefile
# echo alist $alver sha256=$alsha256
# echo alist-web $alwebver sha256=$alwebsha256
# ## ---------------------------------------------------------

# ## -------------- ikoolproxy ---------------------------
git clone -b main https://github.com/ilxp/luci-app-ikoolproxy.git package/diy/luci-app-ikoolproxy
## add video rule
sleep 1
sed -i 's/-traditional -aes256/-aes256/g' package/diy/luci-app-ikoolproxy/root/usr/share/koolproxy/data/gen_ca.sh
curl -sL -m 30 --retry 2 https://gitlab.com/budaig/budaig.gitlab.io/-/raw/source/source/foto/kpupdate -o package/diy/luci-app-ikoolproxy/root/usr/share/koolproxy/kpupdate
urlkp="https://cdn.jsdelivr.net/gh/ilxp/koolproxy@main/rules/koolproxy.txt"
curl -sL -m 30 --retry 2 "$urlkp" -o package/diy/luci-app-ikoolproxy/root/usr/share/koolproxy/data/rules/koolproxy.txt >/dev/null 2>&1
urldl="https://cdn.jsdelivr.net/gh/ilxp/koolproxy@main/rules/daily.txt"
curl -sL -m 30 --retry 2 "$urldl" -o package/diy/luci-app-ikoolproxy/root/usr/share/koolproxy/data/rules/daily.txt >/dev/null 2>&1
# ## ---------------------------------------------------------

# ## -------------- lucky ---------------------------
# rm -rf feeds/packages/net/lucky
# rm -rf feeds/luci/applications/luci-app-lucky
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

rm -rf package/diy/v2raya/v2ray-core
rm -rf package/diy/v2raya/xray-core
rm -rf package/diy/v2raya/v2fly-geodata

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
mkdir -p package/diy/v2raya/luci-app-v2raya/root/etc/v2raya/xray
cp ${GITHUB_WORKSPACE}/_modFiles/xrayconfig.json package/diy/v2raya/luci-app-v2raya/root/etc/v2raya/xray/config.json

# ##  -------------- xray ---------------------------
git clone https://github.com/yichya/openwrt-xray package/diy/openwrt-xray
git clone https://github.com/yichya/openwrt-xray-geodata-cut package/diy/openwrt-geodata
# mkdir -p package/diy/openwrt-xray/root/etc/init.d
# cp ${GITHUB_WORKSPACE}/_modFiles/xray.init package/diy/openwrt-xray/root/etc/init.d/xray
# mkdir -p package/diy/openwrt-xray/root/usr/share/xray
# cp ${GITHUB_WORKSPACE}/_modFiles/xraycfg.json package/diy/openwrt-xray/root/usr/share/xray/xraycfg.json

# ##  -------------- luci app xray ---------------------------
# use yicha xray status for 22.03 or up---------------
# git clone https://github.com/yichya/luci-app-xray package/diy/luci-app-status
# use yicha xray status ---------------
# or use ttimasdf xray/xapp for 21.02 or up---------------
# git clone https://github.com/ttimasdf/luci-app-xray package/diy/luci-app-xapp
# use yicha xray status ---------------
# ## ---------------------------------------------------------

# ## -------------- smartdns ---------------------------
rm -rf feeds/packages/net/smartdns
rm -rf feeds/luci/applications/luci-app-smartdns
git clone https://github.com/pymumu/openwrt-smartdns package/diy/smartdns
git clone https://github.com/pymumu/luci-app-smartdns -b master package/diy/luci-app-smartdns

## update to the newest
# SMARTDNS_VER=$(echo -n `curl -sL https://api.github.com/repos/pymumu/smartdns/commits | jq .[0].commit.committer.date | awk -F "T" '{print $1}' | sed 's/\"//g' | sed 's/\-/\./g'`)
# SMAERTDNS_SHA=$(echo -n `curl -sL https://api.github.com/repos/pymumu/smartdns/commits | jq .[0].sha | sed 's/\"//g'`)
# echo smartdns $SMARTDNS_VER sha256=$SMAERTDNS_SHA

#customize ver
# SMARTDNS_VER=2024.05.08
# SMAERTDNS_SHA=f92fbb83cefb0446fc5dd1b0cd16fc6b2fc7664c
# ------
#fix 2024.05.09 ver
#failed sed -i 's/pymumu\/smartdns/zxlhhyccc\/smartdns\/tree\/patch-12/g' package/diy/smartdns/Makefile
#failed sed -i '33 s/.*/  URL:=https:\/\/github.com\/zxlhhyccc\/smartdns\/tree\/patch-12\//g' package/diy/smartdns/Makefile
# sed -i 's/.*/pymumu\/smartdns/zxlhhyccc\/smartdns\/tree\/patch-12.git/g' package/diy/smartdns/Makefile
# # ------

# sed -i '/PKG_MIRROR_HASH:=/d' package/diy/smartdns/Makefile
# sed -i 's/PKG_VERSION:=.*/PKG_VERSION:='"$SMARTDNS_VER"'/g' package/diy/smartdns/Makefile
# sed -i 's/PKG_SOURCE_VERSION:=.*/PKG_SOURCE_VERSION:='"$SMAERTDNS_SHA"'/g' package/diy/smartdns/Makefile
# sed -i 's/PKG_VERSION:=.*/PKG_VERSION:='"$SMARTDNS_VER"'/g' package/diy/luci-app-smartdns/Makefile
# sed -i 's/..\/..\/luci.mk/$(TOPDIR)\/feeds\/luci\/luci.mk/g' package/diy/luci-app-smartdns/Makefile

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

# CONFIG_TARGET_mediatek_filogic_DEVICE_xiaomi_redmi-router-ax6000=y
grep '^CONFIG_TARGET.*DEVICE.*=y' .config | sed -r 's/.*DEVICE_(.*)=y/\1/' > DEVICE_NAME
cat DEVICE_NAME
# xiaomi_redmi-router-ax6000

grep '^CONFIG_TARGET.*DEVICE.*=y' .config | sed -r 's/.*TARGET_.*_(.*)_DEVICE_.*=y/\1/' > TARGET_NAME
cat TARGET_NAME
# filogic

}
