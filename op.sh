#!/bin/bash

# 设置字体颜色和样式
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # 无颜色
BOLD=$(tput bold)
RESET=$(tput sgr0)
FONT_SIZE='\033[1;5m' # 较大字号

# 随机选择绿色或黄色作为主界面颜色
COLORS=("$GREEN" "$YELLOW")
MAIN_COLOR=${COLORS[$RANDOM % 2]}

# 解决Backspace和Delete键问题
stty -echoctl
stty erase '^H' # 设置 Backspace 键
stty werase '^[[3~' # 设置 Delete 键

# 显示主界面
show_main_menu() {
    clear
    echo -e "${MAIN_COLOR}${BOLD}${FONT_SIZE}***********************************************************************************"
    echo "------------------------------自编译OpenWRT固件脚本--------------------------------"
    echo "***********************************************************************************"
    echo "* 1.安装Openwrt所需依赖环境"
    echo "* 2.查询Python版本或降级Python"
    echo "* 3.下载Openwrt源码"
    echo "* 4.开始编译OpenWRT固件"
    echo "* 5."
    echo "* 6."
    echo "* 7."
    echo "* 8."
    echo "* 9."
    echo "* 10.退出脚本"
    echo "***********************************************************************************${RESET}"
}

# 安装依赖环境菜单
show_dependencies_menu() {
    clear
    echo -e "${MAIN_COLOR}${BOLD}${FONT_SIZE}***********************************************************************************"
    echo "------------------------------自编译OpenWRT固件脚本--------------------------------"
    echo "***********************************************************************************"
    echo "1.一键安装Openwrt编译所需全部依赖包"
    echo "2.设置允许root用户编译(FORCE_UNSAFE_CONFIGURE=1)"
    echo "3.返回上一级界面"
    echo "4.退出脚本"
    echo "***********************************************************************************${RESET}"
}

# Python管理菜单
show_python_menu() {
    clear
    echo -e "${MAIN_COLOR}${BOLD}${FONT_SIZE}***********************************************************************************"
    echo "------------------------------自编译OpenWRT固件脚本--------------------------------"
    echo "***********************************************************************************"
    echo "1.检查Python版本"
    echo "2.安装指定的Python版本"
    echo "3.返回上一级界面"
    echo "4.退出本脚本"
    echo "***********************************************************************************${RESET}"
}

# Python版本选择菜单
show_python_version_menu() {
    clear
    echo -e "${MAIN_COLOR}${BOLD}${FONT_SIZE}***********************************************************************************"
    echo "------------------------------自编译OpenWRT固件脚本--------------------------------"
    echo "***********************************************************************************"
    echo "1.安装Python3.10.9,并设置为默认版本"
    echo "2.安装Python3.10.6,并设置为默认版本"
    echo "3.安装Python3.9.6,并设置为默认版本"
    echo "4.安装Python3.8.9,并设置为默认版本"
    echo "5.安装Python3.7.9,并设置为默认版本"
    echo "6.安装Python3.6.9,并设置为默认版本"
    echo "7.返回上一级界面"
    echo "8.退出本脚本"
    echo "***********************************************************************************${RESET}"
}

# 源码下载菜单
show_source_menu() {
    clear
    echo -e "${MAIN_COLOR}${BOLD}${FONT_SIZE}***********************************************************************************"
    echo "------------------------------自编译OpenWRT固件脚本--------------------------------"
    echo "***********************************************************************************"
    echo "1.下载LEDE源码"
    echo "2.下载immortalwrt源码"
    echo "3.返回上一级界面"
    echo "4.退出本脚本"
    echo "***********************************************************************************${RESET}"
    echo -e "${RED}请将源码下载到/root或/home目录，否则无法编译！${NC}"
    echo -e "${RED}当前所在的目录：$(pwd)${NC}"
}

# LEDE源码下载菜单
show_lede_menu() {
    clear
    echo -e "${MAIN_COLOR}${BOLD}${FONT_SIZE}***********************************************************************************"
    echo "------------------------------自编译OpenWRT固件脚本--------------------------------"
    echo "***********************************************************************************"
    echo "1.将LEDE源码下载到当前目录下"
    echo "2.输入自定义，LEDE源码的下载路径"
    echo "3.返回上一级界面"
    echo "4.退出本脚本"
    echo "***********************************************************************************${RESET}"
    echo -e "${RED}请将源码下载到/root或/home目录，否则无法编译！${NC}"
    echo -e "${RED}当前所在的目录：$(pwd)${NC}"
}

# ImmortalWRT源码下载菜单
show_immortalwrt_menu() {
    clear
    echo -e "${MAIN_COLOR}${BOLD}${FONT_SIZE}***********************************************************************************"
    echo "------------------------------自编译OpenWRT固件脚本--------------------------------"
    echo "***********************************************************************************"
    echo "1.将源码下载到当前目录下"
    echo "2.输入自定义，immortalwrt源码的下载路径"
    echo "3.返回上一级界面"
    echo "4.退出本脚本"
    echo "***********************************************************************************${RESET}"
    echo -e "${RED}请将源码下载到/root或/home目录，否则无法编译！${NC}"
    echo -e "${RED}当前所在的目录：$(pwd)${NC}"
}

# ImmortalWRT版本选择菜单
show_immortalwrt_version_menu() {
    clear
    echo -e "${MAIN_COLOR}${BOLD}${FONT_SIZE}***********************************************************************************"
    echo "------------------------------自编译OpenWRT固件脚本--------------------------------"
    echo "***********************************************************************************"
    echo "1.下载immortalwrt-18.06k5.4"
    echo "2.下载immortalwrt-18.06"
    echo "3.下载immortalwrt-21.02"
    echo "4.下载immortalwrt-23.05"
    echo "5.下载immortalwrt-24.10"
    echo "6.返回上一级界面"
    echo "7.退出本脚本"
    echo "***********************************************************************************${RESET}"
    echo -e "${RED}请将源码下载到/root或/home目录，否则无法编译！${NC}"
    echo -e "${RED}当前所在的目录：$(pwd)${NC}"
}

# 编译过程菜单
show_compile_menu() {
    clear
    echo -e "${MAIN_COLOR}${BOLD}${FONT_SIZE}***********************************************************************************"
    echo "------------------------------自编译OpenWRT固件脚本--------------------------------"
    echo "***********************************************************************************"
    echo "1.进入OpenWRT源码目录"
    echo "2.是否将download.pl文件curl替换为wget"
    echo "3.是否添加kenzok8第三方插件库"
    echo "4.执行update和install"
    echo "5.是否升级/安装(accesscontrol/argon/ddnsto/samba4/serverchan/pushbot/zerotier)"
    echo "6.再次执行update和install"
    echo "7.执行make menuconfig"
    echo "8.替换固件名称/主题/IP地址等"
    echo "9.执行make download下载DL"
    echo "10.执行make V=s -j线程数"
    echo "11.返回上一级界面"
    echo "12.退出本脚本"
    echo "***********************************************************************************${RESET}"
    echo -e "${RED}当前所在的目录：$(pwd)${NC}"
}

# 插件管理菜单
show_plugins_menu() {
    clear
    echo -e "${MAIN_COLOR}${BOLD}${FONT_SIZE}***********************************************************************************"
    echo "------------------------------自编译OpenWRT固件脚本--------------------------------"
    echo "***********************************************************************************"
    echo "1.安装或升级accesscontrol插件"
    echo "2.安装或升级argon主题插件"
    echo "3.安装或升级ddnsto插件"
    echo "4.安装或升级samba4插件"
    echo "5.安装或升级serverchan插件"
    echo "6.安装或升级pushbot插件"
    echo "7.安装或升级zerotier插件"
    echo "8.返回上一级界面"
    echo "9.退出本脚本"
    echo "***********************************************************************************${RESET}"
    echo -e "${RED}当前所在的源码目录：$(pwd)${NC}"
}

# Argon版本选择菜单1
show_argon_menu1() {
    clear
    echo -e "${MAIN_COLOR}${BOLD}${FONT_SIZE}***********************************************************************************"
    echo "------------------------------自编译OpenWRT固件脚本--------------------------------"
    echo "***********************************************************************************"
    echo "1.下载argon主题插件的master版本"
    echo "2.下载argon主题插件的1806—1.8.4版本"
    echo "3.返回上一级界面"
    echo "4.退出本脚本"
    echo "***********************************************************************************${RESET}"
    echo -e "${RED}当前所在的源码目录：$(pwd)${NC}"
}

