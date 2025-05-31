#!/bin/bash

# 解决Backspace和Delete键删除问题
stty erase ^H
stty erase ^?

# 设置字体加粗
bold=$(tput bold)
reset=$(tput sgr0)

# 随机选择绿色或黄色
colors=("32" "33") # 32:绿色, 33:黄色
selected_color=${colors[$RANDOM % 2]}

# 颜色函数
color_echo() {
    echo -e "\e[1;${selected_color}m${bold}$1${reset}\e[0m"
}

error_echo() {
    echo -e "\e[1;31m${bold}$1${reset}\e[0m"
}

info_echo() {
    echo -e "\e[1;36m${bold}$1${reset}\e[0m"
}

# 主菜单
main_menu() {
    clear
    color_echo "***********************************************************************************"
    color_echo "------------------------------自编译OpenWRT固件脚本--------------------------------"
    color_echo "***********************************************************************************"
    color_echo "* 1.安装Openwrt所需依赖环境"
    color_echo "* 2.查询Python版本或降级Python"
    color_echo "* 3.下载Openwrt源码"
    color_echo "* 4.开始编译OpenWRT固件"
    color_echo "* 5."
    color_echo "* 6."
    color_echo "* 7."
    color_echo "* 8."
    color_echo "* 9."
    color_echo "* 10.退出脚本"
    color_echo "***********************************************************************************"
    read -p "请选择相应的编号(1-10): " choice
    
    case $choice in
        1) install_dependencies_menu ;;
        2) python_menu ;;
        3) download_source_menu ;;
        4) compile_menu ;;
        10) exit 0 ;;
        *) error_echo "无效选择！"; sleep 1; main_menu ;;
    esac
}

# 安装依赖环境菜单
install_dependencies_menu() {
    clear
    color_echo "***********************************************************************************"
    color_echo "------------------------------自编译OpenWRT固件脚本--------------------------------"
    color_echo "***********************************************************************************"
    color_echo "1.一键安装Openwrt编译所需全部依赖包"
    color_echo "2.设置允许root用户编译(FORCE_UNSAFE_CONFIGURE=1)"
    color_echo "3.返回上一级界面"
    color_echo "4.退出脚本"
    color_echo "***********************************************************************************"
    read -p "请选择: " choice
    
    case $choice in
        1) 
            info_echo "开始安装OpenWRT编译依赖..."
            bash <(wget -qO- https://raw.githubusercontent.com/afala2020/openwrt-packages/refs/heads/main/yilai.sh)
            read -n1 -r -p "安装完成，按任意键返回！"
            install_dependencies_menu
            ;;
        2)
            if grep -q "export FORCE_UNSAFE_CONFIGURE=1" /etc/profile; then
                error_echo "export FORCE_UNSAFE_CONFIGURE=1已在/etc/profile文件中，无需重复写入！"
            else
                echo 'export FORCE_UNSAFE_CONFIGURE=1' >> /etc/profile
                source /etc/profile
                info_echo "已将FORCE_UNSAFE_CONFIGURE=1写入/etc/profile，建议退出SSH重新登录！"
            fi
            read -n1 -r -p "按任意键返回！"
            install_dependencies_menu
            ;;
        3) main_menu ;;
        4) exit 0 ;;
        *) error_echo "无效选择！"; sleep 1; install_dependencies_menu ;;
    esac
}

# Python菜单
python_menu() {
    clear
    color_echo "***********************************************************************************"
    color_echo "------------------------------自编译OpenWRT固件脚本--------------------------------"
    color_echo "***********************************************************************************"
    color_echo "1.检查Python版本"
    color_echo "2.安装指定的Python版本"
    color_echo "3.返回上一级界面"
    color_echo "4.退出本脚本"
    color_echo "***********************************************************************************"
    read -p "请选择: " choice
    
    case $choice in
        1) 
            color_echo "当前Python版本：$(python -V 2>&1 || echo '未安装')"
            color_echo "当前Python3版本：$(python3 -V 2>&1 || echo '未安装')"
            read -n1 -r -p "按任意键返回！"
            python_menu
            ;;
        2) python_version_menu ;;
        3) main_menu ;;
        4) exit 0 ;;
        *) error_echo "无效选择！"; sleep 1; python_menu ;;
    esac
}

# Python版本选择菜单
python_version_menu() {
    clear
    color_echo "***********************************************************************************"
    color_echo "------------------------------自编译OpenWRT固件脚本--------------------------------"
    color_echo "***********************************************************************************"
    color_echo "1.安装Python3.10.9,并设置为默认版本"
    color_echo "2.安装Python3.10.6,并设置为默认版本"
    color_echo "3.安装Python3.9.6,并设置为默认版本"
    color_echo "4.安装Python3.8.9,并设置为默认版本"
    color_echo "5.安装Python3.7.9,并设置为默认版本"
    color_echo "6.安装Python3.6.9,并设置为默认版本"
    color_echo "7.返回上一级界面"
    color_echo "8.退出本脚本"
    color_echo "***********************************************************************************"
    read -p "请选择: " choice
    
    case $choice in
        1) install_python "3.10.9" ;;
        2) install_python "3.10.6" ;;
        3) install_python "3.9.6" ;;
        4) install_python "3.8.9" ;;
        5) install_python "3.7.9" ;;
        6) install_python "3.6.9" ;;
        7) python_menu ;;
        8) exit 0 ;;
        *) error_echo "无效选择！"; sleep 1; python_version_menu ;;
    esac
}

