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

# 后台静默启动SSH隧道并将输出重定向到日志文件
echo "正在后台启动SSH隧道..."
nohup cpolar tcp 22 > cpolar_ssh.log 2>&1 &
sleep 15  # 等待隧道信息生成

# 等待隧道信息生成（动态检测日志内容）
max_retries=10
count=0
public_url=""

while [ $count -lt $max_retries ] && [ -z "$public_url" ]; do
    sleep 5
    public_url=$(grep -oP "tcp://\K[0-9a-z.-]+:[0-9]+" cpolar_ssh.log | head -n 1)
    count=$((count+1))
done

# 检查是否成功获取地址
if [ -z "$public_url" ]; then
    echo "错误：隧道地址获取失败，请检查日志文件 cpolar_ssh.log" >&2
    exit 1
else
    # 提取主机名和端口
    hostname=$(echo "$public_url" | cut -d':' -f1)
    port=$(echo "$public_url" | cut -d':' -f2)
    
    # 格式化输出
    echo "========================================"
    echo "SSH公网代理已启动"
    echo "公网地址: $hostname"
    echo "端口号  : $port"
    echo "========================================"
    echo "连接示例:"
    echo "ssh -p $port 用户名@$hostname"
fi
