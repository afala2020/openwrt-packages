#!/bin/bash

# 保存原始终端设置
original_stty=$(stty -g)

# 设置终端以正确处理退格键和删除键
stty erase ^H 2>/dev/null
stty erase ^? 2>/dev/null
stty intr ^C

# 定义颜色和格式
RED="\033[1;31;1m"
GREEN="\033[1;32;1m"
YELLOW="\033[1;33;1m"
RESET="\033[0m"
BOLD="\033[1m"

# 随机选择主界面颜色（绿或黄）
COLORS=("$GREEN" "$YELLOW")
MAIN_COLOR=${COLORS[$RANDOM % 2]}

# 全局数组存储找到的源码目录
found_dirs=()

# 错误处理函数
error() {
    echo -e "${RED}错误: $1${RESET}" >&2
    read -p "按任意键继续..."
}

# 显示主界面
show_main_menu() {
    clear
    echo -e "${MAIN_COLOR}***********************************************************************************"
    echo -e "------------------------------自编译OpenWRT固件脚本--------------------------------"
    echo -e "***********************************************************************************"
    echo -e "* 1.安装Openwrt所需依赖环境"
    echo -e "* 2.查询Python版本或降级Python"
    echo -e "* 3.下载Openwrt源码"
    echo -e "* 4.开始编译OpenWRT固件"
    echo -e "* 5."
    echo -e "* 6."
    echo -e "* 7."
    echo -e "* 8."
    echo -e "* 9."
    echo -e "* 10.退出脚本"
    echo -e "***********************************************************************************${RESET}"
}

# 安装依赖环境菜单
install_deps_menu() {
    while true; do
        clear
        echo -e "${MAIN_COLOR}***********************************************************************************"
        echo -e "------------------------------自编译OpenWRT固件脚本--------------------------------"
        echo -e "***********************************************************************************"
        echo -e "1.一键安装Openwrt编译所需全部依赖包"
        echo -e "2.设置允许root用户编译(FORCE_UNSAFE_CONFIGURE=1)"
        echo -e "3.返回上一级界面"
        echo -e "4.退出脚本"
        echo -e "***********************************************************************************${RESET}"
        
        read -p "请选择操作 (1-4): " choice
        case $choice in
            1)
                echo -e "${GREEN}开始安装OpenWRT依赖环境...${RESET}"
                bash <(wget -qO- https://raw.githubusercontent.com/afala2020/openwrt-packages/refs/heads/main/yilai.sh)
                read -p "安装完成，按任意键返回..."
                ;;
            2)
                if grep -q "FORCE_UNSAFE_CONFIGURE=1" /etc/profile; then
                    echo -e "${GREEN}export FORCE_UNSAFE_CONFIGURE=1已在/etc/profile文件中，无需重复写入！${RESET}"
                else
                    echo 'export FORCE_UNSAFE_CONFIGURE=1' >> /etc/profile
                    source /etc/profile
                    echo -e "${GREEN}已将FORCE_UNSAFE_CONFIGURE=1写入/etc/profile，建议退出SSH重新登录！${RESET}"
                fi
                read -p "按任意键返回..."
                ;;
            3) return ;;
            4) exit 0 ;;
            *) error "无效选择" ;;
        esac
    done
}

# 显示Python版本
show_python_versions() {
    echo -e "${GREEN}当前Python版本: $(python -V 2>&1)${RESET}"
    echo -e "${GREEN}当前Python3版本: $(python3 -V 2>&1)${RESET}"
    read -p "按任意键返回..."
}

# 安装指定Python版本
install_python_version() {
    local version=$1
    local url="https://www.python.org/ftp/python/${version}/Python-${version}.tar.xz"
    local dir="/home/Python-${version}"
    
    echo -e "${GREEN}安装Python${version}...需要等待一会！${RESET}"
    sleep 5
    
    # 下载并编译
    cd /home || return
    rm -rf Python*
    if ! wget "$url"; then
        error "下载Python源码失败"
        return
    fi
    
    tar -Jxvf "Python-${version}.tar.xz" || {
        error "解压源码失败"
        return
    }
    rm -rf Python-*.tar.xz
    
    cd "$dir" || return
    ./configure --enable-optimizations || {
        error "配置失败"
        return
    }
    
    make altinstall -j$(nproc) || {
        error "编译失败"
        return
    }
    
    sleep 3
    cd /root || return
    rm -rf /home/Python*
    
    # 设置默认版本
    local minor=${version%.*}
    sudo update-alternatives --install /usr/bin/python python "/usr/local/bin/python${minor}" 300
    sudo update-alternatives --install /usr/bin/python3 python3 "/usr/local/bin/python${minor}" 300
    sudo update-alternatives --auto python
    sudo update-alternatives --auto python3
    
    # 显示新版本
    echo -e "${GREEN}当前Python版本: $(python -V 2>&1)${RESET}"
    echo -e "${GREEN}当前Python3版本: $(python3 -V 2>&1)${RESET}"
    read -p "安装完成，按任意键返回..."
}

# Python版本菜单
python_menu() {
    while true; do
        clear
        echo -e "${MAIN_COLOR}***********************************************************************************"
        echo -e "------------------------------自编译OpenWRT固件脚本--------------------------------"
        echo -e "***********************************************************************************"
        echo -e "1.检查Python版本"
        echo -e "2.安装指定的Python版本"
        echo -e "3.返回上一级界面"
        echo -e "4.退出本脚本"
        echo -e "***********************************************************************************${RESET}"
        
        read -p "请选择操作 (1-4): " choice
        case $choice in
            1) show_python_versions ;;
            2) python_version_menu ;;
            3) return ;;
            4) exit 0 ;;
            *) error "无效选择" ;;
        esac
    done
}