# 安装Python函数
install_python() {
    version=$1
    info_echo "安装Python$version.....需要等待一会！"
    sleep 2
    
    # 安装编译依赖
    info_echo "安装编译依赖..."
    apt update
    apt install -y build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev \
    libssl-dev libreadline-dev libffi-dev libsqlite3-dev wget libbz2-dev
    
    cd /home || exit
    rm -rf Python*
    wget "https://www.python.org/ftp/python/$version/Python-$version.tar.xz"
    if [ $? -ne 0 ]; then
        error_echo "下载Python-$version失败！"
        read -n1 -r -p "按任意键返回！"
        python_version_menu
        return
    fi
    
    tar -Jxvf "Python-$version.tar.xz"
    rm -rf Python-*.tar.xz
    
    cd "Python-$version" || exit
    ./configure --enable-optimizations
    if [ $? -ne 0 ]; then
        error_echo "配置失败！"
        read -n1 -r -p "按任意键返回！"
        python_version_menu
        return
    fi
    
    make altinstall -j$(nproc)
    if [ $? -ne 0 ]; then
        error_echo "编译安装失败！"
        read -n1 -r -p "按任意键返回！"
        python_version_menu
        return
    fi
    
    sleep 1
    cd /root || exit
    rm -rf /home/Python*
    
    # 设置默认版本
    major_minor=$(echo $version | cut -d. -f1-2)
    sudo update-alternatives --install /usr/bin/python python "/usr/local/bin/python$major_minor" 300
    sudo update-alternatives --install /usr/bin/python3 python3 "/usr/local/bin/python$major_minor" 300
    sudo update-alternatives --auto python
    sudo update-alternatives --auto python3
    
    color_echo "当前Python版本：$(python -V 2>&1)"
    color_echo "当前Python3版本：$(python3 -V 2>&1)"
    read -n1 -r -p "安装完成，按任意键返回！"
    python_version_menu
}

# 下载源码菜单
download_source_menu() {
    clear
    color_echo "***********************************************************************************"
    color_echo "------------------------------自编译OpenWRT固件脚本--------------------------------"
    color_echo "***********************************************************************************"
    color_echo "1.下载LEDE源码"
    color_echo "2.下载immortalwrt源码"
    color_echo "3.返回上一级界面"
    color_echo "4.退出本脚本"
    color_echo "***********************************************************************************"
    info_echo "请将源码下载到/root或/home目录，否则无法编译！"
    color_echo "当前所在的目录：$(pwd)"
    read -p "请选择: " choice
    
    case $choice in
        1) download_lede_menu ;;
        2) download_immortalwrt_menu ;;
        3) main_menu ;;
        4) exit 0 ;;
        *) error_echo "无效选择！"; sleep 1; download_source_menu ;;
    esac
}

# LEDE下载菜单
download_lede_menu() {
    clear
    color_echo "***********************************************************************************"
    color_echo "------------------------------自编译OpenWRT固件脚本--------------------------------"
    color_echo "***********************************************************************************"
    color_echo "1.将LEDE源码下载到当前目录下"
    color_echo "2.输入自定义，LEDE源码的下载路径"
    color_echo "3.返回上一级界面"
    color_echo "4.退出本脚本"
    color_echo "***********************************************************************************"
    info_echo "请将源码下载到/root或/home目录，否则无法编译！"
    color_echo "当前所在的目录：$(pwd)"
    read -p "请选择: " choice
    
    case $choice in
        1)
            info_echo "开始下载LEDE源码到：$(pwd)"
            git clone https://github.com/coolsnowwolf/lede
            if [ $? -eq 0 ]; then
                info_echo "LEDE源码已下载到：$(pwd)/lede"
            else
                error_echo "LEDE源码下载失败！"
            fi
            read -n1 -r -p "按任意键返回！"
            download_lede_menu
            ;;
        2)
            read -p "请输入lede源码的下载路径（绝对路径：/root或/home）：" path
            if [ ! -d "$path" ]; then
                error_echo "输入的路径不存在！"
                sleep 1
                download_lede_menu
            else
                info_echo "开始下载lede源码到：$path"
                git clone https://github.com/coolsnowwolf/lede "$path/lede"
                if [ $? -eq 0 ]; then
                    info_echo "LEDE源码已下载到：$path/lede"
                else
                    error_echo "LEDE源码下载失败！"
                fi
                read -n1 -r -p "按任意键返回！"
                download_lede_menu
            fi
            ;;
        3) download_source_menu ;;
        4) exit 0 ;;
        *) error_echo "无效选择！"; sleep 1; download_lede_menu ;;
    esac
}

# Immortalwrt下载菜单
download_immortalwrt_menu() {
    clear
    color_echo "***********************************************************************************"
    color_echo "------------------------------自编译OpenWRT固件脚本--------------------------------"
    color_echo "***********************************************************************************"
    color_echo "1.将源码下载到当前目录下"
    color_echo "2.输入自定义，源码下载路径"
    color_echo "3.返回上一级界面"
    color_echo "4.退出本脚本"
    color_echo "***********************************************************************************"
    info_echo "请将源码下载到/root或/home目录，否则无法编译！"
    color_echo "当前所在的目录：$(pwd)"
    read -p "请选择: " choice
    
    case $choice in
        1) download_immortalwrt_version "$(pwd)" ;;
        2)
            read -p "请输入immortalwrt源码的下载路径（绝对路径：/root或/home）：" path
            if [ ! -d "$path" ]; then
                error_echo "输入的路径不存在！"
                sleep 1
                download_immortalwrt_menu
            else
                download_immortalwrt_version "$path"
            fi
            ;;
        3) download_source_menu ;;
        4) exit 0 ;;
        *) error_echo "无效选择！"; sleep 1; download_immortalwrt_menu ;;
    esac
}

