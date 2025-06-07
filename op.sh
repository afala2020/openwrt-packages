#!/bin/bash

# 解决Backspace和Delete键问题
stty -echoctl
stty erase '^H' # 设置 Backspace 键
stty werase '^[[3~' # 设置 Delete 键

# 设置颜色变量
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 随机选择绿色或黄色作为主色调
COLORS=("$GREEN" "$YELLOW")
MAIN_COLOR=${COLORS[$RANDOM % ${#COLORS[@]}]}

# 清理函数，退出时恢复终端颜色
cleanup() {
    echo -e "${NC}"
    stty sane
    exit 0
}

# 捕获退出信号
trap cleanup EXIT INT TERM

# 清除代理函数
clear_proxy() {
    unset HTTP_PROXY HTTPS_PROXY FTP_PROXY ALL_PROXY
    unset http_proxy https_proxy ftp_proxy all_proxy
    
    # 从~/.bashrc中删除代理设置
    if [ -f ~/.bashrc ]; then
        sed -i '/export HTTP_PROXY=/d' ~/.bashrc
        sed -i '/export HTTPS_PROXY=/d' ~/.bashrc
        sed -i '/export FTP_PROXY=/d' ~/.bashrc
        sed -i '/export ALL_PROXY=/d' ~/.bashrc
        sed -i '/export http_proxy=/d' ~/.bashrc
        sed -i '/export https_proxy=/d' ~/.bashrc
        sed -i '/export ftp_proxy=/d' ~/.bashrc
        sed -i '/export all_proxy=/d' ~/.bashrc
    fi
}

# 获取当前代理设置
get_current_proxy() {
    temp_proxy=""
    perm_proxy=""
    
    if [ ! -z "$HTTP_PROXY" ] || [ ! -z "$http_proxy" ]; then
        temp_proxy="$HTTP_PROXY"
        [ -z "$temp_proxy" ] && temp_proxy="$http_proxy"
    fi
    
    if [ -f ~/.bashrc ]; then
        perm_proxy=$(grep "export HTTP_PROXY=" ~/.bashrc | head -1 | cut -d'"' -f2)
    fi
}

# IP地址验证函数
validate_ip() {
    local ip=$1
    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        IFS='.' read -ra ADDR <<< "$ip"
        for i in "${ADDR[@]}"; do
            if [[ $i -gt 255 ]]; then
                return 1
            fi
        done
        return 0
    fi
    return 1
}

# 端口验证函数
validate_port() {
    local port=$1
    if [[ $port =~ ^[0-9]+$ ]] && [ $port -ge 1 ] && [ $port -le 65535 ]; then
        return 0
    fi
    return 1
}

# 按任意键返回函数
press_any_key() {
    echo -e "${MAIN_COLOR}按任意键返回！${NC}"
    read -n 1 -s
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
    echo -e "* 9.退出脚本"
    echo -e "***********************************************************************************${NC}"
    echo -e "${MAIN_COLOR}请选择相应的编号(1-9)：${NC}"
}

# 显示依赖环境界面
show_dependency_menu() {
    clear
    echo -e "${MAIN_COLOR}***********************************************************************************"
    echo -e "------------------------------自编译OpenWRT固件脚本--------------------------------"
    echo -e "***********************************************************************************"
    echo -e "1.一键安装Openwrt编译所需全部依赖包"
    echo -e "2.设置允许root用户编译(FORCE_UNSAFE_CONFIGURE=1)"
    echo -e "3.手动添加系统代理IP和端口"
    echo -e "4.返回上一级界面"
    echo -e "5.退出脚本"
    echo -e "***********************************************************************************${NC}"
}

# 显示代理设置界面
show_proxy_menu() {
    clear
    echo -e "${MAIN_COLOR}***********************************************************************************"
    echo -e "------------------------------自编译OpenWRT固件脚本--------------------------------"
    echo -e "***********************************************************************************"
    echo -e "1.设置临时代理（仅当前终端有效）"
    echo -e "2.设置永久代理（写入~/.bashrc）"
    echo -e "3.清除代理设置"
    echo -e "4.返回上一级"
    echo -e "5.退出本脚本"
    echo -e "***********************************************************************************${NC}"
    
    # 获取当前代理设置
    get_current_proxy
    if [ ! -z "$temp_proxy" ]; then
        echo -e "${MAIN_COLOR}系统当前已设置的临时代理：$temp_proxy${NC}"
    else
        echo -e "${MAIN_COLOR}系统当前已设置的临时代理：未设置${NC}"
    fi
    
    if [ ! -z "$perm_proxy" ]; then
        echo -e "${MAIN_COLOR}系统当前已设置的永久代理：$perm_proxy${NC}"
    else
        echo -e "${MAIN_COLOR}系统当前已设置的永久代理：未设置${NC}"
    fi
    
    if [ -z "$temp_proxy" ] && [ -z "$perm_proxy" ]; then
        echo -e "${MAIN_COLOR}当前未设置临时代理或永久代理！${NC}"
    fi
}

# 显示Python版本界面
show_python_menu() {
    clear
    echo -e "${MAIN_COLOR}***********************************************************************************"
    echo -e "------------------------------自编译OpenWRT固件脚本--------------------------------"
    echo -e "***********************************************************************************"
    echo -e "1.检查Python版本"
    echo -e "2.安装指定的Python版本"
    echo -e "3.返回上一级界面"
    echo -e "4.退出本脚本"
    echo -e "***********************************************************************************${NC}"
}

# 显示Python版本选择界面
show_python_version_menu() {
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
    echo -e "***********************************************************************************${NC}"
}

# 显示源码下载界面
show_source_menu() {
    clear
    echo -e "${MAIN_COLOR}***********************************************************************************"
    echo -e "------------------------------自编译OpenWRT固件脚本--------------------------------"
    echo -e "***********************************************************************************"
    echo -e "1.下载LEDE源码"
    echo -e "2.下载immortalwrt源码"
    echo -e "3.返回上一级界面"
    echo -e "4.退出本脚本"
    echo -e "***********************************************************************************${NC}"
    echo -e "${MAIN_COLOR}请将源码下载到/root或/home目录，否则无法编译！${NC}"
    echo -e "${MAIN_COLOR}当前所在的目录：$(pwd)${NC}"
}

# 显示LEDE源码下载界面
show_lede_menu() {
    clear
    echo -e "${MAIN_COLOR}***********************************************************************************"
    echo -e "------------------------------自编译OpenWRT固件脚本--------------------------------"
    echo -e "***********************************************************************************"
    echo -e "1.将LEDE源码下载到当前目录下"
    echo -e "2.输入自定义，LEDE源码的下载路径"
    echo -e "3.返回上一级界面"
    echo -e "4.退出本脚本"
    echo -e "***********************************************************************************${NC}"
    echo -e "${MAIN_COLOR}请将源码下载到/root或/home目录，否则无法编译！${NC}"
    echo -e "${MAIN_COLOR}当前所在的目录：$(pwd)${NC}"
}

# 显示immortalwrt源码下载界面
show_immortalwrt_menu() {
    clear
    echo -e "${MAIN_COLOR}***********************************************************************************"
    echo -e "------------------------------自编译OpenWRT固件脚本--------------------------------"
    echo -e "***********************************************************************************"
    echo -e "1.将immortalwrt源码下载到当前目录下"
    echo -e "2.输入自定义，immortalwrt源码的下载路径"
    echo -e "3.返回上一级界面"
    echo -e "4.退出本脚本"
    echo -e "***********************************************************************************${NC}"
    echo -e "${MAIN_COLOR}请将源码下载到/root或/home目录，否则无法编译！${NC}"
    echo -e "${MAIN_COLOR}当前所在的目录：$(pwd)${NC}"
}

# 显示immortalwrt版本选择界面
show_immortalwrt_version_menu() {
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
    echo -e "***********************************************************************************${NC}"
    echo -e "${MAIN_COLOR}请将源码下载到/root或/home目录，否则无法编译！${NC}"
    echo -e "${MAIN_COLOR}当前所在的目录：$(pwd)${NC}"
}

# 显示编译过程界面
show_compile_menu() {
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
    echo -e "************************************************************************************${NC}"
    echo -e "${MAIN_COLOR}当前所在的目录：$(pwd)${NC}"
}

# 显示插件安装升级界面
show_plugin_menu() {
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
    echo -e "***********************************************************************************${NC}"
    echo -e "${MAIN_COLOR}当前所在的源码目录：$(pwd)${NC}"
}

# 显示argon版本选择界面1
show_argon_version1_menu() {
    clear
    echo -e "${MAIN_COLOR}***********************************************************************************"
    echo -e "------------------------------自编译OpenWRT固件脚本--------------------------------"
    echo -e "***********************************************************************************"
    echo -e "1.下载argon主题插件的master版本"
    echo -e "2.下载argon主题插件的1806—1.8.4版本"
    echo -e "3.返回上一级界面"
    echo -e "4.退出本脚本"
    echo -e "***********************************************************************************${NC}"
    echo -e "${MAIN_COLOR}当前所在的源码目录：$(pwd)${NC}"
}

# 显示argon版本选择界面2
show_argon_version2_menu() {
    local remote_version=$1
    clear
    echo -e "${MAIN_COLOR}***********************************************************************************"
    echo -e "------------------------------自编译OpenWRT固件脚本--------------------------------"
    echo -e "***********************************************************************************"
    echo -e "1.升级argon主题插件到最新的${remote_version}版本"
    echo -e "2.将当前源码中的argon主题插件替换为1806—1.8.4版本"
    echo -e "3.返回上一级界面"
    echo -e "4.退出本脚本"
    echo -e "***********************************************************************************${NC}"
    echo -e "${MAIN_COLOR}当前所在的源码目录：$(pwd)${NC}"
}

# 显示samba4版本选择界面1
show_samba4_version1_menu() {
    clear
    echo -e "${MAIN_COLOR}***********************************************************************************"
    echo -e "------------------------------自编译OpenWRT固件脚本--------------------------------"
    echo -e "***********************************************************************************"
    echo -e "1.下载samba4—v4.18.8版本"
    echo -e "2.下载samba4—v4.14.14版本"
    echo -e "3.下载samba4—v4.14.12版本"
    echo -e "4.返回上一级界面"
    echo -e "5.退出本脚本"
    echo -e "***********************************************************************************${NC}"
    echo -e "${MAIN_COLOR}当前所在的源码目录：$(pwd)${NC}"
}

# 显示samba4版本选择界面2
show_samba4_version2_menu() {
    local remote_version=$1
    clear
    echo -e "${MAIN_COLOR}***********************************************************************************"
    echo -e "------------------------------自编译OpenWRT固件脚本--------------------------------"
    echo -e "***********************************************************************************"
    echo -e "1.升级samba4插件到最新的${remote_version}版本"
    echo -e "2.将当前源码中的samba4插件替换为v4.18.8版本"
    echo -e "3.将当前源码中的samba4插件替换为v4.14.14版本"
    echo -e "4.将当前源码中的samba4插件替换为v4.14.12版本"
    echo -e "5.返回上一级界面"
    echo -e "6.退出本脚本"
    echo -e "***********************************************************************************${NC}"
    echo -e "${MAIN_COLOR}当前所在的源码目录：$(pwd)${NC}"
}

# 显示固件配置界面
show_firmware_config_menu() {
    clear
    echo -e "${MAIN_COLOR}***********************************************************************************"
    echo -e "------------------------------自编译OpenWRT固件脚本--------------------------------"
    echo -e "***********************************************************************************"
    echo -e "1.LEDE版源码一键修改(固件名称/IP地址/主题/CST-8时区/Nas名称)"
    echo -e "2.immortalwrt1806/1806k54版源码一键修改(固件名称/IP地址/主题/CST-8时区/Nas名称)"
    echo -e "3.immortalwrt2102及以上版本源码一键修改(固件名称/IP地址/主题/CST-8时区/Nas名称)"
    echo -e "4.返回上一级"
    echo -e "5.退出本脚本"
    echo -e "***********************************************************************************${NC}"
    echo -e "${MAIN_COLOR}当前所在的源码目录：$(pwd)${NC}"
}

# 检查是否在OpenWRT源码目录中
check_openwrt_dir() {
    local current_dir=$(basename "$(pwd)")
    local parent_dir=$(dirname "$(pwd)")
    
    if [[ "$current_dir" =~ ^(lede|immortalwrt) ]] || [[ "$current_dir" =~ ^(lede|immortalwrt).* ]]; then
        return 0
    fi
    return 1
}

# 搜索OpenWRT源码目录
search_openwrt_dirs() {
    local dirs=()
    
    # 搜索/root目录
    if [ -d "/root" ]; then
        while IFS= read -r -d '' dir; do
            dirs+=("$dir")
        done < <(find /root -maxdepth 1 -type d \( -iname "lede*" -o -iname "immortalwrt*" \) -print0 2>/dev/null)
    fi
    
    # 搜索/home目录
    if [ -d "/home" ]; then
        while IFS= read -r -d '' dir; do
            dirs+=("$dir")
        done < <(find /home -maxdepth 1 -type d \( -iname "lede*" -o -iname "immortalwrt*" \) -print0 2>/dev/null)
    fi
    
    echo "${dirs[@]}"
}

# 显示源码目录选择界面
show_source_dir_menu() {
    local dirs=($(search_openwrt_dirs))
    
    if [ ${#dirs[@]} -eq 0 ]; then
        echo -e "${RED}当前系统未下载OpenWRT源码，请去下载源码！${NC}"
        press_any_key
        return 1
    fi
    
    clear
    echo -e "${MAIN_COLOR}***********************************************************************************"
    echo -e "------------------------------自编译OpenWRT固件脚本--------------------------------"
    echo -e "***********************************************************************************"
    echo -e "当前系统已下载的OpenWRT源码有："
    
    local i=1
    for dir in "${dirs[@]}"; do
        local dirname=$(basename "$dir")
        local full_path=$(realpath "$dir")
        echo -e "${i}.进入-${full_path}-源码目录"
        ((i++))
    done
    
    local back_option=$i
    local exit_option=$((i+1))
    echo -e "${back_option}.返回上一级界面"
    echo -e "${exit_option}.退出本脚本"
    echo -e "***********************************************************************************${NC}"
    echo -e "${MAIN_COLOR}当前所在的目录：$(pwd)${NC}"
    
    while true; do
        read -p "请选择编号：" choice
        if [[ "$choice" =~ ^[0-9]+$ ]]; then
            if [ "$choice" -ge 1 ] && [ "$choice" -lt "$back_option" ]; then
                local selected_dir="${dirs[$((choice-1))]}"
                cd "$selected_dir"
                local dirname=$(basename "$selected_dir")
                local full_path=$(realpath "$selected_dir")
                echo -e "${MAIN_COLOR}已进入-${full_path}-源码目录中${NC}"
                echo -e "${MAIN_COLOR}当前所在的源码目录：${full_path}${NC}"
                press_any_key
                return 0
            elif [ "$choice" -eq "$back_option" ]; then
                return 1
            elif [ "$choice" -eq "$exit_option" ]; then
                cleanup
            fi
        fi
        echo -e "${RED}输入无效，请重新选择！${NC}"
    done
}

# 安装依赖包
install_dependencies() {
    echo -e "${MAIN_COLOR}开始安装Openwrt编译所需全部依赖包...${NC}"
    bash <(wget -qO- https://raw.githubusercontent.com/afala2020/openwrt-packages/refs/heads/main/yilai.sh)
    press_any_key
}

# 设置FORCE_UNSAFE_CONFIGURE
set_force_unsafe_configure() {
    if grep -q "export FORCE_UNSAFE_CONFIGURE=1" /etc/profile; then
        echo -e "${MAIN_COLOR}FORCE_UNSAFE_CONFIGURE=1已在/etc/profile文件中，无需重复写入！${NC}"
    else
        echo 'export FORCE_UNSAFE_CONFIGURE=1' >> /etc/profile
        source /etc/profile
        echo -e "${MAIN_COLOR}已将FORCE_UNSAFE_CONFIGURE=1写入/etc/profile，建议退出终端重新登录后生效！${NC}"
    fi
    press_any_key
}

# 设置临时代理
set_temp_proxy() {
    while true; do
        echo -e "${MAIN_COLOR}请输入代理服务器的IP：${NC}"
        read ip
        if validate_ip "$ip"; then
            break
        else
            echo -e "${RED}IP地址格式不正确，请重新输入！${NC}"
            press_any_key
            return
        fi
    done
    
    while true; do
        echo -e "${MAIN_COLOR}请输入代理服务器的端口：${NC}"
        read port
        if validate_port "$port"; then
            break
        else
            echo -e "${RED}端口格式不正确，请输入1-65535之间的数字！${NC}"
            press_any_key
            return
        fi
    done
    
    echo -e "${MAIN_COLOR}开始添加代理IP和端口.....${NC}"
    sleep 2
    
    # 清除现有代理
    clear_proxy
    
    # 设置新代理
    export HTTP_PROXY="http://$ip:$port"
    export HTTPS_PROXY="http://$ip:$port"
    export FTP_PROXY="http://$ip:$port"
    export ALL_PROXY="http://$ip:$port"
    export http_proxy="http://$ip:$port"
    export https_proxy="http://$ip:$port"
    export ftp_proxy="http://$ip:$port"
    export all_proxy="http://$ip:$port"
    
    echo -e "${MAIN_COLOR}已设置系统临时代理，仅当前终端有效！${NC}"
    press_any_key
}

# 设置永久代理
set_perm_proxy() {
    while true; do
        echo -e "${MAIN_COLOR}请输入代理服务器的IP：${NC}"
        read ip
        if validate_ip "$ip"; then
            break
        else
            echo -e "${RED}IP地址格式不正确，请重新输入！${NC}"
            press_any_key
            return
        fi
    done
    
    while true; do
        echo -e "${MAIN_COLOR}请输入代理服务器的端口：${NC}"
        read port
        if validate_port "$port"; then
            break
        else
            echo -e "${RED}端口格式不正确，请输入1-65535之间的数字！${NC}"
            press_any_key
            return
        fi
    done
    
    echo -e "${MAIN_COLOR}开始添加代理IP和端口.....${NC}"
    sleep 2
    
    # 清除现有代理
    clear_proxy
    
    # 添加到~/.bashrc
    echo "export HTTP_PROXY=\"http://$ip:$port\"" >> ~/.bashrc
    echo "export HTTPS_PROXY=\"http://$ip:$port\"" >> ~/.bashrc
    echo "export FTP_PROXY=\"http://$ip:$port\"" >> ~/.bashrc
    echo "export ALL_PROXY=\"http://$ip:$port\"" >> ~/.bashrc
    echo "export http_proxy=\"http://$ip:$port\"" >> ~/.bashrc
    echo "export https_proxy=\"http://$ip:$port\"" >> ~/.bashrc
    echo "export ftp_proxy=\"http://$ip:$port\"" >> ~/.bashrc
    echo "export all_proxy=\"http://$ip:$port\"" >> ~/.bashrc
    
    source ~/.bashrc
    
    echo -e "${MAIN_COLOR}已设置系统永久代理(写入~/.bashrc)，建议退出终端重新登录后生效！${NC}"
    press_any_key
}

# 清除代理设置
clear_proxy_settings() {
    clear_proxy
    echo -e "${MAIN_COLOR}已清理/删除将当前系统中的临时代理和永久代理！${NC}"
    press_any_key
}

# 检查Python版本
check_python_version() {
    echo -e "${MAIN_COLOR}当前Python版本：$(python -V 2>&1)${NC}"
    echo -e "${MAIN_COLOR}当前Python3版本：$(python3 -V 2>&1)${NC}"
    press_any_key
}

# 安装Python版本
install_python_version() {
    local version=$1
    local version_num=$2
    
    echo -e "${MAIN_COLOR}安装Python${version}.....需要等待一会！${NC}"
    sleep 5
    
    cd /home && rm -rf Python*
    wget https://www.python.org/ftp/python/${version}/Python-${version}.tar.xz
    tar -Jxvf Python-${version}.tar.xz && rm -rf Python-*.tar.xz
    cd /home/Python-${version}
    
    sudo ./configure --enable-optimizations && sudo make altinstall -j8 && sleep 3
    cd /root && rm -rf /home/Python*
    
    ls /usr/bin/ | grep python
    ls /usr/local/bin/ | grep python
    
    if [ "$version_num" != "3.10.9" ]; then
        echo -e "${MAIN_COLOR}正在将Python${version}设置为系统默认.....${NC}"
    fi
    
    local python_bin="/usr/local/bin/python${version_num%.*}"
    sudo update-alternatives --install /usr/bin/python python "$python_bin" 300
    sudo update-alternatives --install /usr/bin/python3 python3 "$python_bin" 300
    sudo update-alternatives --auto python
    sudo update-alternatives --auto python3
    
    echo -e "${MAIN_COLOR}当前Python版本：$(python -V 2>&1)${NC}"
    echo -e "${MAIN_COLOR}当前Python3版本：$(python3 -V 2>&1)${NC}"
    press_any_key
}

# 下载LEDE源码到当前目录
download_lede_current() {
    echo -e "${MAIN_COLOR}开始下载LEDE源码到：$(pwd)${NC}"
    git clone https://github.com/coolsnowwolf/lede
    if [ $? -eq 0 ]; then
        echo -e "${MAIN_COLOR}LEDE源码已下载到：$(pwd)/lede${NC}"
    else
        echo -e "${RED}LEDE源码下载失败！${NC}"
    fi
    press_any_key
}

# 下载LEDE源码到指定目录
download_lede_custom() {
    while true; do
        echo -e "${MAIN_COLOR}请输入lede源码的下载路径（输入绝对路径：/root或/home）：${NC}"
        read path
        if [ "$path" = "/root" ] || [ "$path" = "/home" ]; then
            echo -e "${MAIN_COLOR}开始下载lede源码到：$path${NC}"
            cd "$path"
            git clone https://github.com/coolsnowwolf/lede
            if [ $? -eq 0 ]; then
                echo -e "${MAIN_COLOR}LEDE源码已下载到：$path/lede${NC}"
            else
                echo -e "${RED}LEDE源码下载失败！${NC}"
            fi
            press_any_key
            return
        else
            echo -e "${RED}请输入绝对路径：/root或/home${NC}"
            press_any_key
            return
        fi
    done
}

# 下载immortalwrt源码
download_immortalwrt() {
    local branch=$1
    local dirname=$2
    local current_path=$(pwd)
    
    echo -e "${MAIN_COLOR}开始下载immortalwrt-${branch}源码到：$current_path${NC}"
    git clone -b "$branch" --single-branch https://github.com/immortalwrt/immortalwrt "$dirname"
    if [ $? -eq 0 ]; then
        echo -e "${MAIN_COLOR}immortalwrt-${branch}源码已下载到：$current_path/$dirname${NC}"
    else
        echo -e "${RED}immortalwrt-${branch}源码下载失败！${NC}"
    fi
    press_any_key
}

# 下载immortalwrt源码到指定目录
download_immortalwrt_custom() {
    local custom_path=$1
    local branch=$2
    local dirname=$3
    
    echo -e "${MAIN_COLOR}开始下载immortalwrt-${branch}源码到：$custom_path${NC}"
    cd "$custom_path"
    git clone -b "$branch" --single-branch https://github.com/immortalwrt/immortalwrt "$dirname"
    if [ $? -eq 0 ]; then
        echo -e "${MAIN_COLOR}immortalwrt-${branch}源码已下载到：$custom_path/$dirname${NC}"
    else
        echo -e "${RED}immortalwrt-${branch}源码下载失败！${NC}"
    fi
    press_any_key
}

# 替换curl为wget
replace_curl_with_wget() {
    if ! check_openwrt_dir; then
        echo -e "${RED}当前路径未在OpenWRT源码目录中，请返回选择进入源码目录！${NC}"
        press_any_key
        return
    fi
    
    echo -e "${MAIN_COLOR}当前所在的源码目录：$(pwd)${NC}"
    echo -e "${MAIN_COLOR}是否将download.pl文件curl替换为wget？[y/n]${NC}"
    read choice
    
    if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
        local current_dir=$(basename "$(pwd)")
        if [[ "$current_dir" =~ immortalwrt1806 ]]; then
            sed -i 's/curl -f --connect-timeout 20 --retry 5 --location --insecure/wget --tries=2 --timeout=20 --no-check-certificate --output-document=-/g' ./scripts/download.pl
            sed -i 's/CURL_OPTIONS/WGET_OPTIONS/g' ./scripts/download.pl
            echo -e "${MAIN_COLOR}已将curl替换成wget，按任意键返回J！${NC}"
        else
            sed -i 's/curl -f --connect-timeout 20 --retry 5 --location/wget --tries=2 --timeout=20 --output-document=-/g' ./scripts/download.pl
            sed -i 's/--insecure/--no-check-certificate/g' ./scripts/download.pl
            sed -i 's/CURL_OPTIONS/WGET_OPTIONS/g' ./scripts/download.pl
            echo -e "${MAIN_COLOR}已将curl替换成wget，按任意键返回X！${NC}"
        fi
        press_any_key
    fi
}

# 添加kenzok8插件库
add_kenzok8_feeds() {
    if ! check_openwrt_dir; then
        echo -e "${RED}当前路径未在OpenWRT源码目录中，请返回选择进入源码目录！${NC}"
        press_any_key
        return
    fi
    
    echo -e "${MAIN_COLOR}当前所在的源码目录：$(pwd)${NC}"
    echo -e "${MAIN_COLOR}是否添加kenzok8第三方插件库到源码中？[y/n]${NC}"
    read choice
    
    if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
        if ! grep -q "kenzok8/openwrt-packages" feeds.conf.default; then
            sed -i '$a src-git kenzo https://github.com/kenzok8/openwrt-packages' feeds.conf.default
            sed -i '$a src-git smpackageX https://github.com/kenzok8/small-package' feeds.conf.default
            echo -e "${MAIN_COLOR}已将kenzok8插件库添加到feeds.conf.default文件中！${NC}"
            echo -e "${MAIN_COLOR}开始执行update和install，请等待一会！${NC}"
            ./scripts/feeds update -a
            ./scripts/feeds install -a
            echo -e "${MAIN_COLOR}已添加kenzok8插件库，update和install运行完成，按任意键返回！${NC}"
        else
            echo -e "${MAIN_COLOR}feeds.conf.default文件中已存在kenzok8插件库，无需重复添加！${NC}"
        fi
        press_any_key
    fi
}

# 执行update和install
run_feeds_update_install() {
    if ! check_openwrt_dir; then
        echo -e "${RED}当前路径未在OpenWRT源码目录中，请返回选择进入源码目录！${NC}"
        press_any_key
        return
    fi
    
    echo -e "${MAIN_COLOR}当前所在的源码目录：$(pwd)${NC}"
    echo -e "${MAIN_COLOR}开始执行update和install，请等待一会！${NC}"
    ./scripts/feeds update -a
    ./scripts/feeds install -a
    echo -e "${MAIN_COLOR}update和install已完成运行，请按任意键返回！${NC}"
    press_any_key
}

# 获取插件版本信息
get_plugin_version() {
    local makefile_path=$1
    if [ -f "$makefile_path" ]; then
        cat "$makefile_path" | grep -e "PKG_VERSION:" -e "PKG_RELEASE:" | head -2
    else
        echo "文件不存在"
    fi
}

# 获取远程版本信息
get_remote_version() {
    local url=$1
    wget -qO- "$url" 2>/dev/null | grep -e "PKG_VERSION:" -e "PKG_RELEASE:" | head -2
}

# 比较版本
compare_versions() {
    local local_version=$1
    local remote_version=$2
    
    if [ "$local_version" = "$remote_version" ]; then
        return 0  # 相同
    else
        return 1  # 不同
    fi
}

# 处理accesscontrol插件
handle_accesscontrol_plugin() {
    if ! check_openwrt_dir; then
        echo -e "${RED}当前路径未在OpenWRT源码目录中，请返回选择进入源码目录！${NC}"
        press_any_key
        return
    fi
    
    local makefile_path="./feeds/luci/applications/luci-app-accesscontrol/Makefile"
    
    if [ ! -f "$makefile_path" ]; then
        echo -e "${MAIN_COLOR}accesscontrol插件不存在,是否下载安装？[y/n]${NC}"
        read choice
        if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
            find . -type d -name "*accesscontrol" -exec rm -rf {} \; 2>/dev/null
            git clone https://github.com/aige168/luci-app-accesscontrol.git ./feeds/luci/applications/luci-app-accesscontrol
            local local_version=$(get_plugin_version "$makefile_path")
            echo -e "${MAIN_COLOR}accesscontrol插件源码已下载，请返回执行update和install${NC}"
            echo -e "${MAIN_COLOR}当前源码中accesscontrol插件的版本：${NC}"
            echo "$local_version"
        fi
        press_any_key
        return
    fi
    
    local local_version=$(get_plugin_version "$makefile_path")
    echo -e "${MAIN_COLOR}当前源码中accesscontrol插件的版本：${NC}"
    echo "$local_version"
    
    local remote_version=$(get_remote_version "https://raw.githubusercontent.com/aige168/luci-app-accesscontrol/refs/heads/main/Makefile")
    echo -e "${MAIN_COLOR}远程仓库中accesscontrol插件的最新版本：${NC}"
    echo "$remote_version"
    
    if compare_versions "$local_version" "$remote_version"; then
        echo -e "${MAIN_COLOR}accesscontrol插件已是最新版本，无需升级!${NC}"
    else
        echo -e "${MAIN_COLOR}是否将accesscontrol插件升级到最新版本？[y/n]${NC}"
        read choice
        if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
            find . -type d -name "*accesscontrol" -exec rm -rf {} \; 2>/dev/null
            git clone https://github.com/aige168/luci-app-accesscontrol.git ./feeds/luci/applications/luci-app-accesscontrol
            local new_version=$(get_plugin_version "$makefile_path")
            echo -e "${MAIN_COLOR}升级后源码中accesscontrol插件的版本：${NC}"
            echo "$new_version"
            echo -e "${MAIN_COLOR}accesscontrol插件已升级到最新版本，请返回执行update和install${NC}"
        fi
    fi
    press_any_key
}

# 处理argon主题插件
handle_argon_plugin() {
    if ! check_openwrt_dir; then
        echo -e "${RED}当前路径未在OpenWRT源码目录中，请返回选择进入源码目录！${NC}"
        press_any_key
        return
    fi
    
    local makefile_path="./feeds/luci/themes/luci-theme-argon/Makefile"
    
    if [ ! -f "$makefile_path" ]; then
        echo -e "${MAIN_COLOR}argon主题插件不存在,是否下载安装？[y/n]${NC}"
        read choice
        if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
            argon_version1_menu
        fi
        return
    fi
    
    local local_version=$(get_plugin_version "$makefile_path")
    echo -e "${MAIN_COLOR}当前源码中argon主题插件的版本：${NC}"
    echo "$local_version"
    
    local remote_version=$(get_remote_version "https://raw.githubusercontent.com/jerrykuku/luci-theme-argon/refs/heads/master/Makefile")
    echo -e "${MAIN_COLOR}远程仓库中argon主题插件的最新版本：${NC}"
    echo "$remote_version"
    
    if compare_versions "$local_version" "$remote_version"; then
        echo -e "${MAIN_COLOR}argon主题插件已是最新版本无需升级，但可以替换为1806版本，是否去替换？[y/n]${NC}"
        read choice
        if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
            argon_version2_menu "$remote_version"
        fi
    else
        echo -e "${MAIN_COLOR}是否将argon主题插件升级到最新版本？[y/n]${NC}"
        read choice
        if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
            argon_version2_menu "$remote_version"
        fi
    fi
}

# argon版本选择菜单1
argon_version1_menu() {
    while true; do
        show_argon_version1_menu
        read choice
        case $choice in
            1)
                find . -type d -name "*argon" -exec rm -rf {} \; 2>/dev/null
                git clone -b master https://github.com/jerrykuku/luci-theme-argon.git ./feeds/luci/themes/luci-theme-argon
                local version=$(get_plugin_version "./feeds/luci/themes/luci-theme-argon/Makefile")
                echo -e "${MAIN_COLOR}argon主题插件的master版本源码已下载，请返回执行update和install${NC}"
                echo -e "${MAIN_COLOR}当前源码中argon主题插件的版本：${NC}"
                echo "$version"
                press_any_key
                ;;
            2)
                find . -type d -name "*argon" -exec rm -rf {} \; 2>/dev/null
                git clone -b 18.06 https://github.com/jerrykuku/luci-theme-argon.git ./feeds/luci/themes/luci-theme-argon
                local version=$(get_plugin_version "./feeds/luci/themes/luci-theme-argon/Makefile")
                echo -e "${MAIN_COLOR}argon主题插件的1806—1.8.4版本源码已下载，请返回执行update和install${NC}"
                echo -e "${MAIN_COLOR}当前源码中argon主题插件的版本：${NC}"
                echo "$version"
                press_any_key
                ;;
            3)
                return
                ;;
            4)
                cleanup
                ;;
            *)
                echo -e "${RED}输入无效，请重新选择！${NC}"
                ;;
        esac
    done
}

# argon版本选择菜单2
argon_version2_menu() {
    local remote_version=$1
    while true; do
        show_argon_version2_menu "$remote_version"
        read choice
        case $choice in
            1)
                find . -type d -name "*argon" -exec rm -rf {} \; 2>/dev/null
                git clone -b master https://github.com/jerrykuku/luci-theme-argon.git ./feeds/luci/themes/luci-theme-argon
                local version=$(get_plugin_version "./feeds/luci/themes/luci-theme-argon/Makefile")
                echo -e "${MAIN_COLOR}argon主题插件已更新到最新版，请返回执行update和install${NC}"
                echo -e "${MAIN_COLOR}当前源码中argon主题插件的版本：${NC}"
                echo "$version"
                press_any_key
                ;;
            2)
                find . -type d -name "*argon" -exec rm -rf {} \; 2>/dev/null
                git clone -b 18.06 https://github.com/jerrykuku/luci-theme-argon.git ./feeds/luci/themes/luci-theme-argon
                local version=$(get_plugin_version "./feeds/luci/themes/luci-theme-argon/Makefile")
                echo -e "${MAIN_COLOR}已将当前源码中argon主题插件替换为1806—1.8.4版本，请返回执行update和install${NC}"
                echo -e "${MAIN_COLOR}当前源码中argon主题插件的版本：${NC}"
                echo "$version"
                press_any_key
                ;;
            3)
                return
                ;;
            4)
                cleanup
                ;;
            *)
                echo -e "${RED}输入无效，请重新选择！${NC}"
                ;;
        esac
    done
}