# Python版本选择菜单
python_version_menu() {
    while true; do
        clear
        echo -e "${MAIN_COLOR}***********************************************************************************"
        echo -e "------------------------------自编译OpenWRT固件脚本--------------------------------"
        echo -e "***********************************************************************************"
        echo -e "1.安装Python3.10.9,并设置为默认版本"
        echo -e "2.安装Python3.10.6,并设置为默认版本"
        echo -e "3.安装Python3.9.6,并设置为默认版本"
        echo -e "4.安装Python3.8.9,并设置为默认版本"
        echo -e "5.安装Python3.7.9,并设置为默认版本"
        echo -e "6.安装Python3.6.9,并设置为默认版本"
        echo -e "7.返回上一级界面"
        echo -e "8.退出本脚本"
        echo -e "***********************************************************************************${RESET}"
        
        read -p "请选择Python版本 (1-8): " choice
        case $choice in
            1) install_python_version "3.10.9" ;;
            2) install_python_version "3.10.6" ;;
            3) install_python_version "3.9.6" ;;
            4) install_python_version "3.8.9" ;;
            5) install_python_version "3.7.9" ;;
            6) install_python_version "3.6.9" ;;
            7) return ;;
            8) exit 0 ;;
            *) error "无效选择" ;;
        esac
    done
}

# 下载LEDE源码
download_lede() {
    local path=$1
    echo -e "${GREEN}开始下载LEDE源码到: $path${RESET}"
    git clone https://github.com/coolsnowwolf/lede "$path" || {
        error "下载LEDE源码失败"
        return
    }
    echo -e "${GREEN}LEDE源码已下载到: $path${RESET}"
    read -p "按任意键返回脚本主界面..."
}

# 下载ImmortalWRT源码
download_immortalwrt() {
    local path=$1
    local version=$2
    
    case $version in
        1)
            echo -e "${GREEN}开始下载immortalwrt-18.06k5.4源码到: $path${RESET}"
            git clone -b openwrt-18.06-k5.4 --single-branch https://github.com/immortalwrt/immortalwrt "$path/immortalwrt1806k54"
            ;;
        2)
            echo -e "${GREEN}开始下载immortalwrt-18.06源码到: $path${RESET}"
            git clone -b openwrt-18.06 --single-branch https://github.com/immortalwrt/immortalwrt "$path/immortalwrt1806"
            ;;
        3)
            echo -e "${GREEN}开始下载immortalwrt-21.02源码到: $path${RESET}"
            git clone -b openwrt-21.02 --single-branch https://github.com/immortalwrt/immortalwrt "$path/immortalwrt2102"
            ;;
        4)
            echo -e "${GREEN}开始下载immortalwrt-23.05源码到: $path${RESET}"
            git clone -b openwrt-23.05 --single-branch https://github.com/immortalwrt/immortalwrt "$path/immortalwrt2305"
            ;;
        5)
            echo -e "${GREEN}开始下载immortalwrt-24.10源码到: $path${RESET}"
            git clone -b openwrt-24.10 --single-branch https://github.com/immortalwrt/immortalwrt "$path/immortalwrt2410"
            ;;
        *)
            error "无效选择"
            return
            ;;
    esac
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}源码下载成功到: $path${RESET}"
    else
        error "下载源码失败"
    fi
    read -p "按任意键返回脚本主界面..."
}

# 源码下载菜单
source_download_menu() {
    while true; do
        clear
        echo -e "${MAIN_COLOR}***********************************************************************************"
        echo -e "------------------------------自编译OpenWRT固件脚本--------------------------------"
        echo -e "***********************************************************************************"
        echo -e "1.下载LEDE源码"
        echo -e "2.下载immortalwrt源码"
        echo -e "3.返回上一级界面"
        echo -e "4.退出本脚本"
        echo -e "***********************************************************************************${RESET}"
        echo -e "${GREEN}请将源码下载到/root或/home目录，否则无法编译！${RESET}"
        echo -e "${GREEN}当前所在的目录: $(pwd)${RESET}"
        
        read -p "请选择操作 (1-4): " choice
        case $choice in
            1) lede_download_menu ;;
            2) immortalwrt_download_menu ;;
            3) return ;;
            4) exit 0 ;;
            *) error "无效选择" ;;
        esac
    done
}

# LEDE下载菜单
lede_download_menu() {
    while true; do
        clear
        echo -e "${MAIN_COLOR}***********************************************************************************"
        echo -e "------------------------------自编译OpenWRT固件脚本--------------------------------"
        echo -e "***********************************************************************************"
        echo -e "1.将LEDE源码下载到当前目录下"
        echo -e "2.输入自定义，LEDE源码的下载路径"
        echo -e "3.返回上一级界面"
        echo -e "4.退出本脚本"
        echo -e "***********************************************************************************${RESET}"
        echo -e "${GREEN}请将源码下载到/root或/home目录，否则无法编译！${RESET}"
        echo -e "${GREEN}当前所在的目录: $(pwd)${RESET}"
        
        read -p "请选择操作 (1-4): " choice
        case $choice in
            1)
                download_lede "$(pwd)"
                ;;
            2)
                read -p "请输入LEDE源码的下载路径（绝对路径：/root或/home）: " custom_path
                if [ ! -d "$custom_path" ]; then
                    error "输入的路径不存在！"
                    continue
                fi
                download_lede "$custom_path"
                ;;
            3) return ;;
            4) exit 0 ;;
            *) error "无效选择" ;;
        esac
    done
}

