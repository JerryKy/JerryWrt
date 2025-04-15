#!/bin/bash

# Modify hostname
sed -i 's/ImmortalWrt/JerryWrt/g' package/base-files/files/bin/config_generate

# 更新argon
rm -rf package/feeds/luci/luci-theme-argon
git clone https://github.com/jerrykuku/luci-theme-argon.git package/feeds/luci/luci-theme-argon