# 处理ddnsto插件
handle_ddnsto_plugin() {
    if ! check_openwrt_dir; then
        echo -e "${RED}当前路径未在OpenWRT源码目录中，请返回选择进入源码目录！${NC}"
        press_any_key
        return
    fi
    
    local ddnsto_dir=$(find . -name "luci-app-ddnsto" -type d 2>/dev/null | head -1)
    
    if [ -z "$ddnsto_dir" ]; then
        echo -e "${MAIN_COLOR}ddnsto插件不存在,是否下载安装？[y/n]${NC}"
        read choice
        if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
            find . -type d -name "*ddnsto*" -exec rm -rf {} \; 2>/dev/null
            git clone -b main https://github.com/linkease/nas-packages-luci.git package/luci-app-ddnstoX
            git clone -b master https://github.com/linkease/nas-packages.git package/luci-app-ddnsto
            local makefile_path=$(find . -name "luci-app-ddnsto" -type d 2>/dev/null | head -1)/Makefile
            if [ -f "$makefile_path" ]; then
                local version=$(get_plugin_version "$makefile_path")
                echo -e "${MAIN_COLOR}ddnsto插件源码已下载，请返回执行update和install${NC}"
                echo -e "${MAIN_COLOR}当前源码中ddnsto插件的版本：${NC}"
                echo "$version"
            fi
        fi
        press_any_key
        return
    fi
    
    local makefile_path="$ddnsto_dir/Makefile"
    local local_version=$(get_plugin_version "$makefile_path")
    echo -e "${MAIN_COLOR}当前源码中ddnsto插件的版本：${NC}"
    echo "$local_version"
    
    local remote_version=$(get_remote_version "https://raw.githubusercontent.com/linkease/nas-packages-luci/refs/heads/main/luci/luci-app-ddnsto/Makefile")
    echo -e "${MAIN_COLOR}远程仓库中ddnsto插件的最新版本：${NC}"
    echo "$remote_version"
    
    if compare_versions "$local_version" "$remote_version"; then
        echo -e "${MAIN_COLOR}ddnsto插件已是最新版本，无需升级!${NC}"
    else
        echo -e "${MAIN_COLOR}是否将ddnsto插件升级到最新版本？[y/n]${NC}"
        read choice
        if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
            find . -type d -name "*ddnsto*" -exec rm -rf {} \; 2>/dev/null
            git clone -b main https://github.com/linkease/nas-packages-luci.git package/luci-app-ddnstoX
            git clone -b master https://github.com/linkease/nas-packages.git package/luci-app-ddnsto
            local new_makefile_path=$(find . -name "luci-app-ddnsto" -type d 2>/dev/null | head -1)/Makefile
            if [ -f "$new_makefile_path" ]; then
                local new_version=$(get_plugin_version "$new_makefile_path")
                echo -e "${MAIN_COLOR}升级后源码中ddnsto插件的版本：${NC}"
                echo "$new_version"
                echo -e "${MAIN_COLOR}ddnsto插件已升级到最新版本，请返回执行update和install${NC}"
            fi
        fi
    fi
    press_any_key
}