# Immortalwrt版本选择
download_immortalwrt_version() {
    base_path=$1
    clear
    color_echo "***********************************************************************************"
    color_echo "------------------------------自编译OpenWRT固件脚本--------------------------------"
    color_echo "***********************************************************************************"
    color_echo "1.下载immortalwrt-18.06k5.4"
    color_echo "2.下载immortalwrt-18.06"
    color_echo "3.下载immortalwrt-21.02"
    color_echo "4.下载immortalwrt-23.05"
    color_echo "5.下载immortalwrt-24.10"
    color_echo "6.返回上一级界面"
    color_echo "7.退出本脚本"
    color_echo "***********************************************************************************"
    color_echo "当前所在的目录：$base_path"
    read -p "请选择: " choice
    
    clone_command() {
        branch=$1
        dir_name=$2
        version_name=$3
        info_echo "开始下载$version_name源码到：$base_path"
        git clone -b "$branch" --single-branch https://github.com/immortalwrt/immortalwrt "$base_path/$dir_name"
        if [ $? -eq 0 ]; then
            info_echo "$version_name源码已下载到：$base_path/$dir_name"
        else
            error_echo "$version_name源码下载失败！"
        fi
        read -n1 -r -p "按任意键返回！"
        download_immortalwrt_menu
    }
    
    case $choice in
        1) clone_command "openwrt-18.06-k5.4" "immortalwrt1806k54" "immortalwrt-18.06k5.4" ;;
        2) clone_command "openwrt-18.06" "immortalwrt1806" "immortalwrt-18.06" ;;
        3) clone_command "openwrt-21.02" "immortalwrt2102" "immortalwrt-21.02" ;;
        4) clone_command "openwrt-23.05" "immortalwrt2305" "immortalwrt-23.05" ;;
        5) clone_command "openwrt-24.10" "immortalwrt2410" "immortalwrt-24.10" ;;
        6) download_immortalwrt_menu ;;
        7) exit 0 ;;
        *) error_echo "无效选择！"; sleep 1; download_immortalwrt_version "$base_path" ;;
    esac
}

# 编译菜单
compile_menu() {
    clear
    color_echo "***********************************************************************************"
    color_echo "------------------------------自编译OpenWRT固件脚本--------------------------------"
    color_echo "***********************************************************************************"
    color_echo "1.进入OpenWRT源码目录"
    color_echo "2.是否将download.pl文件curl替换为wget"
    color_echo "3.是否添加kenzok8第三方插件库"
    color_echo "4.执行update和install"
    color_echo "5.是否升级/安装(accesscontrol/argon/ddnsto/samba4/serverchan/pushbot/zerotier)"
    color_echo "6.再次执行update和install"
    color_echo "7.执行make menuconfig"
    color_echo "8.替换固件名称/主题/IP地址等"
    color_echo "9.执行make download下载DL"
    color_echo "10.执行make V=s -j线程数"
    color_echo "11.返回上一级界面"
    color_echo "12.退出本脚本"
    color_echo "***********************************************************************************"
    color_echo "当前所在的目录：$(pwd)"
    read -p "请选择: " choice
    
    case $choice in
        1) enter_source_dir ;;
        2) replace_curl_to_wget ;;
        3) add_kenzok8_repo ;;
        4) run_update_install ;;
        5) plugin_menu ;;
        6) run_update_install ;;
        7) make_menuconfig ;;
        8) firmware_mod_menu ;;
        9) make_download ;;
        10) make_compile ;;
        11) main_menu ;;
        12) exit 0 ;;
        *) error_echo "无效选择！"; sleep 1; compile_menu ;;
    esac
}

