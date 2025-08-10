# 修改默认IP & 固件名称 & 编译署名
sed -i 's/192.168.1.1/192.168.2.1/g' package/base-files/files/bin/config_generate
sed -i "s/hostname='.*'/hostname='Roc'/g" package/base-files/files/bin/config_generate
sed -i "s/(\(luciversion || ''\))/(\1) + (' \/ Built by ImmortalWrt')/g" feeds/luci/modules/luci-mod-status/htdocs/luci-static/resources/view/status/include/10_system.js

# 升级frp到v0.63.0
sed -i -e 's/^PKG_VERSION:=0\.51\.3$/PKG_VERSION:=0.63.0/' \
       -e 's/^PKG_HASH:=83032399773901348c660d41c967530e794ab58172ccd070db89d5e50d915fef$/PKG_HASH:=e5269cf3d545a90fe3773dd39abe6eb8511f02c1dc0cdf759a65d1e776dc1520/' \
       -e 's#\(\$(INSTALL_DATA) \$(PKG_BUILD_DIR)/\)conf/\(\$(2)\)_full.ini#\1conf/legacy/\2_legacy_full.ini#' \
       -e '/\$(INSTALL_DATA) \$(PKG_BUILD_DIR)\/conf\/legacy\/\$(2)_legacy_full.ini/a \\t$(INSTALL_DATA) $(PKG_BUILD_DIR)/conf/$(2)_full_example.toml $(1)/etc/frp/$(2).d/' \
          feeds/packages/net/frp/Makefile

# 调整NSS驱动q6_region内存区域预留大小（ipq6018.dtsi默认预留85MB，ipq6018-512m.dtsi默认预留55MB，带WiFi必须至少预留54MB，以下分别是改成预留16MB、32MB、64MB和96MB）
# sed -i 's/reg = <0x0 0x4ab00000 0x0 0x[0-9a-f]\+>/reg = <0x0 0x4ab00000 0x0 0x01000000>/' target/linux/qualcommax/files/arch/arm64/boot/dts/qcom/ipq6018-512m.dtsi
# sed -i 's/reg = <0x0 0x4ab00000 0x0 0x[0-9a-f]\+>/reg = <0x0 0x4ab00000 0x0 0x02000000>/' target/linux/qualcommax/files/arch/arm64/boot/dts/qcom/ipq6018-512m.dtsi
# sed -i 's/reg = <0x0 0x4ab00000 0x0 0x[0-9a-f]\+>/reg = <0x0 0x4ab00000 0x0 0x04000000>/' target/linux/qualcommax/files/arch/arm64/boot/dts/qcom/ipq6018-512m.dtsi
# sed -i 's/reg = <0x0 0x4ab00000 0x0 0x[0-9a-f]\+>/reg = <0x0 0x4ab00000 0x0 0x06000000>/' target/linux/qualcommax/files/arch/arm64/boot/dts/qcom/ipq6018-512m.dtsi

# 移除要替换的包
rm -rf feeds/packages/net/open-app-filter
rm -rf feeds/luci/applications/luci-app-appfilter
rm -rf feeds/luci/applications/luci-app-frpc
rm -rf feeds/luci/applications/luci-app-frps
rm -rf feeds/packages/net/adguardhome
rm -rf feeds/packages/lang/golang

# Git稀疏克隆，只克隆指定目录到本地
function git_sparse_clone() {
  branch="$1" repourl="$2" && shift 2
  git clone --depth=1 -b $branch --single-branch --filter=blob:none --sparse $repourl
  repodir=$(echo $repourl | awk -F '/' '{print $(NF)}')
  cd $repodir && git sparse-checkout set $@
  mv -f $@ ../package
  cd .. && rm -rf $repodir
}


./scripts/feeds update -a
./scripts/feeds install -a