# 处理samba4插件
handle_samba4_plugin() {
    if ! check_openwrt_dir; then
        echo -e "${RED}当前路径未在OpenWRT源码目录中，请返回选择进入源码目录！${NC}"
        press_any_key
        return
    fi
    
    local makefile_path="./feeds/packages/net/samba4/Makefile"
    
    if [ ! -f "$makefile_path" ]; then
        echo -e "${MAIN_COLOR}samba4插件不存在,是否下载安装？[y/n]${NC}"
        read choice
        if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
            samba4_version1_menu
        fi
        return
    fi
    
    local local_version=$(get_plugin_version "$makefile_path")
    echo -e "${MAIN_COLOR}当前源码中samba4插件的版本：${NC}"
    echo "$local_version"
    
    local remote_version=$(get_remote_version "https://raw.githubusercontent.com/aige168/samba4/refs/heads/main/Makefile")
    echo -e "${MAIN_COLOR}远程仓库中samba4插件的最新版本：${NC}"
    echo "$remote_version"
    
    if compare_versions "$local_version" "$remote_version"; then
        echo -e "${MAIN_COLOR}samba4插件已是最新版本无需升级，但可以替换为(v4.18.8或v4.14.14或v4.14.12)，是否进入samba4替换界面？[y/n]${NC}"
        read choice
        if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
            samba4_version2_menu "$remote_version"
        fi
    else
        echo -e "${MAIN_COLOR}是否将samba4插件升级/替换源码中的samba4旧版本？[y/n]${NC}"
        read choice
        if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
            samba4_version2_menu "$remote_version"
        fi
    fi
}