# Argon版本选择菜单2
show_argon_menu2() {
    clear
    echo -e "${MAIN_COLOR}${BOLD}${FONT_SIZE}***********************************************************************************"
    echo "------------------------------自编译OpenWRT固件脚本--------------------------------"
    echo "***********************************************************************************"
    echo "1.升级argon主题插件到最新的$(get_remote_version https://raw.githubusercontent.com/jerrykuku/luci-theme-argon/refs/heads/master/Makefile)版本"
    echo "2.将当前源码中的argon主题插件替换为1806—1.8.4版本"
    echo "3.返回上一级界面"
    echo "4.退出本脚本"
    echo "***********************************************************************************${RESET}"
    echo -e "${RED}当前所在的源码目录：$(pwd)${NC}"
}

# Samba4版本选择菜单1
show_samba4_menu1() {
    clear
    echo -e "${MAIN_COLOR}${BOLD}${FONT_SIZE}***********************************************************************************"
    echo "------------------------------自编译OpenWRT固件脚本--------------------------------"
    echo "***********************************************************************************"
    echo "1.下载samba4—v4.18.8版本"
    echo "2.下载samba4—v4.14.14版本"
    echo "3.下载samba4—v4.14.12版本"
    echo "4.返回上一级界面"
    echo "5.退出本脚本"
    echo "***********************************************************************************${RESET}"
    echo -e "${RED}当前所在的源码目录：$(pwd)${NC}"
}

# Samba4版本选择菜单2
show_samba4_menu2() {
    clear
    echo -e "${MAIN_COLOR}${BOLD}${FONT_SIZE}***********************************************************************************"
    echo "------------------------------自编译OpenWRT固件脚本--------------------------------"
    echo "***********************************************************************************"
    echo "1.升级samba4插件到最新的$(get_remote_version https://raw.githubusercontent.com/aige168/samba4/refs/heads/main/Makefile)版本"
    echo "2.将当前源码中的samba4插件替换为v4.18.8版本"
    echo "3.将当前源码中的samba4插件替换为v4.14.14版本"
    echo "4.将当前源码中的samba4插件替换为v4.14.12版本"
    echo "5.返回上一级界面"
    echo "6.退出本脚本"
    echo "***********************************************************************************${RESET}"
    echo -e "${RED}当前所在的源码目录：$(pwd)${NC}"
}

# 固件修改菜单
show_firmware_mod_menu() {
    clear
    echo -e "${MAIN_COLOR}${BOLD}${FONT_SIZE}***********************************************************************************"
    echo "------------------------------自编译OpenWRT固件脚本--------------------------------"
    echo "***********************************************************************************"
    echo "1.LEDE版源码一键修改(固件名称/IP地址/主题/CST-8时区/Nas名称)"
    echo "2.immortalwrt1806/1806k54版源码一键修改(固件名称/IP地址/主题/CST-8时区/Nas名称)"
    echo "3.immortalwrt2102及以上版本源码一键修改(固件名称/IP地址/主题/CST-8时区/Nas名称)"
    echo "4.返回上一级"
    echo "5.退出本脚本"
    echo "***********************************************************************************${RESET}"
    echo -e "${RED}当前所在的源码目录：$(pwd)${NC}"
}

# 获取远程版本信息
get_remote_version() {
    local url=$1
    local version=$(wget -qO- "$url" | grep -oP 'PKG_VERSION:=\K.*' | head -1)
    local release=$(wget -qO- "$url" | grep -oP 'PKG_RELEASE:=\K.*' | head -1)
    echo "$version-$release"
}

# 检查是否在源码目录
is_in_source_dir() {
    local dir=$(pwd)
    [[ $dir == *"lede"* || $dir == *"immortalwrt"* ]]
}

# 检查是否是LEDE目录
is_lede_dir() {
    local dir=$(pwd)
    [[ $dir == *"lede"* ]]
}

# 检查是否是ImmortalWRT 18.06目录
is_immortalwrt1806_dir() {
    local dir=$(pwd)
    [[ $dir == *"immortalwrt1806"* || $dir == *"immortalwrt1806k54"* ]]
}

# 检查是否是ImmortalWRT 21.02+目录
is_immortalwrt2102plus_dir() {
    local dir=$(pwd)
    [[ $dir == *"immortalwrt2102"* || $dir == *"immortalwrt2305"* || $dir == *"immortalwrt2410"* ]]
}

# 安装依赖
install_dependencies() {
    echo -e "${RED}开始安装OpenWRT编译所需全部依赖包...${NC}"
    bash <(wget -qO- https://raw.githubusercontent.com/afala2020/openwrt-packages/refs/heads/main/yilai.sh)
    read -p "按任意键返回..." -n 1
}

# 设置FORCE_UNSAFE_CONFIGURE
set_force_unsafe_configure() {
    if grep -q "export FORCE_UNSAFE_CONFIGURE=1" /etc/profile; then
        echo -e "${RED}export FORCE_UNSAFE_CONFIGURE=1已在/etc/profile文件中，无需重复写入！${NC}"
    else
        echo 'export FORCE_UNSAFE_CONFIGURE=1' >> /etc/profile
        source /etc/profile
        echo -e "${RED}已将FORCE_UNSAFE_CONFIGURE=1写入/etc/profile，建议退出SSH重新登录！${NC}"
    fi
    read -p "按任意键返回..." -n 1
}

# 检查Python版本
check_python_versions() {
    echo -e "${RED}当前Python版本：$(python -V 2>&1)${NC}"
    echo -e "${RED}当前Python3版本：$(python3 -V 2>&1)${NC}"
    read -p "按任意键返回..." -n 1
}

# 安装指定Python版本
install_python_version() {
    local version=$1
    local url=$2
    
    echo -e "${RED}安装Python${version}.....需要等待一会！${NC}"
    sleep 5
    cd /home && rm -rf Python*
    wget https://www.python.org/ftp/python/${version}/Python-${version}.tar.xz
    tar -Jxvf Python-${version}.tar.xz && \
    rm -rf Python-*.tar.xz
    cd /home/Python-${version}
    sudo ./configure --enable-optimizations && \
    sudo make altinstall -j8 && \
    sleep 3
    cd /root && rm -rf /home/Python*
    ls /usr/bin/ | grep python
    ls /usr/local/bin/ | grep python
    
    # 设置默认版本
    if [[ $version == "3.10.9" ]]; then
        sudo update-alternatives --install /usr/bin/python python /usr/local/bin/python3.10 300
        sudo update-alternatives --install /usr/bin/python3 python3 /usr/local/bin/python3.10 300
        sudo update-alternatives --auto python
        sudo update-alternatives --auto python3
    elif [[ $version == "3.10.6" ]]; then
        echo -e "${RED}正在将Python${version}设置为系统默认.....${NC}"
        sudo update-alternatives --install /usr/bin/python python /usr/local/bin/python3.10 300
        sudo update-alternatives --install /usr/bin/python3 python3 /usr/local/bin/python3.10 300
        sudo update-alternatives --auto python
        sudo update-alternatives --auto python3
    elif [[ $version == "3.9.6" ]]; then
        echo -e "${RED}正在将Python${version}设置为系统默认.....${NC}"
        sudo update-alternatives --install /usr/bin/python python /usr/local/bin/python3.9 300
        sudo update-alternatives --install /usr/bin/python3 python3 /usr/local/bin/python3.9 300
        sudo update-alternatives --auto python
        sudo update-alternatives --auto python3
    elif [[ $version == "3.8.9" ]]; then
        echo -e "${RED}正在将Python${version}设置为系统默认.....${NC}"
        sudo update-alternatives --install /usr/bin/python python /usr/local/bin/python3.8 300
        sudo update-alternatives --install /usr/bin/python3 python3 /usr/local/bin/python3.8 300
        sudo update-alternatives --auto python
        sudo update-alternatives --auto python3
    elif [[ $version == "3.7.9" ]]; then
        echo -e "${RED}正在将Python${version}设置为系统默认.....${NC}"
        sudo update-alternatives --install /usr/bin/python python /usr/local/bin/python3.7 300
        sudo update-alternatives --install /usr/bin/python3 python3 /usr/local/bin/python3.7 300
        sudo update-alternatives --auto python
        sudo update-alternatives --auto python3
    elif [[ $version == "3.6.9" ]]; then
        echo -e "${RED}正在将Python${version}设置为系统默认.....${NC}"
        sudo update-alternatives --install /usr/bin/python python /usr/local/bin/python3.6 300
        sudo update-alternatives --install /usr/bin/python3 python3 /usr/local/bin/python3.6 300
        sudo update-alternatives --auto python
        sudo update-alternatives --auto python3
    fi
    
    echo -e "${RED}当前Python版本：$(python -V 2>&1)${NC}"
    echo -e "${RED}当前Python3版本：$(python3 -V 2>&1)${NC}"
    read -p "按任意键返回..." -n 1
}

# 下载LEDE源码
download_lede() {
    local path=$1
    echo -e "${RED}开始下载LEDE源码到：${path}${NC}"
    git clone https://github.com/coolsnowwolf/lede "$path"
    echo -e "${RED}LEDE源码已下载到：${path}${NC}"
    read -p "按任意键返回脚本主界面！" -n 1
}

# 下载ImmortalWRT源码
download_immortalwrt() {
    local version=$1
    local path=$2
    
    case $version in
        1)
            echo -e "${RED}开始下载immortalwrt-18.06k5.4源码到：${path}${NC}"
            git clone -b openwrt-18.06-k5.4 --single-branch https://github.com/immortalwrt/immortalwrt "${path}/immortalwrt1806k54"
            echo -e "${RED}immortalwrt-18.06k5.4源码已下载到：${path}${NC}"
            ;;
        2)
            echo -e "${RED}开始下载immortalwrt-18.06源码到：${path}${NC}"
            git clone -b openwrt-18.06 --single-branch https://github.com/immortalwrt/immortalwrt "${path}/immortalwrt1806"
            echo -e "${RED}immortalwrt-18.06源码已下载到：${path}${NC}"
            ;;
        3)
            echo -e "${RED}开始下载immortalwrt-21.02源码到：${path}${NC}"
            git clone -b openwrt-21.02 --single-branch https://github.com/immortalwrt/immortalwrt "${path}/immortalwrt2102"
            echo -e "${RED}immortalwrt-21.02源码已下载到：${path}${NC}"
            ;;
        4)
            echo -e "${RED}开始下载immortalwrt-23.05源码到：${path}${NC}"
            git clone -b openwrt-23.05 --single-branch https://github.com/immortalwrt/immortalwrt "${path}/immortalwrt2305"
            echo -e "${RED}immortalwrt-23.05源码已下载到：${path}${NC}"
            ;;
        5)
            echo -e "${RED}开始下载immortalwrt-24.10源码到：${path}${NC}"
            git clone -b openwrt-24.10 --single-branch https://github.com/immortalwrt/immortalwrt "${path}/immortalwrt2410"
            echo -e "${RED}immortalwrt-2410源码已下载到：${path}${NC}"
            ;;
    esac
    
    read -p "按任意键返回脚本主界面！" -n 1
}

