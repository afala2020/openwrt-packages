#!/usr/bin/env bash

# 定义颜色
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
RESET="\033[0m"

# 检测是否具有 root 权限
[[ $EUID -ne 0 ]] && echo -e "${RED}错误: 请先运行 sudo -i 获取 root 权限后再执行此脚本${RESET}" && exit 1

# 解锁服务函数
unlock_services() {
    echo -e "${YELLOW}[4/5] 正在解除 SSH 和 Docker 服务的锁定，启用密码访问...${RESET}"
    systemctl unmask ssh containerd docker.socket docker
    pkill dockerd
    pkill containerd
    systemctl start ssh containerd docker.socket docker &>/dev/null
}

# SSH 配置函数
configure_ssh() {
  echo -e "${YELLOW}[2/5] 正在终止现有的 SSH 进程...${RESET}"
  lsof -i:22 | awk '/IPv4/{print $2}' | xargs kill -9 2>/dev/null || true

  echo -e "${YELLOW}[3/5] 正在配置 SSH 服务，允许 root 登录和密码认证...${RESET}"

  # 检查并配置 root 登录
  ! grep -q "^PermitRootLogin yes" /etc/ssh/sshd_config && echo -e '\nPermitRootLogin yes' >> /etc/ssh/sshd_config

  # 检查并配置密码认证
  ! grep -q "^PasswordAuthentication yes" /etc/ssh/sshd_config && echo -e '\nPasswordAuthentication yes' >> /etc/ssh/sshd_config

  echo root:$PASSWORD | chpasswd
}

echo -e "${YELLOW}[1/5] 获取必要信息...${RESET}"
# 获取密码，确保至少5位且不为空
while true; do
  read -p "请输入root密码 (至少5位): " PASSWORD
  if [[ -z "$PASSWORD" ]]; then
    echo -e "${RED}错误: 密码不能为空，请重新输入${RESET}"
  elif [[ ${#PASSWORD} -lt 5 ]]; then
    echo -e "${RED}错误: 密码长度不足5位，请重新输入${RESET}"
  else
    break
  fi
done

    configure_ssh

    unlock_services

# 下载并安装cpolar
echo "开始安装cpolar..."
curl -L https://www.cpolar.com/static/downloads/install-release-cpolar.sh | sudo bash

# 配置认证token（替换123456789为你的实际token）
echo "配置token..."
cpolar authtoken NDBjNmY2NGMtNzRhNS00Njg0LThlNDAtMjNmNjNlMDlmNWIw

# 设置开机启动并启动服务
echo "配置系统服务..."
sudo systemctl enable cpolar
sudo systemctl start cpolar

# 强制终止占用4040端口的旧cpolar进程（解决端口冲突）
echo "检查并释放4040端口..."
sudo pkill -f "cpolar http 4040"  # 终止默认的Web管理进程（如有）
sleep 2  # 等待进程释放端口

# 后台启动SSH隧道并指定不同的Web管理端口（例如4041防止冲突）
echo "启动SSH隧道..."
nohup cpolar tcp 22 --config=localhost:4041 > cpolar_ssh.log 2>&1 &

# 动态检测隧道地址（优化匹配规则）
max_retries=15
count=0
public_url=""

echo -n "等待隧道初始化..."
while [ $count -lt $max_retries ] && [ -z "$public_url" ]; do
    sleep 3
    public_url=$(grep -oP "Forwarding\s+tcp://\K[^ ]+" cpolar_ssh.log | head -n 1)
    echo -n "."
    count=$((count+1))
done
echo ""  # 换行

# 验证结果
if [ -z "$public_url" ]; then
    echo "错误：隧道启动失败，请检查日志！" >&2
    echo "可能原因："
    echo "1. 本地4040/4041端口仍被占用（尝试重启系统）"
    echo "2. AuthToken未正确配置"
    echo "3. 网络连接异常"
    exit 1
else
    # 提取地址和端口
    host=$(echo "$public_url" | cut -d':' -f1)
    port=$(echo "$public_url" | cut -d':' -f2)
    
    # 终端高亮显示
    echo "================================================"
    echo -e "SSH公网代理地址: \033[32m$host\033[0m"
    echo -e "端口号: \033[32m$port\033[0m"
    echo "================================================"
    echo -e "连接命令: \033[33mssh -p $port 用户名@$host\033[0m"
fi
