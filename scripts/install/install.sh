#!/usr/bin/env bash

# The root of the build/dist directory
CAS_ROOT=$(dirname "${BASH_SOURCE[0]}")/../..
source "${CAS_ROOT}/scripts/install/common.sh"

source "${CAS_ROOT}"/scripts/install/mariadb.sh
source "${CAS_ROOT}"/scripts/install/redis.sh
source "${CAS_ROOT}"/scripts/install/mongodb.sh
source "${CAS_ROOT}"/scripts/install/cas-apiserver.sh
source "${CAS_ROOT}"/scripts/install/cas-authz-server.sh
source "${CAS_ROOT}"/scripts/install/cas-pump.sh
source "${CAS_ROOT}"/scripts/install/cas-watcher.sh
source "${CAS_ROOT}"/scripts/install/casctl.sh
source "${CAS_ROOT}"/scripts/install/man.sh
source "${CAS_ROOT}"/scripts/install/test.sh

# 申请服务器，登录 going 用户后，配置 $HOME/.bashrc 文件
cas::install::prepare_linux()
{
  # 1. 替换 Yum 源为阿里的 Yum 源
  cas::common::sudo "mv /etc/yum.repos.d /etc/yum.repos.d.$$.bak" # 先备份原有的 Yum 源
  cas::common::sudo "mkdir /etc/yum.repos.d"
  cas::common::sudo "wget -O /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-vault-8.5.2111.repo"
  cas::common::sudo "yum clean all"
  cas::common::sudo "yum makecache"


  if [[ -f $HOME/.bashrc ]];then
    cp $HOME/.bashrc $HOME/bashrc.cas.backup
  fi

  # 2. 配置 $HOME/.bashrc
  cat << 'EOF' > $HOME/.bashrc
# .bashrc

# User specific aliases and functions

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

if [ ! -d $HOME/workspace ]; then
    mkdir -p $HOME/workspace
fi

# User specific environment
# Basic envs
export LANG="en_US.UTF-8" # 设置系统语言为 en_US.UTF-8，避免终端出现中文乱码
export PS1='[\u@dev \W]\$ ' # 默认的 PS1 设置会展示全部的路径，为了防止过长，这里只展示："用户名@dev 最后的目录名"
export WORKSPACE="$HOME/workspace" # 设置工作目录
export PATH=$HOME/bin:$PATH # 将 $HOME/bin 目录加入到 PATH 变量中

# Default entry folder
cd $WORKSPACE # 登录系统，默认进入 workspace 目录

# User specific aliases and functions
EOF

  # 3. 安装依赖包
  cas::common::sudo "yum -y install make autoconf automake cmake perl-CPAN libcurl-devel libtool gcc gcc-c++ glibc-headers zlib-devel git-lfs telnet lrzsz jq expat-devel openssl-devel"

  # 4. 安装 Git
  rm -rf /tmp/git-2.36.1.tar.gz /tmp/git-2.36.1 # clean up
  cd /tmp
  wget --no-check-certificate https://mirrors.edge.kernel.org/pub/software/scm/git/git-2.36.1.tar.gz
  tar -xvzf git-2.36.1.tar.gz
  cd git-2.36.1/
  ./configure
  make
  cas::common::sudo "make install"

  cat << 'EOF' >> $HOME/.bashrc
# Configure for git
export PATH=/usr/local/libexec/git-core:$PATH
EOF

  git --version | grep -q 'git version 2.36.1' || {
    cas::log::error "git version is not '2.36.1', maynot install git properly"
    return 1
  }

  # 5. 配置 Git
  git config --global user.name "Lingfei Kong"    # 用户名改成自己的
  git config --global user.email "colin404@foxmail.com"    # 邮箱改成自己的
  git config --global credential.helper store    # 设置 Git，保存用户名和密码
  git config --global core.longpaths true # 解决 Git 中 'Filename too long' 的错误
  git config --global core.quotepath off
  git lfs install --skip-repo

  source $HOME/.bashrc
  cas::log::info "prepare linux basic environment successfully"
}