# 替换download.pl中的curl为wget
replace_curl_with_wget() {
    if is_in_source_dir; then
        echo -e "${RED}当前所在的源码目录：$(pwd)${NC}"
        read -p "是否将download.pl文件curl替换为wget？(y/n): " choice
        case $choice in
            y|Y)
                if is_immortalwrt1806_dir; then
                    sed -i 's/curl -f --connect-timeout 20 --retry 5 --location --insecure/wget --tries=2 --timeout=20 --no-check-certificate --output-document=-/g' ./scripts/download.pl
                    sed -i 's/CURL_OPTIONS/WGET_OPTIONS/g' ./scripts/download.pl
                else
                    sed -i 's/curl -f --connect-timeout 20 --retry 5 --location/wget --tries=2 --timeout=20 --output-document=-/g' ./scripts/download.pl
                    sed -i 's/--insecure/--no-check-certificate/g' ./scripts/download.pl
                    sed -i 's/CURL_OPTIONS/WGET_OPTIONS/g' ./scripts/download.pl
                fi
                echo -e "${RED}已将curl替换成wget，按任意键返回！${NC}"
                read -p "" -n 1
                ;;
            *)
                return
                ;;
        esac
    else
        echo -e "${RED}当前路径未在OpenWRT源码目录中，请返回选择进入源码目录！${NC}"
        read -p "按任意键返回..." -n 1
    fi
}

# 添加kenzok8插件库
add_kenzok8_repo() {
    if is_in_source_dir; then
        echo -e "${RED}当前所在的源码目录：$(pwd)${NC}"
        read -p "是否添加kenzok8第三方插件库到源码中？(y/n): " choice
        case $choice in
            y|Y)
                if ! grep -q "kenzok8/openwrt-packages" feeds.conf.default; then
                    sed -i '$a src-git kenzo https://github.com/kenzok8/openwrt-packages' feeds.conf.default
                    sed -i '$a src-git smpackageX https://github.com/kenzok8/small-package' feeds.conf.default
                    echo -e "${RED}已将kenzok8插件库添加到feeds.conf.default文件中！${NC}"
                    echo -e "${RED}开始执行update和install，请等待一会！${NC}"
                    ./scripts/feeds update -a
                    ./scripts/feeds install -a
                else
                    echo -e "${RED}feeds.conf.default文件中已存在kenzok8插件库，无需重复添加！${NC}"
                fi
                read -p "按任意键返回..." -n 1
                ;;
            *)
                return
                ;;
        esac
    else
        echo -e "${RED}当前路径未在OpenWRT源码目录中，请返回选择进入源码目录！${NC}"
        read -p "按任意键返回..." -n 1
    fi
}

# 执行update和install
run_feeds_update_install() {
    if is_in_source_dir; then
        echo -e "${RED}开始执行update和install，请等待一会！${NC}"
        ./scripts/feeds update -a
        ./scripts/feeds install -a
        echo -e "${RED}update和install已完成运行，请按任意键返回！${NC}"
        read -p "" -n 1
    else
        echo -e "${RED}当前路径未在OpenWRT源码目录中，请返回选择进入源码目录！${NC}"
        read -p "按任意键返回..." -n 1
    fi
}

# 处理accesscontrol插件
handle_accesscontrol() {
    if is_in_source_dir; then
        local makefile_path="./feeds/luci/applications/luci-app-accesscontrol/Makefile"
        if [ -f "$makefile_path" ]; then
            local local_version=$(grep "PKG_VERSION:=" "$makefile_path" | cut -d '=' -f2)
            local local_release=$(grep "PKG_RELEASE:=" "$makefile_path" | cut -d '=' -f2)
            echo -e "${RED}当前源码中accesscontrol插件的版本：${local_version}-${local_release}${NC}"
            
            local remote_version=$(wget -qO- https://raw.githubusercontent.com/aige168/luci-app-accesscontrol/refs/heads/main/Makefile | grep "PKG_VERSION:=" | cut -d '=' -f2)
            local remote_release=$(wget -qO- https://raw.githubusercontent.com/aige168/luci-app-accesscontrol/refs/heads/main/Makefile | grep "PKG_RELEASE:=" | cut -d '=' -f2)
            echo -e "${RED}远程仓库中accesscontrol插件的最新版本：${remote_version}-${remote_release}${NC}"
            
            if [ "$local_version-$local_release" == "$remote_version-$remote_release" ]; then
                echo -e "${RED}accesscontrol插件已是最新版本，无需升级!${NC}"
            else
                read -p "是否将accesscontrol插件升级到最新的${remote_version}-${remote_release}版本？(y/n): " choice
                case $choice in
                    y|Y)
                        find . -type d -name "*accesscontrol" -exec rm -rf {} \;
                        git clone https://github.com/aige168/luci-app-accesscontrol.git ./feeds/luci/applications/luci-app-accesscontrol
                        local new_version=$(grep "PKG_VERSION:=" "$makefile_path" | cut -d '=' -f2)
                        local new_release=$(grep "PKG_RELEASE:=" "$makefile_path" | cut -d '=' -f2)
                        echo -e "${RED}升级后源码中accesscontrol插件的版本：${new_version}-${new_release}${NC}"
                        echo -e "${RED}accesscontrol插件已升级到最新版本，请返回执行update和install${NC}"
                        ;;
                esac
            fi
        else
            read -p "accesscontrol插件不存在,是否下载安装？(y/n): " choice
            case $choice in
                y|Y)
                    find . -type d -name "*accesscontrol" -exec rm -rf {} \;
                    git clone https://github.com/aige168/luci-app-accesscontrol.git ./feeds/luci/applications/luci-app-accesscontrol
                    local new_version=$(grep "PKG_VERSION:=" "$makefile_path" | cut -d '=' -f2)
                    local new_release=$(grep "PKG_RELEASE:=" "$makefile_path" | cut -d '=' -f2)
                    echo -e "${RED}当前源码中accesscontrol插件的版本：${new_version}-${new_release}${NC}"
                    echo -e "${RED}accesscontrol插件源码已下载，请返回执行update和install${NC}"
                    ;;
            esac
        fi
        read -p "按任意键返回..." -n 1
    else
        echo -e "${RED}当前路径未在OpenWRT源码目录中，请返回选择进入源码目录！${NC}"
        read -p "按任意键返回..." -n 1
    fi
}