# samba4版本选择菜单1
samba4_version1_menu() {
    while true; do
        show_samba4_version1_menu
        read choice
        case $choice in
            1)
                rm -rf ./feeds/packages/net/samba4
                git clone -b 4.18.8 https://github.com/aige168/samba4 ./feeds/packages/net/samba4
                local version=$(get_plugin_version "./feeds/packages/net/samba4/Makefile")
                echo -e "${MAIN_COLOR}samba4插件的v4.18.8版本源码已下载，请返回执行update和install${NC}"
                echo -e "${MAIN_COLOR}当前源码中samba4插件的版本：${NC}"
                echo "$version"
                press_any_key
                ;;
            2)
                rm -rf ./feeds/packages/net/samba4
                git clone -b 4.14.14 https://github.com/aige168/samba4 ./feeds/packages/net/samba4
                local version=$(get_plugin_version "./feeds/packages/net/samba4/Makefile")
                echo -e "${MAIN_COLOR}samba4插件的v4.14.14版本源码已下载，请返回执行update和install${NC}"
                echo -e "${MAIN_COLOR}当前源码中samba4插件的版本：${NC}"
                echo "$version"
                press_any_key
                ;;
            3)
                rm -rf ./feeds/packages/net/samba4
                git clone -b 4.14.12 https://github.com/aige168/samba4 ./feeds/packages/net/samba4
                local version=$(get_plugin_version "./feeds/packages/net/samba4/Makefile")
                echo -e "${MAIN_COLOR}samba4插件的v4.14.12版本源码已下载，请返回执行update和install${NC}"
                echo -e "${MAIN_COLOR}当前源码中samba4插件的版本：${NC}"
                echo "$version"
                press_any_key
                ;;
            4)
                return
                ;;
            5)
                cleanup
                ;;
            *)
                echo -e "${RED}输入无效，请重新选择！${NC}"
                ;;
        esac
    done
}