# 初始化新申请的 Linux 服务器，使其成为一个友好的开发机
function cas::install::init_into_go_env()
{
  # 1. Linux 服务器基本配置
  cas::install::prepare_linux || return 1

  # 2. Go 编译环境安装和配置
  cas::install::go || return 1

  # 3. Go 开发 IDE 安装和配置
  cas::install::vim_ide || return 1

  cas::log::info "initialize linux to go development machine  successfully"
}

# Go 编译环境安装和配置
function cas::install::go_command()
{
  rm -rf /tmp/go1.18.3.linux-amd64.tar.gz $HOME/go/go1.18.3 # clean up

  # 1. 下载 go1.18.3 版本的 Go 安装包
  wget -P /tmp/ https://golang.google.cn/dl/go1.18.3.linux-amd64.tar.gz

  # 2. 安装 Go
  mkdir -p $HOME/go
  tar -xvzf /tmp/go1.18.3.linux-amd64.tar.gz -C $HOME/go
  mv $HOME/go/go $HOME/go/go1.18.3

  # 3. 配置 Go 环境变量
  cat << 'EOF' >> $HOME/.bashrc
# Go envs
export GOVERSION=go1.18.3 # Go 版本设置
export GO_INSTALL_DIR=$HOME/go # Go 安装目录
export GOROOT=$GO_INSTALL_DIR/$GOVERSION # GOROOT 设置
export GOPATH=$WORKSPACE/golang # GOPATH 设置
export PATH=$GOROOT/bin:$GOPATH/bin:$PATH # 将 Go 语言自带的和通过 go install 安装的二进制文件加入到 PATH 路径中
export GO111MODULE="on" # 开启 Go moudles 特性
export GOPROXY=https://goproxy.cn,direct # 安装 Go 模块时，代理服务器设置
export GOPRIVATE=
export GOSUMDB=off # 关闭校验 Go 依赖包的哈希值
EOF
  source $HOME/.bashrc

  # 4. 初始化 Go 工作区
  mkdir -p $GOPATH && cd $GOPATH
  go work init

  cas::log::info "install go compile tool successfully"
}

function cas::install::protobuf()
{
  # 检查 protoc、protoc-gen-go 是否安装
  command -v protoc &>/dev/null && command -v protoc-gen-go &>/dev/null && return 0

  rm -rf /tmp/protobuf # clean up

  # 1. 安装 protobuf
  cd /tmp/
  git clone -b v3.21.1 --depth=1 https://github.com/protocolbuffers/protobuf
  cd protobuf
  libtoolize --automake --copy --debug --force
  ./autogen.sh
  ./configure
  make
  sudo make install
  cas::common::sudo "make install"
  protoc --version | grep -q 'libprotoc 3.21.1' || {
    cas::log::error "protoc version is not '3.21.1', maynot install protobuf properly"
    return 1
  }

  cas::log::info "install protoc tool successfully"


  # 2. 安装 protoc-gen-go
  go install github.com/golang/protobuf/protoc-gen-go@v1.5.2

  cas::log::info "install protoc-gen-go plugin successfully"
}

function cas::install::go()
{
  cas::install::go_command || return 1
  cas::install::protobuf || return 1

  cas::log::info "install go develop environment successfully"
}

function cas::install::vim_ide()
{
  rm -rf $HOME/.vim $HOME/.vimrc /tmp/gotools-for-vim.tgz # clean up

  # 1. 安装 vim-go
  mkdir -p ~/.vim/pack/plugins/start
  git clone --depth=1 https://github.com/fatih/vim-go.git $HOME/.vim/pack/plugins/start/vim-go
  cp "${CAS_ROOT}/scripts/install/vimrc" $HOME/.vimrc

  # 2. Go 工具安装
  wget -P /tmp/ https://marmotedu-1254073058.cos.ap-beijing.myqcloud.com/tools/gotools-for-vim.tgz && {
    mkdir -p $GOPATH/bin
    tar -xvzf /tmp/gotools-for-vim.tgz -C $GOPATH/bin
  }

  source $HOME/.bashrc
  cas::log::info "install vim ide successfully"
}

# 如果是通过脚本安装，需要先尝试获取安装脚本指定的 Tag，Tag 记录在 version 文件中
function cas::install::obtain_branch_flag(){
  if [ -f "${CAS_ROOT}"/version ];then
    echo `cat "${CAS_ROOT}"/version`
  fi
}