# 处理argon主题
handle_argon() {
    if is_in_source_dir; then
        local makefile_path="./feeds/luci/themes/luci-theme-argon/Makefile"
        if [ -f "$makefile_path" ]; then
            local local_version=$(grep "PKG_VERSION:=" "$makefile_path" | cut -d '=' -f2)
            local local_release=$(grep "PKG_RELEASE:=" "$makefile_path" | cut -d '=' -f2)
            echo -e "${RED}当前源码中argon主题插件的版本：${local_version}-${local_release}${NC}"
            
            local remote_version=$(wget -qO- https://raw.githubusercontent.com/jerrykuku/luci-theme-argon/refs/heads/master/Makefile | grep "PKG_VERSION:=" | cut -d '=' -f2)
            local remote_release=$(wget -qO- https://raw.githubusercontent.com/jerrykuku/luci-theme-argon/refs/heads/master/Makefile | grep "PKG_RELEASE:=" | cut -d '=' -f2)
            echo -e "${RED}远程仓库中argon主题插件的最新版本：${remote_version}-${remote_release}${NC}"
            
            if [ "$local_version-$local_release" == "$remote_version-$remote_release" ]; then
                read -p "argon主题插件已是最新版本无需升级，但可以替换为1806版本，是否去替换？(y/n): " choice
                case $choice in
                    y|Y)
                        show_argon_menu2
                        read -p "请选择操作(1-4): " argon_choice
                        case $argon_choice in
                            1)
                                find . -type d -name "*argon" -exec rm -rf {} \;
                                git clone -b master https://github.com/jerrykuku/luci-theme-argon.git ./feeds/luci/themes/luci-theme-argon
                                echo -e "${RED}argon主题插件已更新到最新版，请返回执行update和install${NC}"
                                ;;
                            2)
                                find . -type d -name "*argon" -exec rm -rf {} \;
                                git clone -b 18.06 https://github.com/jerrykuku/luci-theme-argon.git ./feeds/luci/themes/luci-theme-argon
                                echo -e "${RED}已将当前源码中argon主题插件替换为1806—1.8.4版本，请返回执行update和install${NC}"
                                ;;
                            3) return ;;
                            4) exit 0 ;;
                        esac
                        ;;
                esac
            else
                read -p "是否将argon主题插件升级到最新的${remote_version}-${remote_release}版本？(y/n): " choice
                case $choice in
                    y|Y)
                        show_argon_menu2
                        read -p "请选择操作(1-4): " argon_choice
                        case $argon_choice in
                            1)
                                find . -type d -name "*argon" -exec rm -rf {} \;
                                git clone -b master https://github.com/jerrykuku/luci-theme-argon.git ./feeds/luci/themes/luci-theme-argon
                                echo -e "${RED}argon主题插件已更新到最新版，请返回执行update和install${NC}"
                                ;;
                            2)
                                find . -type d -name "*argon" -exec rm -rf {} \;
                                git clone -b 18.06 https://github.com/jerrykuku/luci-theme-argon.git ./feeds/luci/themes/luci-theme-argon
                                echo -e "${RED}已将当前源码中argon主题插件替换为1806—1.8.4版本，请返回执行update和install${NC}"
                                ;;
                            3) return ;;
                            4) exit 0 ;;
                        esac
                        ;;
                esac
            fi
        else
            read -p "argon主题插件不存在,是否下载安装？(y/n): " choice
            case $choice in
                y|Y)
                    show_argon_menu1
                    read -p "请选择版本(1-3): " version_choice
                    case $version_choice in
                        1)
                            find . -type d -name "*argon" -exec rm -rf {} \;
                            git clone -b master https://github.com/jerrykuku/luci-theme-argon.git ./feeds/luci/themes/luci-theme-argon
                            echo -e "${RED}argon主题插件的master版本源码已下载，请返回执行update和install${NC}"
                            ;;
                        2)
                            find . -type d -name "*argon" -exec rm -rf {} \;
                            git clone -b 18.06 https://github.com/jerrykuku/luci-theme-argon.git ./feeds/luci/themes/luci-theme-argon
                            echo -e "${RED}argon主题插件的1806—1.8.4版本源码已下载，请返回执行update和install${NC}"
                            ;;
                        3) return ;;
                        4) exit 0 ;;
                    esac
                    ;;
            esac
        fi
        read -p "按任意键返回..." -n 1
    else
        echo -e "${RED}当前路径未在OpenWRT源码目录中，请返回选择进入源码目录！${NC}"
        read -p "按任意键返回..." -n 1
    fi
}

# 处理ddnsto插件
handle_ddnsto() {
    if is_in_source_dir; then
        local ddnsto_path=$(find . -name luci-app-ddnsto | head -1)
        if [ -n "$ddnsto_path" ]; then
            local makefile_path="$ddnsto_path/Makefile"
            local local_version=$(grep "PKG_VERSION:=" "$makefile_path" | cut -d '=' -f2)
            local local_release=$(grep "PKG_RELEASE:=" "$makefile_path" | cut -d '=' -f2)
            echo -e "${RED}当前源码中ddnsto插件的版本：${local_version}-${local_release}${NC}"
            
            local remote_version=$(wget -qO- https://raw.githubusercontent.com/linkease/nas-packages-luci/refs/heads/main/luci/luci-app-ddnsto/Makefile | grep "PKG_VERSION:=" | cut -d '=' -f2)
            local remote_release=$(wget -qO- https://raw.githubusercontent.com/linkease/nas-packages-luci/refs/heads/main/luci/luci-app-ddnsto/Makefile | grep "PKG_RELEASE:=" | cut -d '=' -f2)
            echo -e "${RED}远程仓库中ddnsto插件的最新版本：${remote_version}-${remote_release}${NC}"
            
            if [ "$local_version-$local_release" == "$remote_version-$remote_release" ]; then
                echo -e "${RED}ddnsto插件已是最新版本，无需升级!${NC}"
            else
                read -p "是否将ddnsto插件升级到最新${remote_version}-${remote_release}版本？(y/n): " choice
                case $choice in
                    y|Y)
                        find . -type d -name "*ddnsto*" -exec rm -rf {} \;
                        git clone -b main https://github.com/linkease/nas-packages-luci.git package/luci-app-ddnstoX
                        git clone -b master https://github.com/linkease/nas-packages.git package/luci-app-ddnsto
                        local new_version=$(grep "PKG_VERSION:=" "$(find . -name luci-app-ddnsto | head -1)/Makefile" | cut -d '=' -f2)
                        local new_release=$(grep "PKG_RELEASE:=" "$(find . -name luci-app-ddnsto | head -1)/Makefile" | cut -d '=' -f2)
                        echo -e "${RED}升级后源码中ddnsto插件的版本：${new_version}-${new_release}${NC}"
                        echo -e "${RED}ddnsto插件已升级到最新版本，请返回执行update和install${NC}"
                        ;;
                esac
            fi
        else
            read -p "ddnsto插件不存在,是否下载安装？(y/n): " choice
            case $choice in
                y|Y)
                    find . -type d -name "*ddnsto*" -exec rm -rf {} \;
                    git clone -b main https://github.com/linkease/nas-packages-luci.git package/luci-app-ddnstoX
                    git clone -b master https://github.com/linkease/nas-packages.git package/luci-app-ddnsto
                    local new_version=$(grep "PKG_VERSION:=" "$(find . -name luci-app-ddnsto | head -1)/Makefile" | cut -d '=' -f2)
                    local new_release=$(grep "PKG_RELEASE:=" "$(find . -name luci-app-ddnsto | head -1)/Makefile" | cut -d '=' -f2)
                    echo -e "${RED}当前源码中ddnsto插件的版本：${new_version}-${new_release}${NC}"
                    echo -e "${RED}ddnsto插件源码已下载，请返回执行update和install${NC}"
                    ;;
            esac
        fi
        read -p "按任意键返回..." -n 1
    else
        echo -e "${RED}当前路径未在OpenWRT源码目录中，请返回选择进入源码目录！${NC}"
        read -p "按任意键返回..." -n 1
    fi
}

