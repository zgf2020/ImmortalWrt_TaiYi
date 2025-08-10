# 固件名称 & 编译署名
sed -i "s/hostname='.*'/hostname='ImmortalWrt'/g" package/base-files/files/bin/config_generate
sed -i "s/(\(luciversion || ''\))/(\1) + (' \/ Built by ImmortalWrt')/g" feeds/luci/modules/luci-mod-status/htdocs/luci-static/resources/view/status/include/10_system.js

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