function cas::install::prepare_cas()
{
  rm -rf "$WORKSPACE"/golang/src/github.com/Chever-John/cas # clean up

  # 1. 下载 cas 项目代码，先强制删除 cas 目录，确保 cas 源码都是最新的指定版本
  mkdir -p "$WORKSPACE"/golang/src/github.com/Chever-John && cd "$WORKSPACE"/golang/src/github.com/Chever-John
  git clone -b $(cas::install::obtain_branch_flag) --depth=1 https://github.com/Chever-John/cas
  go work use ./cas

  # NOTICE: 因为切换编译路径，所以这里要重新赋值 CAS_ROOT 和 LOCAL_OUTPUT_ROOT
  CAS_ROOT=$WORKSPACE/golang/src/github.com/Chever-John/cas
  LOCAL_OUTPUT_ROOT="${CAS_ROOT}/${OUT_DIR:-_output}"

  pushd ${CAS_ROOT}

  # 2. 配置 $HOME/.bashrc 添加一些便捷入口
  if ! grep -q 'Alias for quick access' $HOME/.bashrc;then
    cat << 'EOF' >> $HOME/.bashrc
# Alias for quick access
export GOSRC="$WORKSPACE/golang/src"
export CAS_ROOT="$GOSRC/github.com/Chever-John/cas"
alias mm="cd $GOSRC/github.com/Chever-John"
alias i="cd $GOSRC/github.com/Chever-John/cas"
EOF
  fi

  # 3. 初始化 MariaDB 数据库，创建 cas 数据库

  # 3.1 登录数据库并创建 cas 用户
  mysql -h127.0.0.1 -P3306 -u"${MARIADB_ADMIN_USERNAME}" -p"${MARIADB_ADMIN_PASSWORD}" << EOF
grant all on cas.* TO ${MARIADB_USERNAME}@127.0.0.1 identified by "${MARIADB_PASSWORD}";
flush privileges;
EOF

  # 3.2 用 cas 用户登录 mysql，执行 cas.sql 文件，创建 cas 数据库
  mysql -h127.0.0.1 -P3306 -u${MARIADB_USERNAME} -p"${MARIADB_PASSWORD}" << EOF
source configs/cas.sql;
show databases;
EOF

  # 4. 创建必要的目录
  echo ${LINUX_PASSWORD} | sudo -S mkdir -p ${CAS_DATA_DIR}/{cas-apiserver,cas-authz-server,cas-pump,cas-watcher}
  cas::common::sudo "mkdir -p ${CAS_INSTALL_DIR}/bin"
  cas::common::sudo "mkdir -p ${CAS_CONFIG_DIR}/cert"
  cas::common::sudo "mkdir -p ${CAS_LOG_DIR}"

  # 5. 安装 cfssl 工具集
  ! command -v cfssl &>/dev/null || ! command -v cfssl-certinfo &>/dev/null || ! command -v cfssljson &>/dev/null && {
    cas::install::install_cfssl || return 1
  }

  # 6. 配置 hosts
  if ! egrep -q 'cas.*chever.me' /etc/hosts;then
    echo ${LINUX_PASSWORD} | sudo -S bash -c "cat << 'EOF' >> /etc/hosts
    127.0.0.1 cas.api.chever.me
    127.0.0.1 cas.authz.chever.me
    EOF"
  fi

  cas::log::info "prepare for cas installation successfully"
  popd
}

function cas::install::unprepare_cas()
{
  pushd ${CAS_ROOT}

  # 1. 删除 cas 数据库和用户
  mysql -h127.0.0.1 -P3306 -u"${MARIADB_ADMIN_USERNAME}" -p"${MARIADB_ADMIN_PASSWORD}" << EOF
drop database cas;
drop user ${MARIADB_USERNAME}@127.0.0.1
EOF

  # 2. 删除创建的目录
  cas::common::sudo "rm -rf ${CAS_DATA_DIR}"
  cas::common::sudo "rm -rf ${CAS_INSTALL_DIR}"
  cas::common::sudo "rm -rf ${CAS_CONFIG_DIR}"
  cas::common::sudo "rm -rf ${CAS_LOG_DIR}"

  # 3. 删除配置 hosts
  echo ${LINUX_PASSWORD} | sudo -S sed -i '/cas.api.chever.me/d' /etc/hosts
  echo ${LINUX_PASSWORD} | sudo -S sed -i '/cas.authz.chever.me/d' /etc/hosts

  cas::log::info "unprepare for cas installation successfully"
  popd
}