# samba4版本选择菜单2
samba4_version2_menu() {
    local remote_version=$1
    while true; do
        show_samba4_version2_menu "$remote_version"
        read choice
        case $choice in
            1)
                rm -rf ./feeds/packages/net/samba4
                git clone -b main https://github.com/aige168/samba4 ./feeds/packages/net/samba4
                local version=$(get_plugin_version "./feeds/packages/net/samba4/Makefile")
                echo -e "${MAIN_COLOR}samba4插件已更新最新版本，请返回执行update和install${NC}"
                echo -e "${MAIN_COLOR}当前源码中samba4插件的版本：${NC}"
                echo "$version"
                press_any_key
                ;;
            2)
                rm -rf ./feeds/packages/net/samba4
                git clone -b 4.18.8 https://github.com/aige168/samba4 ./feeds/packages/net/samba4
                local version=$(get_plugin_version "./feeds/packages/net/samba4/Makefile")
                echo -e "${MAIN_COLOR}已将当前源码中samba4插件替换为v4.18.8版本，请返回执行update和install${NC}"
                echo -e "${MAIN_COLOR}当前源码中samba4插件的版本：${NC}"
                echo "$version"
                press_any_key
                ;;
            3)
                rm -rf ./feeds/packages/net/samba4
                git clone -b 4.14.14 https://github.com/aige168/samba4 ./feeds/packages/net/samba4
                local version=$(get_plugin_version "./feeds/packages/net/samba4/Makefile")
                echo -e "${MAIN_COLOR}已将当前源码中samba4插件替换为v4.14.14版本，请返回执行update和install${NC}"
                echo -e "${MAIN_COLOR}当前源码中samba4插件的版本：${NC}"
                echo "$version"
                press_any_key
                ;;
            4)
                rm -rf ./feeds/packages/net/samba4
                git clone -b 4.14.12 https://github.com/aige168/samba4 ./feeds/packages/net/samba4
                local version=$(get_plugin_version "./feeds/packages/net/samba4/Makefile")
                echo -e "${MAIN_COLOR}已将当前源码中samba4插件替换为v4.14.12版本，请返回执行update和install${NC}"
                echo -e "${MAIN_COLOR}当前源码中samba4插件的版本：${NC}"
                echo "$version"
                press_any_key
                ;;
            5)
                return
                ;;
            6)
                cleanup
                ;;
            *)
                echo -e "${RED}输入无效，请重新选择！${NC}"
                ;;
        esac
    done
}