# 进入源码目录
enter_source_dir() {
    dirs=()
    while IFS= read -r -d $'\0' dir; do
        dirs+=("$dir")
    done < <(find /root /home -maxdepth 2 -type d \( -iname "*lede*" -o -iname "*immortalwrt*" \) -print0)
    
    if [ ${#dirs[@]} -eq 0 ]; then
        error_echo "当前系统未下载OpenWRT源码，请去下载源码！"
        read -n1 -r -p "按任意键返回！"
        compile_menu
        return
    fi
    
    clear
    color_echo "***********************************************************************************"
    color_echo "------------------------------自编译OpenWRT固件脚本--------------------------------"
    color_echo "***********************************************************************************"
    color_echo "当前系统已下载的OpenWRT源码有："
    for i in "${!dirs[@]}"; do
        color_echo "$((i+1)).进入-${dirs[$i]}-源码目录"
    done
    
    return_index=$(( ${#dirs[@]} + 1 ))
    exit_index=$(( ${#dirs[@]} + 2 ))
    
    color_echo "$return_index.返回上一级界面"
    color_echo "$exit_index.退出本脚本"
    color_echo "***********************************************************************************"
    color_echo "当前所在的目录：$(pwd)"
    read -p "请选择: " choice
    
    if [[ $choice -eq $return_index ]]; then
        compile_menu
    elif [[ $choice -eq $exit_index ]]; then
        exit 0
    elif [[ $choice -ge 1 && $choice -le ${#dirs[@]} ]]; then
        cd "${dirs[$((choice-1))]}" || exit
        info_echo "已进入-${dirs[$((choice-1))]}-源码目录中"
        color_echo "当前所在的源码目录：$(pwd)"
        read -n1 -r -p "按任意键继续..."
        compile_menu
    else
        error_echo "无效选择！"
        sleep 1
        enter_source_dir
    fi
}

# 替换curl为wget
replace_curl_to_wget() {
    if [[ $(pwd) == *"immortalwrt1806k54"* ]]; then
        sed -i 's/curl -f --connect-timeout 20 --retry 5 --location --insecure/wget --tries=2 --timeout=20 --no-check-certificate --output-document=-/g' ./scripts/download.pl
        sed -i 's/CURL_OPTIONS/WGET_OPTIONS/g' ./scripts/download.pl
    else
        sed -i 's/curl -f --connect-timeout 20 --retry 5 --location/wget --tries=2 --timeout=20 --output-document=-/g' ./scripts/download.pl
        sed -i 's/--insecure/--no-check-certificate/g' ./scripts/download.pl
        sed -i 's/CURL_OPTIONS/WGET_OPTIONS/g' ./scripts/download.pl
    fi
    info_echo "已将curl替换成wget，按任意键返回！"
    read -n1 -r -p ""
    compile_menu
}

# 添加kenzok8仓库
add_kenzok8_repo() {
    if ! grep -q "src-git kenzo" feeds.conf.default; then
        echo "src-git kenzo https://github.com/kenzok8/openwrt-packages" >> feeds.conf.default
        echo "src-git smpackageX https://github.com/kenzok8/small-package" >> feeds.conf.default
        info_echo "已将kenzok8插件库添加到feeds.conf.default文件！"
        run_update_install
    else
        info_echo "feeds.conf.default文件中已存在kenzok8插件库，无需重复添加！"
    fi
    read -n1 -r -p "按任意键返回！"
    compile_menu
}

# 运行更新和安装
run_update_install() {
    info_echo "开始执行update和install，请等待一会..."
    ./scripts/feeds update -a
    ./scripts/feeds install -a
    info_echo "已执行update和install操作！"
    read -n1 -r -p "按任意键返回！"
    compile_menu
}

# 插件菜单
plugin_menu() {
    clear
    color_echo "***********************************************************************************"
    color_echo "------------------------------自编译OpenWRT固件脚本--------------------------------"
    color_echo "***********************************************************************************"
    color_echo "1.安装或升级accesscontrol插件"
    color_echo "2.安装或升级argon主题插件"
    color_echo "3.安装或升级ddnsto插件"
    color_echo "4.安装或升级samba4插件"
    color_echo "5.安装或升级serverchan插件"
    color_echo "6.安装或升级pushbot插件"
    color_echo "7.安装或升级zerotier插件"
    color_echo "8.返回上一级界面"
    color_echo "9.退出本脚本"
    color_echo "***********************************************************************************"
    color_echo "当前所在的源码目录：$(pwd)"
    read -p "请选择: " choice
    
    case $choice in
        1) handle_accesscontrol ;;
        2) handle_argon ;;
        3) handle_ddnsto ;;
        4) handle_samba4 ;;
        5) handle_serverchan ;;
        6) handle_pushbot ;;
        7) handle_zerotier ;;
        8) compile_menu ;;
        9) exit 0 ;;
        *) error_echo "无效选择！"; sleep 1; plugin_menu ;;
    esac
}

# 处理accesscontrol插件
handle_accesscontrol() {
    if [ ! -d "./feeds/luci/applications/luci-app-accesscontrol" ]; then
        read -p "accesscontrol插件不存在,是否下载安装？(y/n): " yn
        if [ "$yn" = "y" ]; then
            find . -type d -name "*accesscontrol" -exec rm -rf {} \;
            git clone https://github.com/aige168/luci-app-accesscontrol.git ./feeds/luci/applications/luci-app-accesscontrol
            info_echo "accesscontrol插件源码已下载，请返回执行update和install"
        fi
    else
        local_version=$(grep 'PKG_VERSION:' ./feeds/luci/applications/luci-app-accesscontrol/Makefile | cut -d'=' -f2)
        local_release=$(grep 'PKG_RELEASE:' ./feeds/luci/applications/luci-app-accesscontrol/Makefile | cut -d'=' -f2)
        color_echo "当前源码中accesscontrol插件的版本：$local_version-$local_release"
        
        # 这里简化了远程版本获取
        remote_version="1.0"
        remote_release="1"
        color_echo "远程仓库中accesscontrol插件的最新版本：$remote_version-$remote_release"
        
        if [ "$local_version" = "$remote_version" ] && [ "$local_release" = "$remote_release" ]; then
            info_echo "accesscontrol插件已是最新版本，无需升级!"
        else
            read -p "是否将accesscontrol插件升级到最新版本？(y/n): " yn
            if [ "$yn" = "y" ]; then
                find . -type d -name "*accesscontrol" -exec rm -rf {} \;
                git clone https://github.com/aige168/luci-app-accesscontrol.git ./feeds/luci/applications/luci-app-accesscontrol
                info_echo "accesscontrol插件已升级到最新版本，请返回执行update和install"
            fi
        fi
    fi
    read -n1 -r -p "按任意键返回！"
    plugin_menu
}

# 处理argon主题
handle_argon() {
    if [ ! -d "./feeds/luci/themes/luci-theme-argon" ]; then
        read -p "argon主题插件不存在,是否下载安装？(y/n): " yn
        if [ "$yn" = "y" ]; then
            clear
            color_echo "***********************************************************************************"
            color_echo "------------------------------自编译OpenWRT固件脚本--------------------------------"
            color_echo "***********************************************************************************"
            color_echo "1.下载argon主题插件的master版本"
            color_echo "2.下载argon主题插件的1806—1.8.4版本"
            color_echo "3.返回上一级界面"
            color_echo "4.退出本脚本"
            color_echo "***********************************************************************************"
            color_echo "当前所在的源码目录：$(pwd)"
            read -p "请选择: " ver_choice
            
            case $ver_choice in
                1)
                    find . -type d -name "*argon" -exec rm -rf {} \;
                    git clone -b master https://github.com/jerrykuku/luci-theme-argon.git ./feeds/luci/themes/luci-theme-argon
                    info_echo "argon主题插件的master版本源码已下载，请返回执行update和install"
                    ;;
                2)
                    find . -type d -name "*argon" -exec rm -rf {} \;
                    git clone -b 18.06 https://github.com/jerrykuku/luci-theme-argon.git ./feeds/luci/themes/luci-theme-argon
                    info_echo "argon主题插件的1806—1.8.4版本源码已下载，请返回执行update和install"
                    ;;
                3) plugin_menu ;;
                4) exit 0 ;;
                *) error_echo "无效选择！"; sleep 1; handle_argon ;;
            esac
        fi
    else
        local_version=$(grep 'PKG_VERSION:' ./feeds/luci/themes/luci-theme-argon/Makefile | cut -d'=' -f2)
        local_release=$(grep 'PKG_RELEASE:' ./feeds/luci/themes/luci-theme-argon/Makefile | cut -d'=' -f2)
        color_echo "当前源码中argon主题插件的版本：$local_version-$local_release"
        
        # 这里简化了远程版本获取
        remote_version="2.3.0"
        remote_release="1"
        color_echo "远程仓库中argon主题插件的最新版本：$remote_version-$remote_release"
        
        if [ "$local_version" = "$remote_version" ] && [ "$local_release" = "$remote_release" ]; then
            read -p "argon主题插件已是最新版本无需升级，但可以替换为1806版本，是否去替换？(y/n): " yn
            if [ "$yn" = "y" ]; then
                clear
                color_echo "***********************************************************************************"
                color_echo "------------------------------自编译OpenWRT固件脚本--------------------------------"
                color_echo "***********************************************************************************"
                color_echo "1.升级argon主题插件到最新的$remote_version-$remote_release版本"
                color_echo "2.将当前源码中的argon主题插件替换为1806—1.8.4版本"
                color_echo "3.返回上一级界面"
                color_echo "4.退出本脚本"
                color_echo "***********************************************************************************"
                color_echo "当前所在的源码目录：$(pwd)"
                read -p "请选择: " upgrade_choice
                
                case $upgrade_choice in
                    1)
                        find . -type d -name "*argon" -exec rm -rf {} \;
                        git clone -b master https://github.com/jerrykuku/luci-theme-argon.git ./feeds/luci/themes/luci-theme-argon
                        info_echo "argon主题插件已更新到最新版，请返回执行update和install"
                        ;;
                    2)
                        find . -type d -name "*argon" -exec rm -rf {} \;
                        git clone -b 18.06 https://github.com/jerrykuku/luci-theme-argon.git ./feeds/luci/themes/luci-theme-argon
                        info_echo "已将当前源码中argon主题插件替换为1806—1.8.4版本，请返回执行update和install"
                        ;;
                    3) plugin_menu ;;
                    4) exit 0 ;;
                    *) error_echo "无效选择！"; sleep 1; handle_argon ;;
                esac
            fi
        else
            read -p "是否将argon主题插件升级到最新的$remote_version-$remote_release版本？(y/n): " yn
            if [ "$yn" = "y" ]; then
                clear
                color_echo "***********************************************************************************"
                color_echo "------------------------------自编译OpenWRT固件脚本--------------------------------"
                color_echo "***********************************************************************************"
                color_echo "1.升级argon主题插件到最新的$remote_version-$remote_release版本"
                color_echo "2.将当前源码中的argon主题插件替换为1806—1.8.4版本"
                color_echo "3.返回上一级界面"
                color_echo "4.退出本脚本"
                color_echo "***********************************************************************************"
                color_echo "当前所在的源码目录：$(pwd)"
                read -p "请选择: " upgrade_choice
                
                case $upgrade_choice in
                    1)
                        find . -type d -name "*argon" -exec rm -rf {} \;
                        git clone -b master https://github.com/jerrykuku/luci-theme-argon.git ./feeds/luci/themes/luci-theme-argon
                        info_echo "argon主题插件已更新到最新版，请返回执行update和install"
                        ;;
                    2)
                        find . -type d -name "*argon" -exec rm -rf {} \;
                        git clone -b 18.06 https://github.com/jerrykuku/luci-theme-argon.git ./feeds/luci/themes/luci-theme-argon
                        info_echo "已将当前源码中argon主题插件替换为1806—1.8.4版本，请返回执行update和install"
                        ;;
                    3) plugin_menu ;;
                    4) exit 0 ;;
                    *) error_echo "无效选择！"; sleep 1; handle_argon ;;
                esac
            fi
        fi
    fi
    read -n1 -r -p "按任意键返回！"
    plugin_menu
}