# 处理samba4插件
handle_samba4() {
    if is_in_source_dir; then
        local makefile_path="./feeds/packages/net/samba4/Makefile"
        if [ -f "$makefile_path" ]; then
            local local_version=$(grep "PKG_VERSION:=" "$makefile_path" | cut -d '=' -f2)
            local local_release=$(grep "PKG_RELEASE:=" "$makefile_path" | cut -d '=' -f2)
            echo -e "${RED}当前源码中samba4插件的版本：${local_version}-${local_release}${NC}"
            
            local remote_version=$(wget -qO- https://raw.githubusercontent.com/aige168/samba4/refs/heads/main/Makefile | grep "PKG_VERSION:=" | cut -d '=' -f2)
            local remote_release=$(wget -qO- https://raw.githubusercontent.com/aige168/samba4/refs/heads/main/Makefile | grep "PKG_RELEASE:=" | cut -d '=' -f2)
            echo -e "${RED}远程仓库中samba4插件的最新版本：${remote_version}-${remote_release}${NC}"
            
            if [ "$local_version-$local_release" == "$remote_version-$remote_release" ]; then
                read -p "samba4插件已是最新版本无需升级，但可以替换为(v4.18.8或v4.14.14或v4.14.12)，是否进入samba4替换界面？(y/n): " choice
                case $choice in
                    y|Y)
                        show_samba4_menu2
                        read -p "请选择操作(1-6): " samba_choice
                        case $samba_choice in
                            1)
                                rm -rf ./feeds/packages/net/samba4
                                git clone -b main https://github.com/aige168/samba4 ./feeds/packages/net/samba4
                                echo -e "${RED}samba4插件已更新最新${remote_version}-${remote_release}版本，请返回执行update和install${NC}"
                                ;;
                            2)
                                rm -rf ./feeds/packages/net/samba4
                                git clone -b 4.18.8 https://github.com/aige168/samba4 ./feeds/packages/net/samba4
                                echo -e "${RED}已将当前源码中samba4插件替换为v4.18.8版本，请返回执行update和install${NC}"
                                ;;
                            3)
                                rm -rf ./feeds/packages/net/samba4
                                git clone -b 4.14.14 https://github.com/aige168/samba4 ./feeds/packages/net/samba4
                                echo -e "${RED}已将当前源码中samba4插件替换为v4.14.14版本，请返回执行update和install${NC}"
                                ;;
                            4)
                                rm -rf ./feeds/packages/net/samba4
                                git clone -b 4.14.12 https://github.com/aige168/samba4 ./feeds/packages/net/samba4
                                echo -e "${RED}已将当前源码中samba4插件替换为v4.14.12版本，请返回执行update和install${NC}"
                                ;;
                            5) return ;;
                            6) exit 0 ;;
                        esac
                        ;;
                esac
            else
                read -p "是否将samba4插件升级/替换源码中的samba4旧版本？(y/n): " choice
                case $choice in
                    y|Y)
                        show_samba4_menu2
                        read -p "请选择操作(1-6): " samba_choice
                        case $samba_choice in
                            1)
                                rm -rf ./feeds/packages/net/samba4
                                git clone -b main https://github.com/aige168/samba4 ./feeds/packages/net/samba4
                                echo -e "${RED}samba4插件已更新最新${remote_version}-${remote_release}版本，请返回执行update和install${NC}"
                                ;;
                            2)
                                rm -rf ./feeds/packages/net/samba4
                                git clone -b 4.18.8 https://github.com/aige168/samba4 ./feeds/packages/net/samba4
                                echo -e "${RED}已将当前源码中samba4插件替换为v4.18.8版本，请返回执行update和install${NC}"
                                ;;
                            3)
                                rm -rf ./feeds/packages/net/samba4
                                git clone -b 4.14.14 https://github.com/aige168/samba4 ./feeds/packages/net/samba4
                                echo -e "${RED}已将当前源码中samba4插件替换为v4.14.14版本，请返回执行update和install${NC}"
                                ;;
                            4)
                                rm -rf ./feeds/packages/net/samba4
                                git clone -b 4.14.12 https://github.com/aige168/samba4 ./feeds/packages/net/samba4
                                echo -e "${RED}已将当前源码中samba4插件替换为v4.14.12版本，请返回执行update和install${NC}"
                                ;;
                            5) return ;;
                            6) exit 0 ;;
                        esac
                        ;;
                esac
            fi
        else
            read -p "samba4插件不存在,是否下载安装？(y/n): " choice
            case $choice in
                y|Y)
                    show_samba4_menu1
                    read -p "请选择版本(1-5): " version_choice
                    case $version_choice in
                        1)
                            rm -rf ./feeds/packages/net/samba4
                            git clone -b 4.18.8 https://github.com/aige168/samba4 ./feeds/packages/net/samba4
                            echo -e "${RED}samba4插件的v4.18.8版本源码已下载，请返回执行update和install${NC}"
                            ;;
                        2)
                            rm -rf ./feeds/packages/net/samba4
                            git clone -b 4.14.14 https://github.com/aige168/samba4 ./feeds/packages/net/samba4
                            echo -e "${RED}samba4插件的v4.14.14版本源码已下载，请返回执行update和install${NC}"
                            ;;
                        3)
                            rm -rf ./feeds/packages/net/samba4
                            git clone -b 4.14.12 https://github.com/aige168/samba4 ./feeds/packages/net/samba4
                            echo -e "${RED}samba4插件的v4.14.12版本源码已下载，请返回执行update和install${NC}"
                            ;;
                        4) return ;;
                        5) exit 0 ;;
                    esac
                    ;;
            esac
        fi
        read -p "按任意键返回..." -n 1
    else
        echo -e "${RED}当前路径未在OpenWRT源码目录中，请返回选择进入源码目录！${NC}"
        read -p "按任意键返回..." -n 1
    fi
}

# 处理serverchan插件
handle_serverchan() {
    if is_in_source_dir; then
        local makefile_path="./feeds/luci/applications/luci-app-serverchan/Makefile"
        if [ -f "$makefile_path" ]; then
            local local_version=$(grep "PKG_VERSION:=" "$makefile_path" | cut -d '=' -f2)
            local local_release=$(grep "PKG_RELEASE:=" "$makefile_path" | cut -d '=' -f2)
            echo -e "${RED}当前源码中serverchan插件的版本：${local_version}-${local_release}${NC}"
            
            local remote_version=$(wget -qO- https://raw.githubusercontent.com/tty228/luci-app-wechatpush/refs/heads/openwrt-18.06/Makefile | grep "PKG_VERSION:=" | cut -d '=' -f2)
            local remote_release=$(wget -qO- https://raw.githubusercontent.com/tty228/luci-app-wechatpush/refs/heads/openwrt-18.06/Makefile | grep "PKG_RELEASE:=" | cut -d '=' -f2)
            echo -e "${RED}远程仓库中serverchan插件的最新版本：${remote_version}-${remote_release}${NC}"
            
            if [ "$local_version-$local_release" == "$remote_version-$remote_release" ]; then
                echo -e "${RED}serverchan插件已是最新版本，无需升级!${NC}"
            else
                read -p "是否将serverchan插件升级到最新版本？(y/n): " choice
                case $choice in
                    y|Y)
                        find . -type d -name "*-serverchan" -exec rm -rf {} \;
                        git clone -b openwrt-18.06 https://github.com/tty228/luci-app-wechatpush.git ./feeds/luci/applications/luci-app-serverchan
                        local new_version=$(grep "PKG_VERSION:=" "$makefile_path" | cut -d '=' -f2)
                        local new_release=$(grep "PKG_RELEASE:=" "$makefile_path" | cut -d '=' -f2)
                        echo -e "${RED}升级后源码中serverchan插件的版本：${new_version}-${new_release}${NC}"
                        echo -e "${RED}serverchan插件已升级到最新版本，请返回执行update和install${NC}"
                        ;;
                esac
            fi
        else
            read -p "serverchan插件不存在,是否下载安装？(y/n): " choice
            case $choice in
                y|Y)
                    find . -type d -name "*-serverchan" -exec rm -rf {} \;
                    git clone -b openwrt-18.06 https://github.com/tty228/luci-app-wechatpush.git ./feeds/luci/applications/luci-app-serverchan
                    local new_version=$(grep "PKG_VERSION:=" "$makefile_path" | cut -d '=' -f2)
                    local new_release=$(grep "PKG_RELEASE:=" "$makefile_path" | cut -d '=' -f2)
                    echo -e "${RED}当前源码中serverchan插件的版本：${new_version}-${new_release}${NC}"
                    echo -e "${RED}serverchan插件源码已下载，请返回执行update和install${NC}"
                    ;;
            esac
        fi
        read -p "按任意键返回..." -n 1
    else
        echo -e "${RED}当前路径未在OpenWRT源码目录中，请返回选择进入源码目录！${NC}"
        read -p "按任意键返回..." -n 1
    fi
}

