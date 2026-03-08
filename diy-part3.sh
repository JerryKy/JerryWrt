#!/bin/bash

# 禁止下载rust，避免下载时间过长或失败导致构建失败
set -e  # 遇到错误立即退出

# 定义 Rust Makefile 路径（根据你的目录结构）
RUST_MAKEFILE="/home/runner/work/JerryWrt/JerryWrt/workdir/openwrt/feeds/packages/lang/rust/Makefile"

# 检查文件是否存在
if [ ! -f "$RUST_MAKEFILE" ]; then
    echo "❌ 错误：未找到文件 $RUST_MAKEFILE"
    echo "请确认当前目录是 OpenWRT 源码根目录，或修改脚本中的文件路径"
    exit 1
fi

# 替换 HOST_CONFIGURE_ARGS 中的 llvm.download-ci-llvm=true 为 false
echo "📝 修改 HOST_CONFIGURE_ARGS 中的 LLVM 下载配置"
sed -i 's/--set=llvm.download-ci-llvm=true/--set=llvm.download-ci-llvm=false/g' "$RUST_MAKEFILE"

# 验证修改结果
echo -e "\n✅ 修改完成！以下是关键修改验证："
echo -e "\n1. 检查 llvm.download-ci-llvm 配置（应显示 false）："
grep -- "--set=llvm.download-ci-llvm" "$RUST_MAKEFILE" || echo "   ⚠ 验证输出为空，但已执行替换操作"

echo -e "\n🎉 所有修改完成！"