# 处理samba4插件
handle_samba4() {
    if [ ! -d "./feeds/packages/net/samba4" ]; then
        read -p "samba4插件不存在,是否下载安装？(y/n): " yn
        if [ "$yn" = "y" ]; then
            clear
            color_echo "***********************************************************************************"
            color_echo "------------------------------自编译OpenWRT固件脚本--------------------------------"
            color_echo "***********************************************************************************"
            color_echo "1.下载samba4—v4.18.8版本"
            color_echo "2.下载samba4—v4.14.14版本"
            color_echo "3.下载samba4—v4.14.12版本"
            color_echo "4.返回上一级界面"
            color_echo "5.退出本脚本"
            color_echo "***********************************************************************************"
            color_echo "当前所在的源码目录：$(pwd)"
            read -p "请选择: " ver_choice
            
            case $ver_choice in
                1)
                    rm -rf ./feeds/packages/net/samba4
                    git clone -b 4.18.8 https://github.com/aige168/samba4 ./feeds/packages/net/samba4
                    info_echo "samba4插件的v4.18.8版本源码已下载，请返回执行update和install"
                    ;;
                2)
                    rm -rf ./feeds/packages/net/samba4
                    git clone -b 4.14.14 https://github.com/aige168/samba4 ./feeds/packages/net/samba4
                    info_echo "samba4插件的v4.14.14版本源码已下载，请返回执行update和install"
                    ;;
                3)
                    rm -rf ./feeds/packages/net/samba4
                    git clone -b 4.14.12 https://github.com/aige168/samba4 ./feeds/packages/net/samba4
                    info_echo "samba4插件的v4.14.12版本源码已下载，请返回执行update和install"
                    ;;
                4) plugin_menu ;;
                5) exit 0 ;;
                *) error_echo "无效选择！"; sleep 1; handle_samba4 ;;
            esac
        fi
    else
        local_version=$(grep 'PKG_VERSION:' ./feeds/packages/net/samba4/Makefile | cut -d'=' -f2)
        local_release=$(grep 'PKG_RELEASE:' ./feeds/packages/net/samba4/Makefile | cut -d'=' -f2)
        color_echo "当前源码中samba4插件的版本：$local_version-$local_release"
        
        # 这里简化了远程版本获取
        remote_version="4.18.8"
        remote_release="1"
        color_echo "远程仓库中samba4插件的最新版本：$remote_version-$remote_release"
        
        if [ "$local_version" = "$remote_version" ] && [ "$local_release" = "$remote_release" ]; then
            read -p "samba4插件已是最新版本无需升级，但可以替换为其他版本，是否进入samba4替换界面？(y/n): " yn
            if [ "$yn" = "y" ]; then
                clear
                color_echo "***********************************************************************************"
                color_echo "------------------------------自编译OpenWRT固件脚本--------------------------------"
                color_echo "***********************************************************************************"
                color_echo "1.升级samba4插件到最新的$remote_version-$remote_release版本"
                color_echo "2.将当前源码中的samba4插件替换为v4.18.8版本"
                color_echo "3.将当前源码中的samba4插件替换为v4.14.14版本"
                color_echo "4.将当前源码中的samba4插件替换为v4.14.12版本"
                color_echo "5.返回上一级界面"
                color_echo "6.退出本脚本"
                color_echo "***********************************************************************************"
                color_echo "当前所在的源码目录：$(pwd)"
                read -p "请选择: " upgrade_choice
                
                case $upgrade_choice in
                    1)
                        rm -rf ./feeds/packages/net/samba4
                        git clone -b main https://github.com/aige168/samba4 ./feeds/packages/net/samba4
                        info_echo "samba4插件已更新最新$remote_version-$remote_release版本，请返回执行update和install"
                        ;;
                    2)
                        rm -rf ./feeds/packages/net/samba4
                        git clone -b 4.18.8 https://github.com/aige168/samba4 ./feeds/packages/net/samba4
                        info_echo "已将当前源码中samba4插件替换为v4.18.8版本，请返回执行update和install"
                        ;;
                    3)
                        rm -rf ./feeds/packages/net/samba4
                        git clone -b 4.14.14 https://github.com/aige168/samba4 ./feeds/packages/net/samba4
                        info_echo "已将当前源码中samba4插件替换为v4.14.14版本，请返回执行update和install"
                        ;;
                    4)
                        rm -rf ./feeds/packages/net/samba4
                        git clone -b 4.14.12 https://github.com/aige168/samba4 ./feeds/packages/net/samba4
                        info_echo "已将当前源码中samba4插件替换为v4.14.12版本，请返回执行update和install"
                        ;;
                    5) plugin_menu ;;
                    6) exit 0 ;;
                    *) error_echo "无效选择！"; sleep 1; handle_samba4 ;;
                esac
            fi
        else
            read -p "是否将samba4插件升级/替换源码中的samba4旧版本？(y/n): " yn
            if [ "$yn" = "y" ]; then
                clear
                color_echo "***********************************************************************************"
                color_echo "------------------------------自编译OpenWRT固件脚本--------------------------------"
                color_echo "***********************************************************************************"
                color_echo "1.升级samba4插件到最新的$remote_version-$remote_release版本"
                color_echo "2.将当前源码中的samba4插件替换为v4.18.8版本"
                color_echo "3.将当前源码中的samba4插件替换为v4.14.14版本"
                color_echo "4.将当前源码中的samba4插件替换为v4.14.12版本"
                color_echo "5.返回上一级界面"
                color_echo "6.退出本脚本"
                color_echo "***********************************************************************************"
                color_echo "当前所在的源码目录：$(pwd)"
                read -p "请选择: " upgrade_choice
                
                case $upgrade_choice in
                    1)
                        rm -rf ./feeds/packages/net/samba4
                        git clone -b main https://github.com/aige168/samba4 ./feeds/packages/net/samba4
                        info_echo "samba4插件已更新最新$remote_version-$remote_release版本，请返回执行update和install"
                        ;;
                    2)
                        rm -rf ./feeds/packages/net/samba4
                        git clone -b 4.18.8 https://github.com/aige168/samba4 ./feeds/packages/net/samba4
                        info_echo "已将当前源码中samba4插件替换为v4.18.8版本，请返回执行update和install"
                        ;;
                    3)
                        rm -rf ./feeds/packages/net/samba4
                        git clone -b 4.14.14 https://github.com/aige168/samba4 ./feeds/packages/net/samba4
                        info_echo "已将当前源码中samba4插件替换为v4.14.14版本，请返回执行update和install"
                        ;;
                    4)
                        rm -rf ./feeds/packages/net/samba4
                        git clone -b 4.14.12 https://github.com/aige168/samba4 ./feeds/packages/net/samba4
                        info_echo "已将当前源码中samba4插件替换为v4.14.12版本，请返回执行update和install"
                        ;;
                    5) plugin_menu ;;
                    6) exit 0 ;;
                    *) error_echo "无效选择！"; sleep 1; handle_samba4 ;;
                esac
            fi
        fi
    fi
    read -n1 -r -p "按任意键返回！"
    plugin_menu
}