# 处理wechatpush插件
handle_wechatpush() {
    if is_in_source_dir; then
        local makefile_path="./feeds/luci/applications/luci-app-wechatpush/Makefile"
        if [ -f "$makefile_path" ]; then
            local local_version=$(grep "PKG_VERSION:=" "$makefile_path" | cut -d '=' -f2)
            local local_release=$(grep "PKG_RELEASE:=" "$makefile_path" | cut -d '=' -f2)
            echo -e "${RED}当前源码中wechatpush插件的版本：${local_version}-${local_release}${NC}"
            
            local remote_version=$(wget -qO- https://raw.githubusercontent.com/tty228/luci-app-wechatpush/refs/heads/master/Makefile | grep "PKG_VERSION:=" | cut -d '=' -f2)
            local remote_release=$(wget -qO- https://raw.githubusercontent.com/tty228/luci-app-wechatpush/refs/heads/master/Makefile | grep "PKG_RELEASE:=" | cut -d '=' -f2)
            echo -e "${RED}远程仓库中wechatpush插件的最新版本：${remote_version}-${remote_release}${NC}"
            
            if [ "$local_version-$local_release" == "$remote_version-$remote_release" ]; then
                echo -e "${RED}wechatpush插件已是最新版本，无需升级!${NC}"
            else
                read -p "是否将wechatpush插件升级到最新版本？(y/n): " choice
                case $choice in
                    y|Y)
                        find . -type d -name "*-wechatpush" -exec rm -rf {} \;
                        git clone -b master https://github.com/tty228/luci-app-wechatpush.git feeds/luci/applications/luci-app-wechatpush
                        local new_version=$(grep "PKG_VERSION:=" "$makefile_path" | cut -d '=' -f2)
                        local new_release=$(grep "PKG_RELEASE:=" "$makefile_path" | cut -d '=' -f2)
                        echo -e "${RED}升级后源码中wechatpush插件的版本：${new_version}-${new_release}${NC}"
                        echo -e "${RED}wechatpush插件已升级到最新版本，请返回执行update和install${NC}"
                        ;;
                esac
            fi
        else
            read -p "wechatpush插件不存在,是否下载安装？(y/n): " choice
            case $choice in
                y|Y)
                    find . -type d -name "*-wechatpush" -exec rm -rf {} \;
                    git clone -b master https://github.com/tty228/luci-app-wechatpush.git feeds/luci/applications/luci-app-wechatpush
                    local new_version=$(grep "PKG_VERSION:=" "$makefile_path" | cut -d '=' -f2)
                    local new_release=$(grep "PKG_RELEASE:=" "$makefile_path" | cut -d '=' -f2)
                    echo -e "${RED}当前源码中wechatpush插件的版本：${new_version}-${new_release}${NC}"
                    echo -e "${RED}wechatpush插件源码已下载，请返回执行update和install${NC}"
                    ;;
            esac
        fi
        read -p "按任意键返回..." -n 1
    else
        echo -e "${RED}当前路径未在OpenWRT源码目录中，请返回选择进入源码目录！${NC}"
        read -p "按任意键返回..." -n 1
    fi
}

# 处理zerotier插件
handle_zerotier() {
    if is_in_source_dir; then
        local makefile_path="./feeds/packages/net/zerotier/Makefile"
        if [ -f "$makefile_path" ]; then
            local local_version=$(grep "PKG_VERSION:=" "$makefile_path" | cut -d '=' -f2)
            local local_release=$(grep "PKG_RELEASE:=" "$makefile_path" | cut -d '=' -f2)
            echo -e "${RED}当前源码中zerotier插件的版本：${local_version}-${local_release}${NC}"
            
            local remote_version=$(wget -qO- https://raw.githubusercontent.com/aige168/zerotier/refs/heads/main/Makefile | grep "PKG_VERSION:=" | cut -d '=' -f2)
            local remote_release=$(wget -qO- https://raw.githubusercontent.com/aige168/zerotier/refs/heads/main/Makefile | grep "PKG_RELEASE:=" | cut -d '=' -f2)
            echo -e "${RED}远程仓库中zerotier插件的最新版本：${remote_version}-${remote_release}${NC}"
            
            if [ "$local_version-$local_release" == "$remote_version-$remote_release" ]; then
                echo -e "${RED}zerotier插件已是最新版本，无需升级!${NC}"
            else
                read -p "是否将zerotier插件升级到最新版本？(y/n): " choice
                case $choice in
                    y|Y)
                        rm -rf ./feeds/packages/net/zerotier
                        git clone https://github.com/aige168/zerotier ./feeds/packages/net/zerotier
                        local new_version=$(grep "PKG_VERSION:=" "$makefile_path" | cut -d '=' -f2)
                        local new_release=$(grep "PKG_RELEASE:=" "$makefile_path" | cut -d '=' -f2)
                        echo -e "${RED}升级后源码中zerotier插件的版本：${new_version}-${new_release}${NC}"
                        echo -e "${RED}zerotier插件已升级到最新版本，请返回执行update和install${NC}"
                        ;;
                esac
            fi
        else
            read -p "zerotier插件不存在,是否下载安装？(y/n): " choice
            case $choice in
                y|Y)
                    rm -rf ./feeds/packages/net/zerotier
                    git clone https://github.com/aige168/zerotier ./feeds/packages/net/zerotier
                    local new_version=$(grep "PKG_VERSION:=" "$makefile_path" | cut -d '=' -f2)
                    local new_release=$(grep "PKG_RELEASE:=" "$makefile_path" | cut -d '=' -f2)
                    echo -e "${RED}当前源码中zerotier插件的版本：${new_version}-${new_release}${NC}"
                    echo -e "${RED}zerotier插件源码已下载，请返回执行update和install${NC}"
                    ;;
            esac
        fi
        read -p "按任意键返回..." -n 1
    else
        echo -e "${RED}当前路径未在OpenWRT源码目录中，请返回选择进入源码目录！${NC}"
        read -p "按任意键返回..." -n 1
    fi
}

# 执行make menuconfig
run_make_menuconfig() {
    if is_in_source_dir; then
        echo -e "${RED}执行make menuconfig，请自行选择架构和需要安装的插件！${NC}"
        sleep 2
        make menuconfig
        echo -e "${RED}make menuconfig已完成执行，请按任意键返回！${NC}"
        read -p "" -n 1
    else
        echo -e "${RED}当前路径未在OpenWRT源码目录中，请返回选择进入源码目录！${NC}"
        read -p "按任意键返回..." -n 1
    fi
}

