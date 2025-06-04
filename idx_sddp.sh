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

# 解锁SSH服务和允许root用户登录、允许用户使用密码登录
configure_ssh() {
  echo -e "${YELLOW}[2/4] 正在终止现有的 SSH 进程...${RESET}"
  lsof -i:22 | awk '/IPv4/{print $2}' | xargs kill -9 2>/dev/null || true

  echo -e "${YELLOW}[3/4] 正在配置 SSH 服务，允许 root 用户登录和密码认证...${RESET}"

  # 检查并设置允许 root 用户登录
  ! grep -q "^PermitRootLogin yes" /etc/ssh/sshd_config && echo -e '\nPermitRootLogin yes' >> /etc/ssh/sshd_config

  # 检查并设置 用户 允许密码登录
  ! grep -q "^PasswordAuthentication yes" /etc/ssh/sshd_config && echo -e '\nPasswordAuthentication yes' >> /etc/ssh/sshd_config

  echo root:admin@123 | chpasswd
}

echo -e "${YELLOW}[1/4] 获取必要信息...${RESET}"

configure_ssh

unlock_services

echo -e "${YELLOW}开始将FORCE_UNSAFE_CONFIGURE=1 写入/etc/profile文件...${RESET}"
# 定义要添加的配置行
CONFIG_LINE="export FORCE_UNSAFE_CONFIGURE=1"

# 检查配置是否已存在
if grep -Fxq "$CONFIG_LINE" /etc/profile; then
  echo "FORCE_UNSAFE_CONFIGURE=1 已在/etc/profile文件中，无需重复写入！"
else
  # 追加配置到/etc/profile
  echo "$CONFIG_LINE" >> /etc/profile
  echo "FORCE_UNSAFE_CONFIGURE=1 配置已成功写入/etc/profile文件!"
fi
sudo echo 'set number' >> /etc/vim/vimrc
# 立即生效当前会话环境变量
source /etc/profile

# 运行 P2P 容器
echo -e "${YELLOW}开始安装docker-P2P...${RESET}"
# 如果容器存在，先删除旧的p2p容器
if docker ps -a | grep -q "openp2p-client"; then
  docker rm -f openp2p-client || true
fi
# 开始启动 P2P 容器
# docker run -d --privileged --cap-add=NET_ADMIN --device=/dev/net/tun --restart=always --net host --name openp2p-client -e OPENP2P_TOKEN=15101489744091613018 openp2pcn/openp2p-client:3.24.13 && echo 1 > /proc/sys/net/ipv4/ip_forward && iptables -t filter -I FORWARD -i optun -j ACCEPT && iptables -t filter -I FORWARD -o optun -j ACCEPT
docker run -d --privileged --cap-add=NET_ADMIN --device=/dev/net/tun --restart=always --net host --name openp2p-client -e OPENP2P_TOKEN=15101489744091613018 openp2pcn/openp2p-client:3.24.10 && echo 1 > /proc/sys/net/ipv4/ip_forward && iptables -t filter -I FORWARD -i optun -j ACCEPT && iptables -t filter -I FORWARD -o optun -j ACCEPT
sleep 3
# 检查 P2P 容器是否启动成功
if ! docker ps | grep -q openp2p-client; then
  echo -e "${RED}错误: P2P容器启动失败，请检查 Docker 是否正常运行${RESET}"
  exit 1
fi
echo -e "${YELLOW}-----docker-P2P已安装完成...${RESET}"
sleep 3

# 运行 Firefox 容器
# echo -e "${YELLOW}正在安装Firefox容器，以方便IDX保活...${RESET}"
# 如果容器存在，先删除旧firefox容器
# docker rm -f firefox 2>/dev/null || true
# docker run -d \
#  --name firefox \
#  -p 5800:5800 \
#  -v /home/firefox-data:/config:rw \
#  -e FF_OPEN_URL=https://idx.google.com/ \
#  -e TZ=Asia/Shanghai \
#  -e LANG=zh_CN.UTF-8 \
#  -e ENABLE_CJK_FONT=1 \
#  --restart unless-stopped \
#  jlesage/firefox
# sleep 3
# 检查Firefox容器是否启动成功
# if ! docker ps | grep -q firefox; then
#  echo -e "${RED}错误: Firefox 容器启动失败，请检查 Docker 是否正常运行${RESET}"
#  exit 1
# fi
# echo -e "${YELLOW}-----Firefox容器已安装完成...${RESET}"

sleep 3
echo -e "${YELLOW}开始安装Python3.10.6...${RESET}"
cd /home && \
rm -rf Python*
wget https://www.python.org/ftp/python/3.10.6/Python-3.10.6.tar.xz
tar -Jxvf Python-3.10.6.tar.xz && \
rm -rf Python-*.tar.xz
cd /home/Python-3.10.6
sudo ./configure --enable-optimizations && \
sudo make altinstall -j10
sleep 3
rm -rf /home/Python*
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

sleep 5
echo -e "${YELLOW}-----开始安装OpenWRT依赖环境包...${RESET}"
bash <(wget -qO- https://raw.githubusercontent.com/afala2020/openwrt-packages/refs/heads/main/yilai.sh)
