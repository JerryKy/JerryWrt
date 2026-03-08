#!/bin/bash

# Modify hostname
sed -i 's/ImmortalWrt/JerryWrt/g' package/base-files/files/bin/config_generate

# 更新argon
rm -rf package/feeds/luci/luci-theme-argon
git clone https://github.com/jerrykuku/luci-theme-argon.git package/feeds/luci/luci-theme-argon

# 修改默认设置
sed -i '$d' package/emortal/default-settings/files/99-default-settings-chinese
cat >>package/emortal/default-settings/files/99-default-settings-chinese<< EOF
# 修改默认主题
uci set luci.main.mediaurlbase='/luci-static/argon'
uci commit luci

# 修改默认地址
uci set network.lan.ipaddr='192.168.50.60'
uci commit network

# 修改okpg源
sed -i -E '/src\/gz immortalwrt_(jerry|lucky|helloworld)/d' /etc/opkg/distfeeds.conf

exit 0
EOF

# 自定义登录背景图片、浏览器图标
[ -e $GITHUB_WORKSPACE/images/favicon.ico ] && mv $GITHUB_WORKSPACE/images/favicon.ico package/feeds/luci/luci-theme-argon/htdocs/luci-static/argon/favicon.ico
[ -e $GITHUB_WORKSPACE/images/img/bg1.jpg ] && mv $GITHUB_WORKSPACE/images/img/bg1.jpg package/feeds/luci/luci-theme-argon/htdocs/luci-static/argon/img/bg1.jpg
[ -e $GITHUB_WORKSPACE/images/img/argon.svg ] && mv $GITHUB_WORKSPACE/images/img/argon.svg package/feeds/luci/luci-theme-argon/htdocs/luci-static/argon/img/argon.svg
[ -d $GITHUB_WORKSPACE/images/icon ] && mv $GITHUB_WORKSPACE/images/icon/*.png package/feeds/luci/luci-theme-argon/htdocs/luci-static/argon/icon/

# 不下载rust
# ==================== 配置区 ====================
# 基础路径（固定部分）
BASE_DIR="/home/runner/work/JerryWrt/JerryWrt/workdir/openwrt/build_dir/target-x86_64_musl/host"
# 目标配置文件名
CONFIG_FILE_NAME="bootstrap.toml"
# ================================================

# 1. 自动查找以 rustc 开头的目录
echo -e "===== [Step 1] 查找 $BASE_DIR 下以 rustc 开头的目录 ====="
RUSTC_DIRS=($(find "$BASE_DIR" -maxdepth 1 -type d -name "rustc*" | sort))

# 检查是否找到 rustc 目录
if [ ${#RUSTC_DIRS[@]} -eq 0 ]; then
  echo "❌ 错误：在 $BASE_DIR 下未找到以 rustc 开头的目录！"
  exit 1
elif [ ${#RUSTC_DIRS[@]} -gt 1 ]; then
  echo "⚠️ 警告：找到多个 rustc 目录，将使用第一个：${RUSTC_DIRS[0]}"
  echo "   所有找到的目录：${RUSTC_DIRS[*]}"
fi

# 确定最终的配置文件路径
TARGET_CONFIG_FILE="${RUSTC_DIRS[0]}/${CONFIG_FILE_NAME}"
echo -e "✅ 确定目标配置文件路径：$TARGET_CONFIG_FILE\n"

# 2. 打印原始文件内容（Debug 用）
echo -e "===== [Step 2] 打印 $CONFIG_FILE_NAME 原始内容 ====="
if [ -f "$TARGET_CONFIG_FILE" ]; then
  cat "$TARGET_CONFIG_FILE"
else
  echo "⚠️ 警告：配置文件不存在 → $TARGET_CONFIG_FILE"
  echo "🔧 正在创建空配置文件..."
  touch "$TARGET_CONFIG_FILE"
  echo "✅ 已创建空文件：$TARGET_CONFIG_FILE"
fi

# 3. 修改/添加 download-ci-llvm = false 配置
echo -e "\n===== [Step 3] 修改 download-ci-llvm 配置 ====="
# 检查是否存在 [llvm] 段
if grep -q "^[llvm]" "$TARGET_CONFIG_FILE"; then
  # 场景1：存在 [llvm] 段
  if grep -q "download-ci-llvm" "$TARGET_CONFIG_FILE"; then
    # 子场景1：已有 download-ci-llvm 配置 → 直接修改值
    sed -i 's/^[[:space:]]*download-ci-llvm[[:space:]]*=.*/download-ci-llvm = false/' "$TARGET_CONFIG_FILE"
    echo "✅ 已修改 [llvm] 段下的 download-ci-llvm = false"
  else
    # 子场景2：无 download-ci-llvm 配置 → 追加到 [llvm] 段下
    sed -i '/^[llvm]/a download-ci-llvm = false' "$TARGET_CONFIG_FILE"
    echo "✅ 已在 [llvm] 段下添加 download-ci-llvm = false"
  fi
else
  # 场景2：不存在 [llvm] 段 → 直接追加整段配置
  echo -e "\n[llvm]\ndownload-ci-llvm = false" >> "$TARGET_CONFIG_FILE"
  echo "✅ 已添加 [llvm] 段及 download-ci-llvm = false"
fi

# 4. 打印修改后的文件内容（验证结果）
echo -e "\n===== [Step 4] 打印修改后的 $CONFIG_FILE_NAME 内容 ====="
cat "$TARGET_CONFIG_FILE"

echo -e "\n🎉 配置修改完成！目标文件：$TARGET_CONFIG_FILE"