function cas::install::install_cfssl()
{
  mkdir -p $HOME/bin/
  wget https://github.com/cloudflare/cfssl/releases/download/v1.6.1/cfssl_1.6.1_linux_amd64 -O $HOME/bin/cfssl
  wget https://github.com/cloudflare/cfssl/releases/download/v1.6.1/cfssljson_1.6.1_linux_amd64 -O $HOME/bin/cfssljson
  wget https://github.com/cloudflare/cfssl/releases/download/v1.6.1/cfssl-certinfo_1.6.1_linux_amd64 -O $HOME/bin/cfssl-certinfo
  #wget https://pkg.cfssl.org/R1.2/cfssl_linux-amd64 -O $HOME/bin/cfssl
  #wget https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64 -O $HOME/bin/cfssljson
  #wget https://pkg.cfssl.org/R1.2/cfssl-certinfo_linux-amd64 -O $HOME/bin/cfssl-certinfo
  chmod +x $HOME/bin/{cfssl,cfssljson,cfssl-certinfo}
  cas::log::info "install cfssl tools successfully"
}

function cas::install::install_storage()
{
  cas::mariadb::install || return 1
  cas::redis::install || return 1
  cas::mongodb::install || return 1
  cas::log::info "install storage successfully"
}

function cas::install::uninstall_storage()
{
  cas::mariadb::uninstall || return 1
  cas::redis::uninstall || return 1
  cas::mongodb::uninstall || return 1
  cas::log::info "uninstall storage successfully"
}

# 安装 cas 应用
function cas::install::install_cas()
{
  # 1. 安装并初始化数据库
  cas::install::install_storage || return 1

  # 2. 先准备安装环境
  cas::install::prepare_cas || return 1

  # 3. 安装 cas-apiserver 服务
  cas::apiserver::install || return 1

  # 4. 安装 casctl 客户端工具
  cas::casctl::install || return 1

  # 5. 安装 cas-authz-server 服务
  cas::authzserver::install || return 1

  # 6. 安装 cas-pump 服务
  cas::pump::install || return 1

  # 7. 安装 cas-watcher 服务
  cas::watcher::install || return 1

  # 8. 安装 man page
  cas::man::install || return 1

  cas::log::info "install cas application successfully"
}

function cas::install::uninstall_cas()
{
  cas::man::uninstall || return 1
  cas::casctl::uninstall || return 1
  cas::pump::uninstall || return 1
  cas::watcher::uninstall || return 1
  cas::authzserver::uninstall || return 1
  cas::apiserver::uninstall || return 1

  cas::install::unprepare_cas || return 1

  cas::install::uninstall_storage|| return 1
}

function cas::install::init_into_vim_env(){
  # 1. Linux 服务器基本配置
  cas::install::prepare_linux || return 1

  # 2. Go 开发 IDE 安装和配置
  cas::install::vim_ide || return 1

  cas::log::info "initialize linux with SpaceVim successfully"
}

function cas::install::install()
{
  # 1. 配置 Linux 使其成为一个友好的 Go 开发机
  cas::install::init_into_go_env || return 1

  # 2. 安装 CAS 应用
  cas::install::install_cas || return 1

  # 3. 测试安装后的 CAS 系统功能是否正常
  cas::test::test || return 1

  cas::log::info "$(echo -e '\033[32mcongratulations, install cas application successfully!\033[0m')"
}

# 卸载。卸载只卸载服务，不卸载环境，不会卸载列表如下：
# - 配置的 $HOME/.bashrc
# - 安装和配置的 Go 编译环境和工具：go、protoc、protoc-gen-go
# - 安装的依赖包
# - 安装的工具：cfssl 工具
# - 下载的 cas 源码包及其目录
# - 安装的 neovim 和 SpaceVim
#
# 也即只卸载 cas 应用部分，卸载后，Linux 仍然是一个友好的 Go 开发机
function cas::install::uninstall()
{
  cas::install::uninstall_cas || return 1
  cas::log::info "uninstall cas application successfully"
}

eval $*