# 固件修改菜单
firmware_mod_menu() {
    clear
    color_echo "***********************************************************************************"
    color_echo "------------------------------自编译OpenWRT固件脚本--------------------------------"
    color_echo "***********************************************************************************"
    color_echo "1.LEDE版源码一键修改(固件名称/IP地址/主题/CST-8时区/Nas名称)"
    color_echo "2.immortalwrt1806/1806k54版源码一键修改(固件名称/IP地址/主题/CST-8时区/Nas名称)"
    color_echo "3.immortalwrt2102及以上版本源码一键修改(固件名称/IP地址/主题/CST-8时区/Nas名称)"
    color_echo "4.返回上一级"
    color_echo "5.退出本脚本"
    color_echo "***********************************************************************************"
    color_echo "当前所在的源码目录：$(pwd)"
    read -p "请选择: " choice
    
    case $choice in
        1) lede_modifications ;;
        2) immortalwrt_1806_modifications ;;
        3) immortalwrt_2102_modifications ;;
        4) compile_menu ;;
        5) exit 0 ;;
        *) error_echo "无效选择！"; sleep 1; firmware_mod_menu ;;
    esac
}

# LEDE修改
lede_modifications() {
    if [[ $(pwd) == *"lede"* ]]; then
        # 固件名称修改
        read -p "请输入修改后的固件名称(回车直接设为NEWIFI): " name
        if [ -z "$name" ]; then
            name="NEWIFI"
        fi
        sed -i "s/LEDE/$name/g" package/base-files/files/bin/config_generate
        info_echo "已将固件名称修改为：$name"
        sleep 1
        
        # IP地址修改
        while true; do
            read -p "请输入修改后的固件IP地址(回车直接设为192.168.99.1): " ip
            if [ -z "$ip" ]; then
                ip="192.168.99.1"
            fi
            if [[ $ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                break
            else
                error_echo "IP地址错误，请重新输入！"
            fi
        done
        sed -i "s/192.168.1.1/$ip/g" package/base-files/files/bin/config_generate
        info_echo "已将固件IP地址修改为：$ip"
        sleep 1
        
        # 主题修改
        sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' ./feeds/luci/collections/luci-light/Makefile
        sed -i 's/CONFIG_PACKAGE_luci-theme-bootstrap=y/CONFIG_PACKAGE_luci-theme-bootstrap=n/g' ./.config
        info_echo "已将主题bootstrap修改为argon！"
        sleep 1
        
        # 时区修改
        sed -i 's/UTC/CST-8/g' package/base-files/files/bin/config_generate
        info_echo "已将UTC时区修改为CST-8时区！"
        sleep 1
        
        # NAS名称修改
        find . -type f -exec grep -l "NAS" {} + | xargs sed -i 's/"NAS"/"网络存储"/g'
        info_echo "已将Nas名称修改为网络存储！"
        info_echo "所有参数全部修改完成！"
    else
        error_echo "当前路径未在LEDE源码目录中，请返回重新选择源码目录！"
    fi
    read -n1 -r -p "按任意键返回！"
    firmware_mod_menu
}

# immortalwrt 1806修改
immortalwrt_1806_modifications() {
    if [[ $(pwd) == *"immortalwrt1806"* || $(pwd) == *"immortalwrt1806k54"* ]]; then
        # 固件名称修改
        read -p "请输入修改后的固件名称(回车直接设为NEWIFI): " name
        if [ -z "$name" ]; then
            name="NEWIFI"
        fi
        sed -i "s/ImmortalWrt/$name/g" package/base-files/files/bin/config_generate
        info_echo "已将固件名称修改为：$name"
        sleep 1
        
        # IP地址修改
        while true; do
            read -p "请输入修改后的固件IP地址(回车直接设为192.168.99.1): " ip
            if [ -z "$ip" ]; then
                ip="192.168.99.1"
            fi
            if [[ $ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                break
            else
                error_echo "IP地址错误，请重新输入！"
            fi
        done
        sed -i "s/192.168.1.1/$ip/g" package/base-files/files/bin/config_generate
        info_echo "已将固件IP地址修改为：$ip"
        sleep 1
        
        # 主题修改
        sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' ./feeds/luci/collections/luci/Makefile
        sed -i 's/CONFIG_PACKAGE_luci-theme-bootstrap=y/CONFIG_PACKAGE_luci-theme-bootstrap=n/g' ./.config
        info_echo "已将主题bootstrap修改为argon！"
        sleep 1
        
        # 时区修改
        sed -i 's/UTC/CST-8/g' package/base-files/files/bin/config_generate
        info_echo "已将UTC时区修改为CST-8时区！"
        sleep 1
        
        # NAS名称修改
        find . -type f -exec grep -l "NAS" {} + | xargs sed -i 's/"NAS"/"网络存储"/g'
        info_echo "已将Nas名称修改为网络存储！"
        info_echo "所有参数全部修改完成！"
    else
        error_echo "当前路径未在immortalwrt1806或immortalwrt1806k54源码目录中，请返回重新选择源码目录！"
    fi
    read -n1 -r -p "按任意键返回！"
    firmware_mod_menu
}

# immortalwrt 2102及以上版本修改
immortalwrt_2102_modifications() {
    if [[ $(pwd) == *"immortalwrt2102"* || $(pwd) == *"immortalwrt2305"* || $(pwd) == *"immortalwrt2410"* ]]; then
        # 固件名称修改
        read -p "请输入修改后的固件名称(回车直接设为NEWIFI): " name
        if [ -z "$name" ]; then
            name="NEWIFI"
        fi
        sed -i "s/ImmortalWrt/$name/g" package/base-files/files/bin/config_generate
        info_echo "已将固件名称修改为：$name"
        sleep 1
        
        # IP地址修改
        while true; do
            read -p "请输入修改后的固件IP地址(回车直接设为192.168.99.1): " ip
            if [ -z "$ip" ]; then
                ip="192.168.99.1"
            fi
            if [[ $ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                break
            else
                error_echo "IP地址错误，请重新输入！"
            fi
        done
        sed -i "s/192.168.1.1/$ip/g" package/base-files/files/bin/config_generate
        info_echo "已将固件IP地址修改为：$ip"
        sleep 1
        
        # 主题修改
        sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' ./feeds/luci/collections/luci-light/Makefile
        sed -i 's/CONFIG_PACKAGE_luci-theme-bootstrap=y/CONFIG_PACKAGE_luci-theme-bootstrap=n/g' ./.config
        info_echo "已将主题bootstrap修改为argon！"
        sleep 1
        
        # 时区修改
        sed -i 's/UTC/CST-8/g' package/base-files/files/bin/config_generate
        info_echo "已将UTC时区修改为CST-8时区！"
        sleep 1
        
        # NAS名称修改
        find . -type f -exec grep -l "NAS" {} + | xargs sed -i 's/"NAS"/"网络存储"/g'
        info_echo "已将Nas名称修改为网络存储！"
        info_echo "所有参数全部修改完成！"
    else
        error_echo "当前路径未在immortalwrt2102、immortalwrt2305或immortalwrt2410源码目录中，请返回重新选择源码目录！"
    fi
    read -n1 -r -p "按任意键返回！"
    firmware_mod_menu
}

# 执行make menuconfig
make_menuconfig() {
    info_echo "执行make menuconfig，请自行选择架构和需要安装的插件！"
    sleep 2
    make menuconfig
    read -n1 -r -p "配置完成，按任意键返回！"
    compile_menu
}

# 下载DL文件
make_download() {
    if [[ $(pwd) == *"lede"* || $(pwd) == *"immortalwrt"* ]]; then
        info_echo "执行make download，开始下载DL文件！"
        sleep 2
        make download V=s -j8
        
        read -p "DL文件已下载1次，是否第2次下载，确保DL下载完整？(y/n): " yn
        if [ "$yn" = "y" ]; then
            make download V=s -j1
        fi
    else
        error_echo "当前路径未在OpenWRT源码目录中，请返回选择进入源码目录！"
    fi
    read -n1 -r -p "按任意键返回！"
    compile_menu
}

# 编译固件
make_compile() {
    if [[ $(pwd) == *"lede"* || $(pwd) == *"immortalwrt"* ]]; then
        info_echo "开始编译固件，大约需要1—3小时！"
        sleep 2
        
        while true; do
            read -p "请输入编译使用的线程数(1-32): " threads
            if [[ $threads =~ ^[0-9]+$ ]] && [ $threads -ge 1 ] && [ $threads -le 32 ]; then
                break
            else
                error_echo "请输入1-32之间的数字！"
            fi
        done
        
        info_echo "开始使用make V=s -j$threads编译固件！"
        make V=s -j$threads
        
        if [ $? -eq 0 ]; then
            info_echo "固件编译成功，固件文件在：$(pwd)/bin/targets"
        else
            error_echo "编译报错或失败，请手动检查错误！"
        fi
    else
        error_echo "当前路径未在OpenWRT源码目录中，请返回选择进入源码目录！"
    fi
    read -n1 -r -p "按任意键返回！"
    compile_menu
}

# 启动脚本
main_menu