# 处理serverchan插件
handle_serverchan_plugin() {
    if ! check_openwrt_dir; then
        echo -e "${RED}当前路径未在OpenWRT源码目录中，请返回选择进入源码目录！${NC}"
        press_any_key
        return
    fi
    
    local makefile_path="./feeds/luci/applications/luci-app-serverchan/Makefile"
    
    if [ ! -f "$makefile_path" ]; then
        echo -e "${MAIN_COLOR}serverchan插件不存在,是否下载安装？[y/n]${NC}"
        read choice
        if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
            find . -type d -name "*-serverchan" -exec rm -rf {} \; 2>/dev/null
            git clone -b openwrt-18.06 https://github.com/tty228/luci-app-wechatpush.git ./feeds/luci/applications/luci-app-serverchan
            local version=$(get_plugin_version "$makefile_path")
            echo -e "${MAIN_COLOR}serverchan插件源码已下载，请返回执行update和install${NC}"
            echo -e "${MAIN_COLOR}当前源码中serverchan插件的版本：${NC}"
            echo "$version"
        fi
        press_any_key
        return
    fi
    
    local local_version=$(get_plugin_version "$makefile_path")
    echo -e "${MAIN_COLOR}当前源码中serverchan插件的版本：${NC}"
    echo "$local_version"
    
    local remote_version=$(get_remote_version "https://raw.githubusercontent.com/tty228/luci-app-wechatpush/refs/heads/openwrt-18.06/Makefile")
    echo -e "${MAIN_COLOR}远程仓库中serverchan插件的最新版本：${NC}"
    echo "$remote_version"
    
    if compare_versions "$local_version" "$remote_version"; then
        echo -e "${MAIN_COLOR}serverchan插件已是最新版本，无需升级!${NC}"
    else
        echo -e "${MAIN_COLOR}是否将serverchan插件升级到最新版本？[y/n]${NC}"
        read choice
        if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
            find . -type d -name "*-serverchan" -exec rm -rf {} \; 2>/dev/null
            git clone -b openwrt-18.06 https://github.com/tty228/luci-app-wechatpush.git ./feeds/luci/applications/luci-app-serverchan
            local new_version=$(get_plugin_version "$makefile_path")
            echo -e "${MAIN_COLOR}升级后源码中serverchan插件的版本：${NC}"
            echo "$new_version"
            echo -e "${MAIN_COLOR}serverchan插件已升级到最新版本，请返回执行update和install${NC}"
        fi
    fi
    press_any_key
}

# 处理wechatpush插件
handle_wechatpush_plugin() {
    if ! check_openwrt_dir; then
        echo -e "${RED}当前路径未在OpenWRT源码目录中，请返回选择进入源码目录！${NC}"
        press_any_key
        return
    fi
    
    local makefile_path="./feeds/luci/applications/luci-app-wechatpush/Makefile"
    
    if [ ! -f "$makefile_path" ]; then
        echo -e "${MAIN_COLOR}wechatpush插件不存在,是否下载安装？[y/n]${NC}"
        read choice
        if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
            find . -type d -name "*-wechatpush" -exec rm -rf {} \; 2>/dev/null
            git clone -b master https://github.com/tty228/luci-app-wechatpush.git feeds/luci/applications/luci-app-wechatpush
            local version=$(get_plugin_version "$makefile_path")
            echo -e "${MAIN_COLOR}wechatpush插件源码已下载，请返回执行update和install${NC}"
            echo -e "${MAIN_COLOR}当前源码中wechatpush插件的版本：${NC}"
            echo "$version"
        fi
        press_any_key
        return
    fi
    
    local local_version=$(get_plugin_version "$makefile_path")
    echo -e "${MAIN_COLOR}当前源码中wechatpush插件的版本：${NC}"
    echo "$local_version"
    
    local remote_version=$(get_remote_version "https://raw.githubusercontent.com/tty228/luci-app-wechatpush/refs/heads/master/Makefile")
    echo -e "${MAIN_COLOR}远程仓库中wechatpush插件的最新版本：${NC}"
    echo "$remote_version"
    
    if compare_versions "$local_version" "$remote_version"; then
        echo -e "${MAIN_COLOR}wechatpush插件已是最新版本，无需升级!${NC}"
    else
        echo -e "${MAIN_COLOR}是否将wechatpush插件升级到最新版本？[y/n]${NC}"
        read choice
        if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
            find . -type d -name "*-wechatpush" -exec rm -rf {} \; 2>/dev/null
            git clone -b master https://github.com/tty228/luci-app-wechatpush.git feeds/luci/applications/luci-app-wechatpush
            local new_version=$(get_plugin_version "$makefile_path")
            echo -e "${MAIN_COLOR}升级后源码中wechatpush插件的版本：${NC}"
            echo "$new_version"
            echo -e "${MAIN_COLOR}wechatpush插件已升级到最新版本，请返回执行update和install${NC}"
        fi
    fi
    press_any_key
}

# 处理zerotier插件
handle_zerotier_plugin() {
    if ! check_openwrt_dir; then
        echo -e "${RED}当前路径未在OpenWRT源码目录中，请返回选择进入源码目录！${NC}"
        press_any_key
        return
    fi
    
    local makefile_path="./feeds/packages/net/zerotier/Makefile"
    
    if [ ! -f "$makefile_path" ]; then
        echo -e "${MAIN_COLOR}zerotier插件不存在,是否下载安装？[y/n]${NC}"
        read choice
        if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
            rm -rf ./feeds/packages/net/zerotier
            git clone https://github.com/aige168/zerotier ./feeds/packages/net/zerotier
            local version=$(get_plugin_version "$makefile_path")
            echo -e "${MAIN_COLOR}zerotier插件源码已下载，请返回执行update和install${NC}"
            echo -e "${MAIN_COLOR}当前源码中zerotier插件的版本：${NC}"
            echo "$version"
        fi
        press_any_key
        return
    fi
    
    local local_version=$(get_plugin_version "$makefile_path")
    echo -e "${MAIN_COLOR}当前源码中zerotier插件的版本：${NC}"
    echo "$local_version"
    
    local remote_version=$(get_remote_version "https://raw.githubusercontent.com/aige168/zerotier/refs/heads/main/Makefile")
    echo -e "${MAIN_COLOR}远程仓库中zerotier插件的最新版本：${NC}"
    echo "$remote_version"
    
    if compare_versions "$local_version" "$remote_version"; then
        echo -e "${MAIN_COLOR}zerotier插件已是最新版本，无需升级!${NC}"
    else
        echo -e "${MAIN_COLOR}是否将zerotier插件升级到最新版本？[y/n]${NC}"
        read choice
        if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
            rm -rf ./feeds/packages/net/zerotier
            git clone https://github.com/aige168/zerotier ./feeds/packages/net/zerotier
            local new_version=$(get_plugin_version "$makefile_path")
            echo -e "${MAIN_COLOR}升级后源码中zerotier插件的版本：${NC}"
            echo "$new_version"
            echo -e "${MAIN_COLOR}zerotier插件已升级到最新版本，请返回执行update和install${NC}"
        fi
    fi
    press_any_key
}

# 执行make menuconfig
run_make_menuconfig() {
    if ! check_openwrt_dir; then
        echo -e "${RED}当前路径未在OpenWRT源码目录中，请返回选择进入源码目录！${NC}"
        press_any_key
        return
    fi
    
    echo -e "${MAIN_COLOR}当前所在的源码目录：$(pwd)${NC}"
    echo -e "${MAIN_COLOR}执行make menuconfig，请自行选择架构和需要安装的插件！${NC}"
    make menuconfig
    echo -e "${MAIN_COLOR}make menuconfig已完成执行，请按任意键返回！${NC}"
    press_any_key
}