# ImmortalWRT下载菜单
immortalwrt_download_menu() {
    while true; do
        clear
        echo -e "${MAIN_COLOR}***********************************************************************************"
        echo -e "------------------------------自编译OpenWRT固件脚本--------------------------------"
        echo -e "***********************************************************************************"
        echo -e "1.将源码下载到当前目录下"
        echo -e "2.输入自定义，源码下载路径"
        echo -e "3.返回上一级界面"
        echo -e "4.退出本脚本"
        echo -e "***********************************************************************************${RESET}"
        echo -e "${GREEN}请将源码下载到/root或/home目录，否则无法编译！${RESET}"
        echo -e "${GREEN}当前所在的目录: $(pwd)${RESET}"
        
        read -p "请选择操作 (1-4): " choice
        case $choice in
            1)
                custom_path=$(pwd)
                immortalwrt_version_menu "$custom_path"
                ;;
            2)
                read -p "请输入immortalwrt源码的下载路径（绝对路径：/root或/home）: " custom_path
                if [ ! -d "$custom_path" ]; then
                    error "输入的路径不存在！"
                    continue
                fi
                echo -e "${GREEN}immortalwrt源码将下载到: $custom_path${RESET}"
                immortalwrt_version_menu "$custom_path"
                ;;
            3) return ;;
            4) exit 0 ;;
            *) error "无效选择" ;;
        esac
    done
}

# ImmortalWRT版本选择菜单
immortalwrt_version_menu() {
    local path=$1
    
    while true; do
        clear
        echo -e "${MAIN_COLOR}***********************************************************************************"
        echo -e "------------------------------自编译OpenWRT固件脚本--------------------------------"
        echo -e "***********************************************************************************"
        echo -e "1.下载immortalwrt-18.06k5.4"
        echo -e "2.下载immortalwrt-18.06"
        echo -e "3.下载immortalwrt-21.02"
        echo -e "4.下载immortalwrt-23.05"
        echo -e "5.下载immortalwrt-24.10"
        echo -e "6.返回上一级界面"
        echo -e "7.退出本脚本"
        echo -e "***********************************************************************************${RESET}"
        echo -e "${GREEN}当前所在的目录: $path${RESET}"
        
        read -p "请选择版本 (1-7): " choice
        case $choice in
            [1-5])
                download_immortalwrt "$path" "$choice"
                return
                ;;
            6) return ;;
            7) exit 0 ;;
            *) error "无效选择" ;;
        esac
    done
}

