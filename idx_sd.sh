#!/usr/bin/env bash

# 定义颜色
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
RESET="\033[0m"

# 检测是否具有 root 权限
[[ $EUID -ne 0 ]] && echo -e "${RED}错误: 请先运行 sudo -i 获取 root 权限后再执行此脚本${RESET}" && exit 1

# 解锁docker服务
unlock_services() {
    echo -e "${YELLOW}[4/4] 正在解除 SSH 和 Docker 服务的锁定，启用密码访问...${RESET}"
    systemctl unmask ssh containerd docker.socket docker
    pkill dockerd
    pkill containerd
    systemctl start ssh containerd docker.socket docker &>/dev/null
}

# SSH 登录配置
configure_ssh() {
  echo -e "${YELLOW}[2/4] 正在终止现有的 SSH 进程...${RESET}"
  lsof -i:22 | awk '/IPv4/{print $2}' | xargs kill -9 2>/dev/null || true

  echo -e "${YELLOW}[3/4] 正在配置 SSH 服务，允许 root 登录和密码认证...${RESET}"

  # 检查并配置 root 登录
  ! grep -q "^PermitRootLogin yes" /etc/ssh/sshd_config && echo -e '\nPermitRootLogin yes' >> /etc/ssh/sshd_config

  # 检查并配置密码认证
  ! grep -q "^PasswordAuthentication yes" /etc/ssh/sshd_config && echo -e '\nPasswordAuthentication yes' >> /etc/ssh/sshd_config

  echo root:$PASSWORD | chpasswd
}

echo -e "${YELLOW}[1/4] 获取必要信息...${RESET}"
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

# 定义要添加的配置行
CONFIG_LINE="export FORCE_UNSAFE_CONFIGURE=1"

# 检查配置是否已存在
if grep -Fxq "$CONFIG_LINE" /etc/profile; then
  echo "export FORCE配置已添加，无需重复添加。"
else
  # 追加配置到/etc/profile
  echo "$CONFIG_LINE" >> /etc/profile
  echo "export FORCE配置已成功写入/etc/profile。"
fi

# 立即生效当前会话环境变量
source /etc/profile