# 验证固件名称
validate_firmware_name() {
    local name=$1
    if [[ ${#name} -le 10 && "$name" =~ ^[a-zA-Z0-9]+$ ]]; then
        return 0
    fi
    return 1
}

# 修改LEDE固件配置
modify_lede_config() {
    local current_dir=$(basename "$(pwd)")
    if [[ ! "$current_dir" =~ ^lede ]]; then
        echo -e "${RED}当前路径未在LEDE源码目录中，请返回重新选择源码目录！${NC}"
        press_any_key
        return
    fi
    
    # 修改固件名称
    echo -e "${MAIN_COLOR}请输入修改后的固件名称(回车直接设为NEWIFI)：${NC}"
    read firmware_name
    if [ -z "$firmware_name" ]; then
        firmware_name="NEWIFI"
    elif ! validate_firmware_name "$firmware_name"; then
        echo -e "${RED}固件名称格式不正确！${NC}"
        press_any_key
        return
    fi
    
    sed -i "s/LEDE/$firmware_name/g" package/base-files/luci2/bin/config_generate
    echo -e "${MAIN_COLOR}已将固件名称修改为：$firmware_name${NC}"
    sleep 2
    
    # 修改IP地址
    while true; do
        echo -e "${MAIN_COLOR}请输入修改后的固件IP地址(回车直接设为192.168.99.1)：${NC}"
        read ip_address
        if [ -z "$ip_address" ]; then
            ip_address="192.168.99.1"
            break
        elif validate_ip "$ip_address"; then
            break
        else
            echo -e "${RED}IP地址错误，请重新输入：${NC}"
        fi
    done
    
    sed -i "s/192.168.1.1/$ip_address/g" package/base-files/luci2/bin/config_generate
    echo -e "${MAIN_COLOR}已将固件IP地址修改为：$ip_address${NC}"
    sleep 2
    
    # 修改主题
    echo -e "${MAIN_COLOR}正在设置主题，将主题bootstrap修改为argon${NC}"
    sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' ./feeds/luci/collections/luci-light/Makefile
    sed -i 's/CONFIG_PACKAGE_luci-theme-bootstrap=y/CONFIG_PACKAGE_luci-theme-bootstrap=n/g' ./.config 2>/dev/null
    echo -e "${MAIN_COLOR}已将主题bootstrap修改为argon！${NC}"
    sleep 2
    
    # 修改时区
    echo -e "${MAIN_COLOR}正在设置时区，将UTC时区修改为CST-8时区${NC}"
    sed -i 's/UTC/CST-8/g' package/base-files/luci2/bin/config_generate
    echo -e "${MAIN_COLOR}已将UTC时区修改为CST-8时区！${NC}"
    sleep 2
    
    # 修改NAS名称
    echo -e "${MAIN_COLOR}正在设置Nas名称，将Nas名称修改为网络存储，需要等待一会${NC}"
    sed -i 's/"NAS"/"网络存储"/g' $(grep "NAS" -rl ./ 2>/dev/null)
    echo -e "${MAIN_COLOR}已将Nas名称修改为网络存储！${NC}"
    echo -e "${MAIN_COLOR}所有参数全部修改完成，按任意键返回！${NC}"
    press_any_key
}

# 修改immortalwrt1806固件配置
modify_immortalwrt1806_config() {
    local current_dir=$(basename "$(pwd)")
    if [[ ! "$current_dir" =~ immortalwrt1806 ]]; then
        echo -e "${RED}当前路径未在immortalwrt1806或immortalwrt1806k54源码目录中，请返回重新选择源码目录！${NC}"
        press_any_key
        return
    fi
    
    # 修改固件名称
    echo -e "${MAIN_COLOR}请输入修改后的固件名称(回车直接设为NEWIFI)：${NC}"
    read firmware_name
    if [ -z "$firmware_name" ]; then
        firmware_name="NEWIFI"
    elif ! validate_firmware_name "$firmware_name"; then
        echo -e "${RED}固件名称格式不正确！${NC}"
        press_any_key
        return
    fi
    
    sed -i "s/ImmortalWrt/$firmware_name/g" package/base-files/files/bin/config_generate
    echo -e "${MAIN_COLOR}已将固件名称修改为：$firmware_name${NC}"
    sleep 2
    
    # 修改IP地址
    while true; do
        echo -e "${MAIN_COLOR}请输入修改后的固件IP地址(回车直接设为192.168.99.1)：${NC}"
        read ip_address
        if [ -z "$ip_address" ]; then
            ip_address="192.168.99.1"
            break
        elif validate_ip "$ip_address"; then
            break
        else
            echo -e "${RED}IP地址错误，请重新输入：${NC}"
        fi
    done
    
    sed -i "s/192.168.1.1/$ip_address/g" package/base-files/files/bin/config_generate
    echo -e "${MAIN_COLOR}已将固件IP地址修改为：$ip_address${NC}"
    sleep 2
    
    # 修改主题
    echo -e "${MAIN_COLOR}正在设置主题，将主题bootstrap修改为argon${NC}"
    sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' ./feeds/luci/collections/luci/Makefile
    sed -i 's/CONFIG_PACKAGE_luci-theme-bootstrap=y/CONFIG_PACKAGE_luci-theme-bootstrap=n/g' ./.config 2>/dev/null
    echo -e "${MAIN_COLOR}已将主题bootstrap修改为argon！${NC}"
    sleep 2
    
    # 修改时区
    echo -e "${MAIN_COLOR}正在设置时区，将UTC时区修改为CST-8时区${NC}"
    sed -i 's/UTC/CST-8/g' package/base-files/files/bin/config_generate
    echo -e "${MAIN_COLOR}已将UTC时区修改为CST-8时区！${NC}"
    sleep 2
    
    # 修改NAS名称
    echo -e "${MAIN_COLOR}正在设置Nas名称，将Nas名称修改为网络存储，需要等待一会${NC}"
    sed -i 's/"NAS"/"网络存储"/g' $(grep "NAS" -rl ./ 2>/dev/null)
    echo -e "${MAIN_COLOR}已将Nas名称修改为网络存储！${NC}"
    echo -e "${MAIN_COLOR}所有参数全部修改完成，按任意键返回！${NC}"
    press_any_key
}

# 修改immortalwrt2102+固件配置
modify_immortalwrt2102_config() {
    local current_dir=$(basename "$(pwd)")
    if [[ ! "$current_dir" =~ immortalwrt21 ]] && [[ ! "$current_dir" =~ immortalwrt23 ]] && [[ ! "$current_dir" =~ immortalwrt24 ]]; then
        echo -e "${RED}当前路径未在immortalwrt2102、immortalwrt2305、immortalwrt2410源码目录中，请返回重新选择源码目录！${NC}"
        press_any_key
        return
    fi
    
    # 修改固件名称
    echo -e "${MAIN_COLOR}请输入修改后的固件名称(回车直接设为NEWIFI)：${NC}"
    read firmware_name
    if [ -z "$firmware_name" ]; then
        firmware_name="NEWIFI"
    elif ! validate_firmware_name "$firmware_name"; then
        echo -e "${RED}固件名称格式不正确！${NC}"
        press_any_key
        return
    fi
    
    sed -i "s/ImmortalWrt/$firmware_name/g" package/base-files/files/bin/config_generate
    echo -e "${MAIN_COLOR}已将固件名称修改为：$firmware_name${NC}"
    sleep 2
    
    # 修改IP地址
    while true; do
        echo -e "${MAIN_COLOR}请输入修改后的固件IP地址(回车直接设为192.168.99.1)：${NC}"
        read ip_address
        if [ -z "$ip_address" ]; then
            ip_address="192.168.99.1"
            break
        elif validate_ip "$ip_address"; then
            break
        else
            echo -e "${RED}IP地址错误，请重新输入：${NC}"
        fi
    done
    
    sed -i "s/192.168.1.1/$ip_address/g" package/base-files/files/bin/config_generate
    echo -e "${MAIN_COLOR}已将固件IP地址修改为：$ip_address${NC}"
    sleep 2
    
    # 修改主题
    echo -e "${MAIN_COLOR}正在设置主题，将主题bootstrap修改为argon${NC}"
    sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' ./feeds/luci/collections/luci-light/Makefile
    sed -i 's/CONFIG_PACKAGE_luci-theme-bootstrap=y/CONFIG_PACKAGE_luci-theme-bootstrap=n/g' ./.config 2>/dev/null
    echo -e "${MAIN_COLOR}已将主题bootstrap修改为argon！${NC}"
    sleep 2
    
    # 修改时区
    echo -e "${MAIN_COLOR}正在设置时区，将UTC时区修改为CST-8时区${NC}"
    sed -i 's/UTC/CST-8/g' package/base-files/files/bin/config_generate
    echo -e "${MAIN_COLOR}已将UTC时区修改为CST-8时区！${NC}"
    sleep 2
    
    # 修改NAS名称
    echo -e "${MAIN_COLOR}正在设置Nas名称，将Nas名称修改为网络存储，需要等待一会${NC}"
    sed -i 's/"NAS"/"网络存储"/g' $(grep "NAS" -rl ./ 2>/dev/null)
    echo -e "${MAIN_COLOR}已将Nas名称修改为网络存储！${NC}"
    echo -e "${MAIN_COLOR}所有参数全部修改完成，按任意键返回！${NC}"
    press_any_key
}

# 执行make download
run_make_download() {
    if ! check_openwrt_dir; then
        echo -e "${RED}当前路径未在OpenWRT源码目录中，请返回选择进入源码目录！${NC}"
        press_any_key
        return
    fi
    
    echo -e "${MAIN_COLOR}当前所在的源码目录：$(pwd)${NC}"
    echo -e "${MAIN_COLOR}执行make download，开始下载DL文件！${NC}"
    make download V=s -j8
    
    if [ -d "dl" ]; then
        local dl_size=$(du -sh dl | cut -f1)
        echo -e "${MAIN_COLOR}当前源码中DL文件夹大小：$dl_size${NC}"
    fi
    
    echo -e "${MAIN_COLOR}DL文件已下载1次，是否进行第2次下载，确保DL下载完整？[y/n]${NC}"
    read choice
    if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
        make download V=s -j1
        if [ -d "dl" ]; then
            local dl_size=$(du -sh dl | cut -f1)
            echo -e "${MAIN_COLOR}当前源码中DL文件夹大小：$dl_size${NC}"
        fi
    fi
    press_any_key
}

# 执行编译
run_make_compile() {
    if ! check_openwrt_dir; then
        echo -e "${RED}当前路径未在OpenWRT源码目录中，请返回选择进入源码目录！${NC}"
        press_any_key
        return
    fi
    
    echo -e "${MAIN_COLOR}当前所在的源码目录：$(pwd)${NC}"
    echo -e "${MAIN_COLOR}开始编译固件，大约需要1—3小时！${NC}"
    
    while true; do
        echo -e "${MAIN_COLOR}请输入编译使用的线程数：${NC}"
        read threads
        if [[ "$threads" =~ ^[0-9]+$ ]] && [ "$threads" -ge 1 ] && [ "$threads" -le 32 ]; then
            break
        else
            echo -e "${RED}请输入1-32之间的数字！${NC}"
        fi
    done
    
    echo -e "${MAIN_COLOR}开始使用make V=s -j$threads编译固件！${NC}"
    make V=s -j"$threads"
    
    if [ $? -eq 0 ]; then
        # 查找编译生成的固件文件
        local bin_path=$(find . -name "bin" -type d 2>/dev/null | head -1)
        if [ -n "$bin_path" ]; then
            echo -e "${MAIN_COLOR}固件编译成功，固件bin文件在：$(realpath $bin_path)${NC}"
        else
            echo -e "${MAIN_COLOR}固件编译成功！${NC}"
        fi
    else
        echo -e "${RED}编译报错或失败，请手动检查错误！${NC}"
    fi
    press_any_key
}

# 主菜单处理
main_menu() {
    while true; do
        show_main_menu
        read choice
        case $choice in
            1)
                dependency_menu
                ;;
            2)
                python_menu
                ;;
            3)
                source_download_menu
                ;;
            4)
                compile_menu
                ;;
            5|6|7|8)
                echo -e "${RED}功能暂未实现${NC}"
                press_any_key
                ;;
            9)
                cleanup
                ;;
            *)
                echo -e "${RED}输入无效，请重新选择！${NC}"
                ;;
        esac
    done
}