# 查找OpenWRT源码目录
find_openwrt_dirs() {
    found_dirs=()
    
    # 搜索/root目录
    for dir in /root/*; do
        if [ -d "$dir" ]; then
            dirname=$(basename "$dir")
            # 使用不区分大小写的匹配
            if [[ $dirname =~ ^([lL][eE][dD][eE]|[iI][mM][mM][oO][rR][tT][aA][lL][wW][rR][tT]) ]]; then
                found_dirs+=("$dir")
            fi
        fi
    done
    
    # 搜索/home目录
    for dir in /home/*; do
        if [ -d "$dir" ]; then
            dirname=$(basename "$dir")
            if [[ $dirname =~ ^([lL][eE][dD][eE]|[iI][mM][mM][oO][rR][tT][aA][lL][wW][rR][tT]) ]]; then
                found_dirs+=("$dir")
            fi
        fi
    done
}

# 进入源码目录菜单
enter_source_dir_menu() {
    # 清空之前的结果
    found_dirs=()
    find_openwrt_dirs
    
    if [ ${#found_dirs[@]} -eq 0 ]; then
        error "当前系统未下载OpenWRT源码，请去下载源码！"
        return
    fi
    
    while true; do
        clear
        echo -e "${MAIN_COLOR}***********************************************************************************"
        echo -e "------------------------------自编译OpenWRT固件脚本--------------------------------"
        echo -e "***********************************************************************************"
        echo -e "当前系统已下载的OpenWRT源码有:"
        
        for i in "${!found_dirs[@]}"; do
            echo -e "$(($i+1)). 进入 $(basename "${found_dirs[$i]}") 源码目录"
        done
        
        local return_choice=$((${#found_dirs[@]}+1))
        local exit_choice=$((${#found_dirs[@]}+2))
        
        echo -e "${return_choice}. 返回上一级界面"
        echo -e "${exit_choice}. 退出本脚本"
        echo -e "***********************************************************************************${RESET}"
        echo -e "${GREEN}当前所在的目录: $(pwd)${RESET}"
        
        read -p "请选择要进入的目录 (1-${exit_choice}): " choice
        
        if [[ $choice =~ ^[0-9]+$ ]]; then
            if [[ $choice -ge 1 && $choice -le ${#found_dirs[@]} ]]; then
                cd "${found_dirs[$choice-1]}" || {
                    error "无法进入目录"
                    return
                }
                echo -e "${GREEN}已进入 $(basename "${found_dirs[$choice-1]}") 源码目录中${RESET}"
                echo -e "${GREEN}当前所在的源码目录: $(pwd)${RESET}"
                read -p "按任意键继续..."
                return
            elif [[ $choice -eq $return_choice ]]; then
                return
            elif [[ $choice -eq $exit_choice ]]; then
                exit 0
            else
                error "无效选择"
            fi
        else
            error "请输入数字"
        fi
    done
}

# 替换download.pl文件
replace_download_pl() {
    echo -e "${GREEN}当前所在的源码目录: $(pwd)${RESET}"
    
    read -p "是否将download.pl文件curl替换为wget？(y/n): " confirm
    if [ "$confirm" != "y" ]; then
        return
    fi
    
    if [ -f "./scripts/download.pl" ]; then
        # 检查是否在immortalwrt1806k54目录中
        if [[ $(pwd) == *"immortalwrt1806k54"* ]]; then
            sed -i 's/curl -f --connect-timeout 20 --retry 5 --location --insecure/wget --tries=2 --timeout=20 --no-check-certificate --output-document=-/g' ./scripts/download.pl
            sed -i 's/CURL_OPTIONS/WGET_OPTIONS/g' ./scripts/download.pl
        else
            sed -i 's/curl -f --connect-timeout 20 --retry 5 --location/wget --tries=2 --timeout=20 --output-document=-/g' ./scripts/download.pl
            sed -i 's/--insecure/--no-check-certificate/g' ./scripts/download.pl
            sed -i 's/CURL_OPTIONS/WGET_OPTIONS/g' ./scripts/download.pl
        fi
        echo -e "${GREEN}已将curl替换成wget${RESET}"
    else
        error "未找到download.pl文件"
    fi
    read -p "按任意键返回..."
}

# 添加kenzok8插件库
add_kenzok8_feed() {
    echo -e "${GREEN}当前所在的源码目录: $(pwd)${RESET}"
    
    read -p "是否添加kenzok8第三方插件库到源码中？(y/n): " confirm
    if [ "$confirm" != "y" ]; then
        return
    fi
    
    if [ -f "./feeds.conf.default" ]; then
        if ! grep -q "kenzok8" "./feeds.conf.default"; then
            echo "src-git kenzo https://github.com/kenzok8/openwrt-packages" >> feeds.conf.default
            echo "src-git smpackageX https://github.com/kenzok8/small-package" >> feeds.conf.default
            echo -e "${GREEN}已将kenzok8插件库添加到feeds.conf.default文件！${RESET}"
        else
            echo -e "${GREEN}kenzok8插件库已存在${RESET}"
        fi
        
        echo -e "${GREEN}开始执行update和install，请等待一会！${RESET}"
        ./scripts/feeds update -a
        ./scripts/feeds install -a
    else
        error "未找到feeds.conf.default文件"
    fi
    read -p "按任意键返回..."
}

# 获取Makefile版本信息
get_makefile_version() {
    local makefile=$1
    local pkg_version=$(grep "PKG_VERSION:=" "$makefile" | cut -d= -f2)
    local pkg_release=$(grep "PKG_RELEASE:=" "$makefile" | cut -d= -f2)
    echo "$pkg_version $pkg_release"
}

# 升级或安装插件
upgrade_plugin() {
    local plugin_name=$1
    local makefile_path=$2
    local remote_url=$3
    local branch=$4
    
    # 检查插件是否存在
    if [ ! -f "$makefile_path" ]; then
        read -p "${plugin_name}插件不存在，是否下载安装？(y/n): " confirm
        if [ "$confirm" != "y" ]; then
            return
        fi
        
        # 执行下载安装命令
        eval "${5}"
        
        if [ -f "$makefile_path" ]; then
            local versions=($(get_makefile_version "$makefile_path"))
            echo -e "${GREEN}当前源码中${plugin_name}插件的版本: ${versions[0]}-${versions[1]}${RESET}"
            echo -e "${GREEN}${plugin_name}插件源码已下载，请返回执行update和install${RESET}"
        else
            error "下载${plugin_name}插件失败"
        fi
        read -p "按任意键返回..."
        return
    fi
    
    # 获取本地版本
    local local_versions=($(get_makefile_version "$makefile_path"))
    echo -e "${GREEN}当前源码中${plugin_name}插件的版本: ${local_versions[0]}-${local_versions[1]}${RESET}"
    
    # 获取远程版本
    local remote_makefile=$(mktemp)
    wget -qO "$remote_makefile" "${remote_url}" || {
        error "获取远程${plugin_name}插件信息失败"
        return
    }
    
    local remote_versions=($(get_makefile_version "$remote_makefile"))
    rm -f "$remote_makefile"
    
    echo -e "${GREEN}远程仓库中${plugin_name}插件的最新版本: ${remote_versions[0]}-${remote_versions[1]}${RESET}"
    
    # 版本比较
    if [ "${local_versions[0]}" = "${remote_versions[0]}" ] && [ "${local_versions[1]}" = "${remote_versions[1]}" ]; then
        echo -e "${GREEN}${plugin_name}插件已是最新版本，无需升级!${RESET}"
        read -p "按任意键返回..."
        return
    fi
    
    # 版本升级
    read -p "是否将${plugin_name}插件升级到最新版本？(y/n): " confirm
    if [ "$confirm" != "y" ]; then
        return
    fi
    
    # 执行升级命令
    eval "${5}"
    
    if [ -f "$makefile_path" ]; then
        local new_versions=($(get_makefile_version "$makefile_path"))
        echo -e "${GREEN}升级后源码中${plugin_name}插件的版本: ${new_versions[0]}-${new_versions[1]}${RESET}"
        echo -e "${GREEN}${plugin_name}插件已升级到最新版本，请返回执行update和install${RESET}"
    else
        error "升级${plugin_name}插件失败"
    fi
    read -p "按任意键返回..."
}

# samba4版本选择菜单
samba4_version_menu() {
    local path=$1
    local action=$2
    
    while true; do
        clear
        if [ "$action" = "install" ]; then
            echo -e "${MAIN_COLOR}***********************************************************************************"
            echo -e "------------------------------自编译OpenWRT固件脚本--------------------------------"
            echo -e "***********************************************************************************"
            echo -e "1.下载samba4-v4.18.8版本"
            echo -e "2.下载samba4-v4.14.14版本"
            echo -e "3.下载samba4-v4.14.12版本"
            echo -e "4.返回上一级界面"
            echo -e "5.退出本脚本"
            echo -e "***********************************************************************************${RESET}"
        else
            echo -e "${MAIN_COLOR}***********************************************************************************"
            echo -e "------------------------------自编译OpenWRT固件脚本--------------------------------"
            echo -e "***********************************************************************************"
            echo -e "1.升级samba4插件到最新版本"
            echo -e "2.替换为samba4-v4.18.8版本"
            echo -e "3.替换为samba4-v4.14.14版本"
            echo -e "4.替换为samba4-v4.14.12版本"
            echo -e "5.返回上一级界面"
            echo -e "6.退出本脚本"
            echo -e "***********************************************************************************${RESET}"
        fi
        echo -e "${GREEN}当前所在的源码目录: $path${RESET}"
        
        read -p "请选择操作: " choice
        case $choice in
            1)
                if [ "$action" = "install" ]; then
                    rm -rf ./feeds/packages/net/samba4
                    git clone -b 4.18.8 https://github.com/aige168/samba4 ./feeds/packages/net/samba4
                    echo -e "${GREEN}samba4-v4.18.8版本已下载${RESET}"
                else
                    rm -rf ./feeds/packages/net/samba4
                    git clone -b main https://github.com/aige168/samba4 ./feeds/packages/net/samba4
                    echo -e "${GREEN}samba4插件已更新到最新版本${RESET}"
                fi
                read -p "按任意键返回..."
                return
                ;;
            2)
                if [ "$action" = "install" ]; then
                    rm -rf ./feeds/packages/net/samba4
                    git clone -b 4.14.14 https://github.com/aige168/samba4 ./feeds/packages/net/samba4
                    echo -e "${GREEN}samba4-v4.14.14版本已下载${RESET}"
                else
                    rm -rf ./feeds/packages/net/samba4
                    git clone -b 4.18.8 https://github.com/aige168/samba4 ./feeds/packages/net/samba4
                    echo -e "${GREEN}已替换为samba4-v4.18.8版本${RESET}"
                fi
                read -p "按任意键返回..."
                return
                ;;
            3)
                if [ "$action" = "install" ]; then
                    rm -rf ./feeds/packages/net/samba4
                    git clone -b 4.14.12 https://github.com/aige168/samba4 ./feeds/packages/net/samba4
                    echo -e "${GREEN}samba4-v4.14.12版本已下载${RESET}"
                else
                    rm -rf ./feeds/packages/net/samba4
                    git clone -b 4.14.14 https://github.com/aige168/samba4 ./feeds/packages/net/samba4
                    echo -e "${GREEN}已替换为samba4-v4.14.14版本${RESET}"
                fi
                read -p "按任意键返回..."
                return
                ;;
            4)
                if [ "$action" = "install" ]; then
                    return
                else
                    rm -rf ./feeds/packages/net/samba4
                    git clone -b 4.14.12 https://github.com/aige168/samba4 ./feeds/packages/net/samba4
                    echo -e "${GREEN}已替换为samba4-v4.14.12版本${RESET}"
                    read -p "按任意键返回..."
                    return
                fi
                ;;
            *)
                if [ "$action" = "install" ]; then
                    case $choice in
                        4) return ;;
                        5) exit 0 ;;
                        *) error "无效选择" ;;
                    esac
                else
                    case $choice in
                        5) return ;;
                        6) exit 0 ;;
                        *) error "无效选择" ;;
                    esac
                fi
                ;;
        esac
    done
}

# 处理samba4插件
handle_samba4() {
    local makefile_path="./feeds/packages/net/samba4/Makefile"
    
    # 检查插件是否存在
    if [ ! -f "$makefile_path" ]; then
        read -p "samba4插件不存在，是否下载安装？(y/n): " confirm
        if [ "$confirm" != "y" ]; then
            return
        fi
        samba4_version_menu "$(pwd)" "install"
        return
    fi
    
    # 获取本地版本
    local local_versions=($(get_makefile_version "$makefile_path"))
    echo -e "${GREEN}当前源码中samba4插件的版本: ${local_versions[0]}-${local_versions[1]}${RESET}"
    
    # 获取远程版本
    local remote_makefile=$(mktemp)
    wget -qO "$remote_makefile" "https://raw.githubusercontent.com/aige168/samba4/main/Makefile" || {
        error "获取远程samba4插件信息失败"
        return
    }
    
    local remote_versions=($(get_makefile_version "$remote_makefile"))
    rm -f "$remote_makefile"
    
    echo -e "${GREEN}远程仓库中samba4插件的最新版本: ${remote_versions[0]}-${remote_versions[1]}${RESET}"
    
    # 版本比较
    if [ "${local_versions[0]}" = "${remote_versions[0]}" ] && [ "${local_versions[1]}" = "${remote_versions[1]}" ]; then
        echo -e "${GREEN}samba4插件已是最新版本，但可以替换为其他版本${RESET}"
        read -p "是否进入samba4替换界面？(y/n): " confirm
        if [ "$confirm" = "y" ]; then
            samba4_version_menu "$(pwd)" "upgrade"
        fi
        return
    fi
    
    # 版本升级
    read -p "是否升级/替换samba4插件？(y/n): " confirm
    if [ "$confirm" != "y" ]; then
        return
    fi
    
    samba4_version_menu "$(pwd)" "upgrade"
}

# 插件安装升级菜单
plugins_menu() {
    while true; do
        clear
        echo -e "${MAIN_COLOR}***********************************************************************************"
        echo -e "------------------------------自编译OpenWRT固件脚本--------------------------------"
        echo -e "***********************************************************************************"
        echo -e "1.安装或升级accesscontrol插件"
        echo -e "2.安装或升级argon主题插件"
        echo -e "3.安装或升级ddnsto插件"
        echo -e "4.安装或升级samba4插件"
        echo -e "5.安装或升级serverchan插件"
        echo -e "6.安装或升级pushbot插件"
        echo -e "7.安装或升级zerotier插件"
        echo -e "8.返回上一级界面"
        echo -e "9.退出本脚本"
        echo -e "***********************************************************************************${RESET}"
        echo -e "${GREEN}当前所在的源码目录: $(pwd)${RESET}"
        
        read -p "请选择操作 (1-9): " choice
        case $choice in
            1)
                upgrade_plugin "accesscontrol" \
                    "./feeds/luci/applications/luci-app-accesscontrol/Makefile" \
                    "https://raw.githubusercontent.com/aige168/luci-app-accesscontrol/main/Makefile" \
                    "main" \
                    "find . -type d -name \"*accesscontrol\" -exec rm -rf {} \; ; \
                     git clone https://github.com/aige168/luci-app-accesscontrol.git ./feeds/luci/applications/luci-app-accesscontrol"
                ;;
            2)
                upgrade_plugin "argon" \
                    "./feeds/luci/themes/luci-theme-argon/Makefile" \
                    "https://raw.githubusercontent.com/jerrykuku/luci-theme-argon/master/Makefile" \
                    "master" \
                    "find . -type d -name \"*argon\" -exec rm -rf {} \; ; \
                     git clone -b master https://github.com/jerrykuku/luci-theme-argon.git ./feeds/luci/themes/luci-theme-argon"
                ;;
            3)
                upgrade_plugin "ddnsto" \
                    "./package/luci-app-ddnsto/Makefile" \
                    "https://raw.githubusercontent.com/linkease/nas-packages-luci/main/luci/luci-app-ddnsto/Makefile" \
                    "main" \
                    "find . -type d -name \"*ddnsto*\" -exec rm -rf {} \; ; \
                     git clone -b main https://github.com/linkease/nas-packages-luci.git package/luci-app-ddnstoX ; \
                     git clone -b master https://github.com/linkease/nas-packages.git package/luci-app-ddnsto"
                ;;
            4)
                handle_samba4
                ;;
            5)
                upgrade_plugin "serverchan" \
                    "./feeds/luci/applications/luci-app-serverchan/Makefile" \
                    "https://raw.githubusercontent.com/tty228/luci-app-wechatpush/openwrt-18.06/Makefile" \
                    "openwrt-18.06" \
                    "find . -type d -name \"*-serverchan\" -exec rm -rf {} \; ; \
                     git clone -b openwrt-18.06 https://github.com/tty228/luci-app-wechatpush.git ./feeds/luci/applications/luci-app-serverchan"
                ;;
            6)
                upgrade_plugin "pushbot" \
                    "./feeds/luci/applications/luci-app-wechatpush/Makefile" \
                    "https://raw.githubusercontent.com/tty228/luci-app-wechatpush/master/Makefile" \
                    "master" \
                    "find . -type d -name \"*-wechatpush\" -exec rm -rf {} \; ; \
                     git clone -b master https://github.com/tty228/luci-app-wechatpush.git feeds/luci/applications/luci-app-wechatpush"
                ;;
            7)
                upgrade_plugin "zerotier" \
                    "./feeds/packages/net/zerotier/Makefile" \
                    "https://raw.githubusercontent.com/aige168/zerotier/main/Makefile" \
                    "main" \
                    "rm -rf ./feeds/packages/net/zerotier ; \
                     git clone https://github.com/aige168/zerotier ./feeds/packages/net/zerotier"
                ;;
            8) return ;;
            9) exit 0 ;;
            *) error "无效选择" ;;
        esac
    done
}

# 替换固件设置
replace_firmware_settings() {
    echo -e "${GREEN}当前所在的源码目录: $(pwd)${RESET}"
    
    case $1 in
        lede)
            if [[ $(pwd) != *"lede"* ]]; then
                error "当前路径未在LEDE源码目录中，请返回重新选择源码目录！"
                read -p "按任意键返回..."
                return
            fi
            
            # 修改固件名称
            read -p "请输入修改后的固件名称(回车直接设为NEWIFI): " firmware_name
            if [ -z "$firmware_name" ]; then
                firmware_name="NEWIFI"
            fi
            sed -i "s/LEDE/$firmware_name/g" package/base-files/luci2/bin/config_generate
            echo -e "${GREEN}已将固件名称修改为: $firmware_name${RESET}"
            
            # 修改IP地址
            while true; do
                read -p "请输入修改后的固件IP地址(回车直接设为192.168.99.1): " ip_address
                if [ -z "$ip_address" ]; then
                    ip_address="192.168.99.1"
                fi
                
                if [[ $ip_address =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                    sed -i "s/192.168.1.1/$ip_address/g" package/base-files/luci2/bin/config_generate
                    echo -e "${GREEN}已将固件IP地址修改为: $ip_address${RESET}"
                    break
                else
                    error "IP地址错误，请重新输入！"
                fi
            done
            
            # 设置主题
            sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' ./feeds/luci/collections/luci-light/Makefile
            sed -i 's/CONFIG_PACKAGE_luci-theme-bootstrap=y/CONFIG_PACKAGE_luci-theme-bootstrap=n/g' ./.config
            echo -e "${GREEN}已将主题bootstrap修改为argon！${RESET}"
            
            # 设置时区
            sed -i 's/UTC/CST-8/g' package/base-files/luci2/bin/config_generate
            echo -e "${GREEN}已将UTC时区修改为CST-8时区！${RESET}"
            
            # 设置Nas名称
            sed -i 's/"NAS"/"网络存储"/g' `grep "NAS" -rl ./`
            echo -e "${GREEN}已将Nas名称修改为网络存储！${RESET}"
            ;;
            
        immortalwrt_old)
            if [[ $(pwd) != *"immortalwrt1806"* ]] && [[ $(pwd) != *"immortalwrt1806k54"* ]]; then
                error "当前路径未在immortalwrt1806或immortalwrt1806k54源码目录中，请返回重新选择源码目录！"
                read -p "按任意键返回..."
                return
            fi
            
            # 修改固件名称
            read -p "请输入修改后的固件名称(回车直接设为NEWIFI): " firmware_name
            if [ -z "$firmware_name" ]; then
                firmware_name="NEWIFI"
            fi
            sed -i "s/ImmortalWrt/$firmware_name/g" package/base-files/files/bin/config_generate
            echo -e "${GREEN}已将固件名称修改为: $firmware_name${RESET}"
            
            # 修改IP地址
            while true; do
                read -p "请输入修改后的固件IP地址(回车直接设为192.168.99.1): " ip_address
                if [ -z "$ip_address" ]; then
                    ip_address="192.168.99.1"
                fi
                
                if [[ $ip_address =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                    sed -i "s/192.168.1.1/$ip_address/g" package/base-files/files/bin/config_generate
                    echo -e "${GREEN}已将固件IP地址修改为: $ip_address${RESET}"
                    break
                else
                    error "IP地址错误，请重新输入！"
                fi
            done
            
            # 设置主题
            sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' ./feeds/luci/collections/luci/Makefile
            sed -i 's/CONFIG_PACKAGE_luci-theme-bootstrap=y/CONFIG_PACKAGE_luci-theme-bootstrap=n/g' ./.config
            echo -e "${GREEN}已将主题bootstrap修改为argon！${RESET}"
            
            # 设置时区
            sed -i 's/UTC/CST-8/g' package/base-files/files/bin/config_generate
            echo -e "${GREEN}已将UTC时区修改为CST-8时区！${RESET}"
            
            # 设置Nas名称
            sed -i 's/"NAS"/"网络存储"/g' `grep "NAS" -rl ./`
            echo -e "${GREEN}已将Nas名称修改为网络存储！${RESET}"
            ;;
            
        immortalwrt_new)
            if [[ $(pwd) != *"immortalwrt2102"* ]] && [[ $(pwd) != *"immortalwrt2305"* ]] && [[ $(pwd) != *"immortalwrt2410"* ]]; then
                error "当前路径未在immortalwrt2102、immortalwrt2305、immortalwrt2410源码目录中，请返回重新选择源码目录！"
                read -p "按任意键返回..."
                return
            fi
            
            # 修改固件名称
            read -p "请输入修改后的固件名称(回车直接设为NEWIFI): " firmware_name
            if [ -z "$firmware_name" ]; then
                firmware_name="NEWIFI"
            fi
            sed -i "s/ImmortalWrt/$firmware_name/g" package/base-files/files/bin/config_generate
            echo -e "${GREEN}已将固件名称修改为: $firmware_name${RESET}"
            
            # 修改IP地址
            while true; do
                read -p "请输入修改后的固件IP地址(回车直接设为192.168.99.1): " ip_address
                if [ -z "$ip_address" ]; then
                    ip_address="192.168.99.1"
                fi
                
                if [[ $ip_address =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                    sed -i "s/192.168.1.1/$ip_address/g" package/base-files/files/bin/config_generate
                    echo -e "${GREEN}已将固件IP地址修改为: $ip_address${RESET}"
                    break
                else
                    error "IP地址错误，请重新输入！"
                fi
            done
            
            # 设置主题
            sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' ./feeds/luci/collections/luci-light/Makefile
            sed -i 's/CONFIG_PACKAGE_luci-theme-bootstrap=y/CONFIG_PACKAGE_luci-theme-bootstrap=n/g' ./.config
            echo -e "${GREEN}已将主题bootstrap修改为argon！${RESET}"
            
            # 设置时区
            sed -i 's/UTC/CST-8/g' package/base-files/files/bin/config_generate
            echo -e "${GREEN}已将UTC时区修改为CST-8时区！${RESET}"
            
            # 设置Nas名称
            sed -i 's/"NAS"/"网络存储"/g' `grep "NAS" -rl ./`
            echo -e "${GREEN}已将Nas名称修改为网络存储！${RESET}"
            ;;
    esac
    
    echo -e "${GREEN}所有参数全部修改完成！${RESET}"
    read -p "按任意键返回..."
}

# 固件设置菜单
firmware_settings_menu() {
    while true; do
        clear
        echo -e "${MAIN_COLOR}***********************************************************************************"
        echo -e "------------------------------自编译OpenWRT固件脚本--------------------------------"
        echo -e "***********************************************************************************"
        echo -e "1.LEDE版源码一键修改(固件名称/IP地址/主题/CST-8时区/Nas名称)"
        echo -e "2.immortalwrt1806版源码一键修改(固件名称/IP地址/主题/CST-8时区/Nas名称)"
        echo -e "3.immortalwrt2102及以上版本源码一键修改(固件名称/IP地址/主题/CST-8时区/Nas名称)"
        echo -e "4.返回上一级"
        echo -e "5.退出本脚本"
        echo -e "***********************************************************************************${RESET}"
        echo -e "${GREEN}当前所在的源码目录: $(pwd)${RESET}"
        
        read -p "请选择操作 (1-5): " choice
        case $choice in
            1) replace_firmware_settings "lede" ;;
            2) replace_firmware_settings "immortalwrt_old" ;;
            3) replace_firmware_settings "immortalwrt_new" ;;
            4) return ;;
            5) exit 0 ;;
            *) error "无效选择" ;;
        esac
    done
}

# 编译过程菜单
compile_menu() {
    while true; do
        clear
        echo -e "${MAIN_COLOR}***********************************************************************************"
        echo -e "------------------------------自编译OpenWRT固件脚本--------------------------------"
        echo -e "***********************************************************************************"
        echo -e "1.进入OpenWRT源码目录"
        echo -e "2.是否将download.pl文件curl替换为wget"
        echo -e "3.是否添加kenzok8第三方插件库"
        echo -e "4.执行update和install"
        echo -e "5.是否升级/安装(accesscontrol/argon/ddnsto/samba4/serverchan/pushbot/zerotier)"
        echo -e "6.再次执行update和install"
        echo -e "7.执行make menuconfig"
        echo -e "8.替换固件名称/主题/IP地址等"
        echo -e "9.执行make download下载DL"
        echo -e "10.执行make V=s -j线程数"
        echo -e "11.返回上一级界面"
        echo -e "12.退出本脚本"
        echo -e "***********************************************************************************${RESET}"
        echo -e "${GREEN}当前所在的目录: $(pwd)${RESET}"
        
        read -p "请选择操作 (1-12): " choice
        case $choice in
            1) enter_source_dir_menu ;;
            2) replace_download_pl ;;
            3) add_kenzok8_feed ;;
            4)
                echo -e "${GREEN}执行update和install...${RESET}"
                ./scripts/feeds update -a
                ./scripts/feeds install -a
                read -p "操作完成，按任意键返回..."
                ;;
            5) plugins_menu ;;
            6)
                echo -e "${GREEN}再次执行update和install...${RESET}"
                ./scripts/feeds update -a
                ./scripts/feeds install -a
                read -p "操作完成，按任意键返回..."
                ;;
            7)
                echo -e "${GREEN}执行make menuconfig，请自行选择架构和需要安装的插件！${RESET}"
                sleep 2
                make menuconfig
                read -p "操作完成，按任意键返回..."
                ;;
            8) firmware_settings_menu ;;
            9)
                if [[ $(pwd) == *"lede"* ]] || [[ $(pwd) == *"immortalwrt"* ]]; then
                    echo -e "${GREEN}执行make download，开始下载DL文件！${RESET}"
                    make download V=s -j8
                    read -p "DL文件已下载1次，是否第2次下载？(y/n): " confirm
                    if [ "$confirm" = "y" ]; then
                        make download V=s -j1
                    fi
                else
                    error "当前路径未在OpenWRT源码目录中，请返回选择进入源码目录！"
                    read -p "按任意键返回..."
                fi
                ;;
            10)
                if [[ $(pwd) == *"lede"* ]] || [[ $(pwd) == *"immortalwrt"* ]]; then
                    echo -e "${GREEN}开始编译固件，大约需要1-3小时！${RESET}"
                    read -p "请输入编译使用的线程数(1-32): " threads
                    if [[ $threads =~ ^[0-9]+$ ]] && [ $threads -ge 1 ] && [ $threads -le 32 ]; then
                        echo -e "${GREEN}开始使用make V=s -j$threads编译固件！${RESET}"
                        make V=s -j$threads
                        if [ $? -eq 0 ]; then
                            firmware_path=$(find bin -name "*sysupgrade.bin" 2>/dev/null | head -1)
                            if [ -n "$firmware_path" ]; then
                                echo -e "${GREEN}固件编译成功，固件文件在: $(pwd)/$firmware_path${RESET}"
                            else
                                echo -e "${GREEN}固件编译成功，但未找到固件文件${RESET}"
                            fi
                        else
                            error "编译报错或失败，请手动检查错误！"
                        fi
                    else
                        error "无效的线程数，请输入1-32之间的数字"
                    fi
                    read -p "按任意键返回..."
                else
                    error "当前路径未在OpenWRT源码目录中，请返回选择进入源码目录！"
                    read -p "按任意键返回..."
                fi
                ;;
            11) return ;;
            12) exit 0 ;;
            *) error "无效选择" ;;
        esac
    done
}

# 主循环
while true; do
    show_main_menu
    read -p "请选择相应的编号(1-10): " main_choice
    
    case $main_choice in
        1) install_deps_menu ;;
        2) python_menu ;;
        3) source_download_menu ;;
        4) compile_menu ;;
        10) break ;;
        *) error "无效选择" ;;
    esac
done

# 恢复原始终端设置
stty "$original_stty"
echo -e "${GREEN}已退出脚本，返回命令行终端${RESET}"
exit 0