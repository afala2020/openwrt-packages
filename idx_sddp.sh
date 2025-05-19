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

  echo root:admin@123 | chpasswd
}

echo -e "${YELLOW}[1/4] 获取必要信息...${RESET}"

configure_ssh

unlock_services

echo -e "${YELLOW}开始配置export FORCE...${RESET}"
# 定义要添加的配置行
CONFIG_LINE="export FORCE_UNSAFE_CONFIGURE=1"

# 检查配置是否已存在
if grep -Fxq "$CONFIG_LINE" /etc/profile; then
  echo "export FORCE配置已添加，无需重复添加。"
else
  # 追加配置到/etc/profile
  echo "$CONFIG_LINE" >> /etc/profile
  echo "export FORCE配置已成功写入/etc/profile文件!"
fi

# 立即生效当前会话环境变量
source /etc/profile

echo -e "${YELLOW}开始安装docker-p2p...${RESET}"
# 如果容器存在，先删除旧容器
if docker ps -a | grep -q "openp2p-client"; then
  docker rm -f openp2p-client || true
fi
# 开始启动容器
docker run -d --privileged --cap-add=NET_ADMIN --device=/dev/net/tun --restart=always --net host --name openp2p-client -e OPENP2P_TOKEN=15101489744091613018 openp2pcn/openp2p-client:3.24.10 && echo 1 > /proc/sys/net/ipv4/ip_forward && iptables -t filter -I FORWARD -i optun -j ACCEPT && iptables -t filter -I FORWARD -o optun -j ACCEPT
sleep 3
echo -e "${YELLOW}docker-p2p已安装完成...${RESET}"
sleep 3

echo -e "${YELLOW}开始安装Python...${RESET}"
cd /home
# wget https://www.python.org/ftp/python/3.10.9/Python-3.10.9.tar.xz
# tar -Jxvf Python-3.10.9.tar.xz
cd /home/Python-3.10.9
sudo ./configure --enable-optimizations && \
sudo make altinstall -j8
sleep 3

ls /usr/bin/ | grep python
ls /usr/local/bin/ | grep python

sudo update-alternatives --install /usr/bin/python python /usr/local/bin/python3.10 300
sudo update-alternatives --install /usr/bin/python3 python3 /usr/local/bin/python3.10 300
sudo update-alternatives --auto python
sudo update-alternatives --auto python3
echo -e "${YELLOW}Python版本：${RESET}"
python -V
echo -e "${YELLOW}Python3版本：${RESET}"
python3 -V