# 修改LEDE固件参数
modify_lede_firmware() {
    if is_lede_dir; then
        # 修改固件名称
        read -p "请输入修改后的固件名称(回车直接设为NEWIFI): " firmware_name
        if [ -z "$firmware_name" ]; then
            firmware_name="NEWIFI"
        fi
        sed -i "s/LEDE/$firmware_name/g" package/base-files/luci2/bin/config_generate
        echo -e "${RED}已将固件名称修改为：$firmware_name${NC}"
        sleep 2
        
        # 修改IP地址
        while true; do
            read -p "请输入修改后的固件IP地址(回车直接设为192.168.99.1): " ip_address
            if [ -z "$ip_address" ]; then
                ip_address="192.168.99.1"
                break
            elif [[ $ip_address =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                break
            else
                echo -e "${RED}IP地址错误，请重新输入：${NC}"
            fi
        done
        sed -i "s/192.168.1.1/$ip_address/g" package/base-files/luci2/bin/config_generate
        echo -e "${RED}已将固件IP地址修改为：$ip_address${NC}"
        sleep 2
        
        # 设置主题
        echo -e "${RED}正在设置主题，将主题bootstrap修改为argon${NC}"
        sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' ./feeds/luci/collections/luci-light/Makefile && \
        sed -i 's/CONFIG_PACKAGE_luci-theme-bootstrap=y/CONFIG_PACKAGE_luci-theme-bootstrap=n/g' ./.config
        echo -e "${RED}已将主题bootstrap修改为argon！${NC}"
        sleep 2
        
        # 设置时区
        echo -e "${RED}正在设置时区，将UTC时区修改为CST-8时区${NC}"
        sed -i 's/UTC/CST-8/g' package/base-files/luci2/bin/config_generate
        echo -e "${RED}已将UTC时区修改为CST-8时区！${NC}"
        sleep 2
        
        # 设置Nas名称
        echo -e "${RED}正在设置Nas名称，将Nas名称修改为网络存储，需要等待一会${NC}"
        sed -i 's/"NAS"/"网络存储"/g' `grep "NAS" -rl ./`
        echo -e "${RED}已将Nas名称修改为网络存储！${NC}"
        echo -e "${RED}所有参数全部修改完成，按任意键返回！${NC}"
        read -p "" -n 1
    else
        echo -e "${RED}当前路径未在LEDE源码目录中，请返回重新选择源码目录！${NC}"
        read -p "按任意键返回..." -n 1
    fi
}

# 修改ImmortalWRT 18.06固件参数
modify_immortalwrt1806_firmware() {
    if is_immortalwrt1806_dir; then
        # 修改固件名称
        read -p "请输入修改后的固件名称(回车直接设为NEWIFI): " firmware_name
        if [ -z "$firmware_name" ]; then
            firmware_name="NEWIFI"
        fi
        sed -i "s/ImmortalWrt/$firmware_name/g" package/base-files/files/bin/config_generate
        echo -e "${RED}已将固件名称修改为：$firmware_name${NC}"
        sleep 2
        
        # 修改IP地址
        while true; do
            read -p "请输入修改后的固件IP地址(回车直接设为192.168.99.1): " ip_address
            if [ -z "$ip_address" ]; then
                ip_address="192.168.99.1"
                break
            elif [[ $ip_address =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                break
            else
                echo -e "${RED}IP地址错误，请重新输入：${NC}"
            fi
        done
        sed -i "s/192.168.1.1/$ip_address/g" package/base-files/files/bin/config_generate
        echo -e "${RED}已将固件IP地址修改为：$ip_address${NC}"
        sleep 2
        
        # 设置主题
        echo -e "${RED}正在设置主题，将主题bootstrap修改为argon${NC}"
        sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' ./feeds/luci/collections/luci/Makefile && \
        sed -i 's/CONFIG_PACKAGE_luci-theme-bootstrap=y/CONFIG_PACKAGE_luci-theme-bootstrap=n/g' ./.config
        echo -e "${RED}已将主题bootstrap修改为argon！${NC}"
        sleep 2
        
        # 设置时区
        echo -e "${RED}正在设置时区，将UTC时区修改为CST-8时区${NC}"
        sed -i 's/UTC/CST-8/g' package/base-files/files/bin/config_generate
        echo -e "${RED}已将UTC时区修改为CST-8时区！${NC}"
        sleep 2
        
        # 设置Nas名称
        echo -e "${RED}正在设置Nas名称，将Nas名称修改为网络存储，需要等待一会${NC}"
        sed -i 's/"NAS"/"网络存储"/g' `grep "NAS" -rl ./`
        echo -e "${RED}已将Nas名称修改为网络存储！${NC}"
        echo -e "${RED}所有参数全部修改完成，按任意键返回！${NC}"
        read -p "" -n 1
    else
        echo -e "${RED}当前路径未在immortalwrt1806或immortalwrt1806k54源码目录中，请返回重新选择源码目录！${NC}"
        read -p "按任意键返回..." -n 1
    fi
}

# 修改ImmortalWRT 21.02+固件参数
modify_immortalwrt2102plus_firmware() {
    if is_immortalwrt2102plus_dir; then
        # 修改固件名称
        read -p "请输入修改后的固件名称(回车直接设为NEWIFI): " firmware_name
        if [ -z "$firmware_name" ]; then
            firmware_name="NEWIFI"
        fi
        sed -i "s/ImmortalWrt/$firmware_name/g" package/base-files/files/bin/config_generate
        echo -e "${RED}已将固件名称修改为：$firmware_name${NC}"
        sleep 2
        
        # 修改IP地址
        while true; do
            read -p "请输入修改后的固件IP地址(回车直接设为192.168.99.1): " ip_address
            if [ -z "$ip_address" ]; then
                ip_address="192.168.99.1"
                break
            elif [[ $ip_address =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                break
            else
                echo -e "${RED}IP地址错误，请重新输入：${NC}"
            fi
        done
        sed -i "s/192.168.1.1/$ip_address/g" package/base-files/files/bin/config_generate
        echo -e "${RED}已将固件IP地址修改为：$ip_address${NC}"
        sleep 2
        
        # 设置主题
        echo -e "${RED}正在设置主题，将主题bootstrap修改为argon${NC}"
        sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' ./feeds/luci/collections/luci-light/Makefile && \
        sed -i 's/CONFIG_PACKAGE_luci-theme-bootstrap=y/CONFIG_PACKAGE_luci-theme-bootstrap=n/g' ./.config
        echo -e "${RED}已将主题bootstrap修改为argon！${NC}"
        sleep 2
        
        # 设置时区
        echo -e "${RED}正在设置时区，将UTC时区修改为CST-8时区${NC}"
        sed -i 's/UTC/CST-8/g' package/base-files/files/bin/config_generate
        echo -e "${RED}已将UTC时区修改为CST-8时区！${NC}"
        sleep 2
        
        # 设置Nas名称
        echo -e "${RED}正在设置Nas名称，将Nas名称修改为网络存储，需要等待一会${NC}"
        sed -i 's/"NAS"/"网络存储"/g' `grep "NAS" -rl ./`
        echo -e "${RED}已将Nas名称修改为网络存储！${NC}"
        echo -e "${RED}所有参数全部修改完成，按任意键返回！${NC}"
        read -p "" -n 1
    else
        echo -e "${RED}当前路径未在immortalwrt2102、immortalwrt2305、immortalwrt2410源码目录中，请返回重新选择源码目录！${NC}"
        read -p "按任意键返回..." -n 1
    fi
}

# 执行make download
run_make_download() {
    if is_in_source_dir; then
        echo -e "${RED}执行make download，开始下载DL文件！${NC}"
        sleep 2
        make download V=s -j8
        read -p "DL文件已下载1次，是否第2次下载，确保DL下载完整？(y/n): " choice
        case $choice in
            y|Y)
                make download V=s -j1
                ;;
        esac
        read -p "按任意键返回..." -n 1
    else
        echo -e "${RED}当前路径未在OpenWRT源码目录中，请返回选择进入源码目录！${NC}"
        read -p "按任意键返回..." -n 1
    fi
}

# 执行make编译
run_make_compile() {
    if is_in_source_dir; then
        echo -e "${RED}开始编译固件，大约需要1—3小时！${NC}"
        sleep 2
        while true; do
            read -p "请输入编译使用的线程数(1-32): " thread_num
            if [[ $thread_num =~ ^[0-9]+$ ]] && [ $thread_num -ge 1 ] && [ $thread_num -le 32 ]; then
                break
            else
                echo -e "${RED}输入错误，请输入1-32之间的数字！${NC}"
            fi
        done
        echo -e "${RED}开始使用make V=s -j${thread_num}编译固件！${NC}"
        make V=s -j${thread_num}
        
        if [ $? -eq 0 ]; then
            local firmware_path=$(find bin/targets -name "*sysupgrade.bin" | head -1)
            if [ -n "$firmware_path" ]; then
                echo -e "${RED}固件编译成功，固件文件在：$(pwd)/$firmware_path${NC}"
            else
                echo -e "${RED}固件编译成功，但未找到固件文件！${NC}"
            fi
        else
            echo -e "${RED}编译报错或失败，请手动检查错误！${NC}"
        fi
        read -p "按任意键返回..." -n 1
    else
        echo -e "${RED}当前路径未在OpenWRT源码目录中，请返回选择进入源码目录！${NC}"
        read -p "按任意键返回..." -n 1
    fi
}

# 搜索OpenWRT源码目录
search_openwrt_source() {
    local source_dirs=()
    local count=1
    
    echo -e "${RED}正在搜索OpenWRT源码目录...${NC}"
    
    # 搜索/root和/home目录下2层以内的lede或immortalwrt目录
    for dir in $(find /root /home -maxdepth 3 -type d -name "*lede*" -o -name "*immortalwrt*"); do
        source_dirs+=("$dir")
        echo "$count. 进入-$dir-源码目录"
        ((count++))
    done
    
    if [ ${#source_dirs[@]} -eq 0 ]; then
        echo -e "${RED}当前系统未下载OpenWRT源码，请去下载源码！${NC}"
        read -p "按任意键返回..." -n 1
        return
    fi
    
    echo "$((count++)). 返回上一级界面"
    echo "$((count++)). 退出本脚本"
    
    read -p "请选择要进入的目录(1-${#source_dirs[@]}): " choice
    
    if [ $choice -le ${#source_dirs[@]} ]; then
        cd "${source_dirs[$((choice-1))]}"
        echo -e "${RED}已进入-${source_dirs[$((choice-1))]}-源码目录中${NC}"
        echo -e "${RED}当前所在的源码目录：$(pwd)${NC}"
    elif [ $choice -eq $((${#source_dirs[@]}+1)) ]; then
        return
    elif [ $choice -eq $((${#source_dirs[@]}+2)) ]; then
        exit 0
    fi
}

# 主循环
while true; do
    show_main_menu
    read -p "请选择相应的编号(1-10): " main_choice
    
    case $main_choice in
        1) # 安装Openwrt所需依赖环境
            while true; do
                show_dependencies_menu
                read -p "请选择操作(1-4): " dep_choice
                
                case $dep_choice in
                    1) install_dependencies ;;
                    2) set_force_unsafe_configure ;;
                    3) break ;;
                    4) exit 0 ;;
                    *) echo -e "${RED}无效选择，请重新输入！${NC}"; sleep 1 ;;
                esac
            done
            ;;
        2) # 查询Python版本或降级Python
            while true; do
                show_python_menu
                read -p "请选择操作(1-4): " python_choice
                
                case $python_choice in
                    1) check_python_versions ;;
                    2) 
                        while true; do
                            show_python_version_menu
                            read -p "请选择要安装的Python版本(1-8): " version_choice
                            
                            case $version_choice in
                                1) install_python_version "3.10.9" "https://www.python.org/ftp/python/3.10.9/Python-3.10.9.tar.xz" ;;
                                2) install_python_version "3.10.6" "https://www.python.org/ftp/python/3.10.6/Python-3.10.6.tar.xz" ;;
                                3) install_python_version "3.9.6" "https://www.python.org/ftp/python/3.9.6/Python-3.9.6.tar.xz" ;;
                                4) install_python_version "3.8.9" "https://www.python.org/ftp/python/3.8.9/Python-3.8.9.tar.xz" ;;
                                5) install_python_version "3.7.9" "https://www.python.org/ftp/python/3.7.9/Python-3.7.9.tar.xz" ;;
                                6) install_python_version "3.6.9" "https://www.python.org/ftp/python/3.6.9/Python-3.6.9.tar.xz" ;;
                                7) break ;;
                                8) exit 0 ;;
                                *) echo -e "${RED}无效选择，请重新输入！${NC}"; sleep 1 ;;
                            esac
                        done
                        ;;
                    3) break ;;
                    4) exit 0 ;;
                    *) echo -e "${RED}无效选择，请重新输入！${NC}"; sleep 1 ;;
                esac
            done
            ;;
        3) # 下载Openwrt源码
            while true; do
                show_source_menu
                read -p "请选择操作(1-4): " source_choice
                
                case $source_choice in
                    1) # LEDE源码
                        while true; do
                            show_lede_menu
                            read -p "请选择操作(1-4): " lede_choice
                            
                            case $lede_choice in
                                1) 
                                    echo -e "${RED}开始下载LEDE源码到：$(pwd)${NC}"
                                    git clone https://github.com/coolsnowwolf/lede
                                    echo -e "${RED}LEDE源码已下载到：$(pwd)${NC}"
                                    read -p "按任意键返回脚本主界面！" -n 1
                                    ;;
                                2) 
                                    read -p "请输入lede源码的下载路径（绝对路径：/root或/home）：" custom_path
                                    if [ -d "$custom_path" ]; then
                                        echo -e "${RED}开始下载lede源码到：$custom_path${NC}"
                                        git clone https://github.com/coolsnowwolf/lede "$custom_path/lede"
                                        echo -e "${RED}LEDE源码已下载到：$custom_path${NC}"
                                    else
                                        echo -e "${RED}输入的路径不存在！${NC}"
                                    fi
                                    read -p "按任意键返回脚本主界面！" -n 1
                                    ;;
                                3) break ;;
                                4) exit 0 ;;
                                *) echo -e "${RED}无效选择，请重新输入！${NC}"; sleep 1 ;;
                            esac
                        done
                        ;;
                    2) # ImmortalWRT源码
                        while true; do
                            show_immortalwrt_menu
                            read -p "请选择操作(1-4): " immortal_choice
                            
                            case $immortal_choice in
                                1) 
                                    while true; do
                                        show_immortalwrt_version_menu
                                        read -p "请选择版本(1-7): " version_choice
                                        
                                        case $version_choice in
                                            1) download_immortalwrt 1 $(pwd) ;;
                                            2) download_immortalwrt 2 $(pwd) ;;
                                            3) download_immortalwrt 3 $(pwd) ;;
                                            4) download_immortalwrt 4 $(pwd) ;;
                                            5) download_immortalwrt 5 $(pwd) ;;
                                            6) break ;;
                                            7) exit 0 ;;
                                            *) echo -e "${RED}无效选择，请重新输入！${NC}"; sleep 1 ;;
                                        esac
                                    done
                                    ;;
                                2) 
                                    read -p "请输入immortalwrt源码的下载路径（绝对路径：/root或/home）：" custom_path
                                    if [ -d "$custom_path" ]; then
                                        echo -e "${RED}immortalwrt源码将下载到：$custom_path${NC}"
                                        sleep 3
                                        while true; do
                                            show_immortalwrt_version_menu
                                            read -p "请选择版本(1-7): " version_choice
                                            
                                            case $version_choice in
                                                1) download_immortalwrt 1 "$custom_path" ;;
                                                2) download_immortalwrt 2 "$custom_path" ;;
                                                3) download_immortalwrt 3 "$custom_path" ;;
                                                4) download_immortalwrt 4 "$custom_path" ;;
                                                5) download_immortalwrt 5 "$custom_path" ;;
                                                6) break ;;
                                                7) exit 0 ;;
                                                *) echo -e "${RED}无效选择，请重新输入！${NC}"; sleep 1 ;;
                                            esac
                                        done
                                    else
                                        echo -e "${RED}输入的路径不存在！${NC}"
                                        read -p "按任意键返回..." -n 1
                                    fi
                                    ;;
                                3) break ;;
                                4) exit 0 ;;
                                *) echo -e "${RED}无效选择，请重新输入！${NC}"; sleep 1 ;;
                            esac
                        done
                        ;;
                    3) break ;;
                    4) exit 0 ;;
                    *) echo -e "${RED}无效选择，请重新输入！${NC}"; sleep 1 ;;
                esac
            done
            ;;
        4) # 开始编译OpenWRT固件
            while true; do
                show_compile_menu
                read -p "请选择操作(1-12): " compile_choice
                
                case $compile_choice in
                    1) search_openwrt_source ;;
                    2) replace_curl_with_wget ;;
                    3) add_kenzok8_repo ;;
                    4) run_feeds_update_install ;;
                    5) 
                        while true; do
                            show_plugins_menu
                            read -p "请选择要操作的插件(1-9): " plugin_choice
                            
                            case $plugin_choice in
                                1) handle_accesscontrol ;;
                                2) handle_argon ;;
                                3) handle_ddnsto ;;
                                4) handle_samba4 ;;
                                5) handle_serverchan ;;
                                6) handle_wechatpush ;;
                                7) handle_zerotier ;;
                                8) break ;;
                                9) exit 0 ;;
                                *) echo -e "${RED}无效选择，请重新输入！${NC}"; sleep 1 ;;
                            esac
                        done
                        ;;
                    6) run_feeds_update_install ;;
                    7) run_make_menuconfig ;;
                    8) 
                        while true; do
                            show_firmware_mod_menu
                            read -p "请选择操作(1-5): " mod_choice
                            
                            case $mod_choice in
                                1) modify_lede_firmware ;;
                                2) modify_immortalwrt1806_firmware ;;
                                3) modify_immortalwrt2102plus_firmware ;;
                                4) break ;;
                                5) exit 0 ;;
                                *) echo -e "${RED}无效选择，请重新输入！${NC}"; sleep 1 ;;
                            esac
                        done
                        ;;
                    9) run_make_download ;;
                    10) run_make_compile ;;
                    11) break ;;
                    12) exit 0 ;;
                    *) echo -e "${RED}无效选择，请重新输入！${NC}"; sleep 1 ;;
                esac
            done
            ;;
        10) # 退出脚本
            exit 0
            ;;
        *) echo -e "${RED}无效选择，请重新输入！${NC}"; sleep 1 ;;
    esac
done
