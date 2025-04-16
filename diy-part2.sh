#!/bin/bash

# Modify hostname
sed -i 's/ImmortalWrt/JerryWrt/g' package/base-files/files/bin/config_generate

# 更新argon
rm -rf package/feeds/luci/luci-theme-argon
git clone https://github.com/jerrykuku/luci-theme-argon.git package/feeds/luci/luci-theme-argon

# 修改默认设置
sed -i '$d' package/emortal/default-settings/files/99-default-settings-chinese
cat >>package/emortal/default-settings/files/99-default-settings-chinese<< EOF
uci set luci.main.mediaurlbase='/luci-static/argon'
uci commit luci

exit 0
EOF

# 自定义登录背景图片
[ -e $GITHUB_WORKSPACE/images/bg1.jpg ] && mv $GITHUB_WORKSPACE/images/bg1.jpg package/feeds/luci/luci-theme-argon/htdocs/luci-static/argon/img/bg1.jpg