# 依赖环境菜单
dependency_menu() {
    while true; do
        show_dependency_menu
        read choice
        case $choice in
            1)
                install_dependencies
                ;;
            2)
                set_force_unsafe_configure
                ;;
            3)
                proxy_menu
                ;;
            4)
                return
                ;;
            5)
                cleanup
                ;;
            *)
                echo -e "${RED}输入无效，请重新选择！${NC}"
                ;;
        esac
    done
}

# 代理设置菜单
proxy_menu() {
    while true; do
        show_proxy_menu
        read choice
        case $choice in
            1)
                set_temp_proxy
                ;;
            2)
                set_perm_proxy
                ;;
            3)
                clear_proxy_settings
                ;;
            4)
                return
                ;;
            5)
                cleanup
                ;;
            *)
                echo -e "${RED}输入无效，请重新选择！${NC}"
                ;;
        esac
    done
}

# Python菜单
python_menu() {
    while true; do
        show_python_menu
        read choice
        case $choice in
            1)
                check_python_version
                ;;
            2)
                python_version_menu
                ;;
            3)
                return
                ;;
            4)
                cleanup
                ;;
            *)
                echo -e "${RED}输入无效，请重新选择！${NC}"
                ;;
        esac
    done
}

# Python版本选择菜单
python_version_menu() {
    while true; do
        show_python_version_menu
        read choice
        case $choice in
            1)
                install_python_version "3.10.9" "3.10"
                ;;
            2)
                install_python_version "3.10.6" "3.10"
                ;;
            3)
                install_python_version "3.9.6" "3.9"
                ;;
            4)
                install_python_version "3.8.9" "3.8"
                ;;
            5)
                install_python_version "3.7.9" "3.7"
                ;;
            6)
                install_python_version "3.6.9" "3.6"
                ;;
            7)
                return
                ;;
            8)
                cleanup
                ;;
            *)
                echo -e "${RED}输入无效，请重新选择！${NC}"
                ;;
        esac
    done
}

# 源码下载菜单
source_download_menu() {
    while true; do
        show_source_menu
        read choice
        case $choice in
            1)
                lede_download_menu
                ;;
            2)
                immortalwrt_download_menu
                ;;
            3)
                return
                ;;
            4)
                cleanup
                ;;
            *)
                echo -e "${RED}输入无效，请重新选择！${NC}"
                ;;
        esac
    done
}

# LEDE下载菜单
lede_download_menu() {
    while true; do
        show_lede_menu
        read choice
        case $choice in
            1)
                download_lede_current
                ;;
            2)
                download_lede_custom
                ;;
            3)
                return
                ;;
            4)
                cleanup
                ;;
            *)
                echo -e "${RED}输入无效，请重新选择！${NC}"
                ;;
        esac
    done
}

# immortalwrt下载菜单
immortalwrt_download_menu() {
    while true; do
        show_immortalwrt_menu
        read choice
        case $choice in
            1)
                immortalwrt_version_menu "current"
                ;;
            2)
                while true; do
                    echo -e "${MAIN_COLOR}请输入immortalwrt源码的下载路径（输入绝对路径：/root或/home）：${NC}"
                    read custom_path
                    if [ "$custom_path" = "/root" ] || [ "$custom_path" = "/home" ]; then
                        echo -e "${MAIN_COLOR}immortalwrt源码将下载到：$custom_path${NC}"
                        sleep 3
                        immortalwrt_version_menu "$custom_path"
                        break
                    else
                        echo -e "${RED}请输入绝对路径：/root或/home${NC}"
                        press_any_key
                        break
                    fi
                done
                ;;
            3)
                return
                ;;
            4)
                cleanup
                ;;
            *)
                echo -e "${RED}输入无效，请重新选择！${NC}"
                ;;
        esac
    done
}

# immortalwrt版本选择菜单
immortalwrt_version_menu() {
    local download_path=$1
    while true; do
        show_immortalwrt_version_menu
        read choice
        case $choice in
            1)
                if [ "$download_path" = "current" ]; then
                    download_immortalwrt "openwrt-18.06-k5.4" "immortalwrt1806k54"
                else
                    download_immortalwrt_custom "$download_path" "openwrt-18.06-k5.4" "immortalwrt1806k54"
                fi
                ;;
            2)
                if [ "$download_path" = "current" ]; then
                    download_immortalwrt "openwrt-18.06" "immortalwrt1806"
                else
                    download_immortalwrt_custom "$download_path" "openwrt-18.06" "immortalwrt1806"
                fi
                ;;
            3)
                if [ "$download_path" = "current" ]; then
                    download_immortalwrt "openwrt-21.02" "immortalwrt2102"
                else
                    download_immortalwrt_custom "$download_path" "openwrt-21.02" "immortalwrt2102"
                fi
                ;;
            4)
                if [ "$download_path" = "current" ]; then
                    download_immortalwrt "openwrt-23.05" "immortalwrt2305"
                else
                    download_immortalwrt_custom "$download_path" "openwrt-23.05" "immortalwrt2305"
                fi
                ;;
            5)
                if [ "$download_path" = "current" ]; then
                    download_immortalwrt "openwrt-24.10" "immortalwrt2410"
                else
                    download_immortalwrt_custom "$download_path" "openwrt-24.10" "immortalwrt2410"
                fi
                ;;
            6)
                return
                ;;
            7)
                cleanup
                ;;
            *)
                echo -e "${RED}输入无效，请重新选择！${NC}"
                ;;
        esac
    done
}

# 编译菜单
compile_menu() {
    while true; do
        show_compile_menu
        read choice
        case $choice in
            1)
                show_source_dir_menu
                ;;
            2)
                replace_curl_with_wget
                ;;
            3)
                add_kenzok8_feeds
                ;;
            4)
                run_feeds_update_install
                ;;
            5)
                plugin_menu
                ;;
            6)
                run_feeds_update_install
                ;;
            7)
                run_make_menuconfig
                ;;
            8)
                firmware_config_menu
                ;;
            9)
                run_make_download
                ;;
            10)
                run_make_compile
                ;;
            11)
                return
                ;;
            12)
                cleanup
                ;;
            *)
                echo -e "${RED}输入无效，请重新选择！${NC}"
                ;;
        esac
    done
}

# 插件菜单
plugin_menu() {
    while true; do
        show_plugin_menu
        read choice
        case $choice in
            1)
                handle_accesscontrol_plugin
                ;;
            2)
                handle_argon_plugin
                ;;
            3)
                handle_ddnsto_plugin
                ;;
            4)
                handle_samba4_plugin
                ;;
            5)
                handle_serverchan_plugin
                ;;
            6)
                handle_wechatpush_plugin
                ;;
            7)
                handle_zerotier_plugin
                ;;
            8)
                return
                ;;
            9)
                cleanup
                ;;
            *)
                echo -e "${RED}输入无效，请重新选择！${NC}"
                ;;
        esac
    done
}

# 固件配置菜单
firmware_config_menu() {
    while true; do
        show_firmware_config_menu
        read choice
        case $choice in
            1)
                modify_lede_config
                ;;
            2)
                modify_immortalwrt1806_config
                ;;
            3)
                modify_immortalwrt2102_config
                ;;
            4)
                return
                ;;
            5)
                cleanup
                ;;
            *)
                echo -e "${RED}输入无效，请重新选择！${NC}"
                ;;
        esac
    done
}

# 脚本入口
main() {
    clear
    echo -e "${MAIN_COLOR}欢迎使用自编译OpenWRT固件脚本！${NC}"
    sleep 2
    main_menu
}

# 启动脚本
main
