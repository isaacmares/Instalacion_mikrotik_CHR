#!/bin/bash -e

echo
echo "=== azadrah.org ==="
echo "=== https://github.com/azadrahorg ==="
echo "=== MikroTik 7 Installer ==="
echo
sleep 3
wget https://download.mikrotik.com/routeros/7.11.2/chr-7.11.2.img.zip -O chr.img.zip && \
gunzip -c chr.img.zip > chr.img && \
STORAGE=`lsblk | grep disk | cut -d ' ' -f 1 | head -n 1` && \
echo STORAGE is $STORAGE && \
ETH=`ip route show default | sed -n 's/.* dev \([^\ ]*\) .*/\1/p'` && \
echo ETH is $ETH && \
ADDRESS=`ip addr show $ETH | grep global | cut -d' ' -f 6 | head -n 1` && \
echo ADDRESS is $ADDRESS && \
GATEWAY=`ip route list | grep default | cut -d' ' -f 3` && \
echo GATEWAY is $GATEWAY && \
sleep 5 && \
dd if=chr.img of=/dev/$STORAGE bs=4M oflag=sync && \
echo "Ok, reboot" && \
echo 1 > /proc/sys/kernel/sysrq && \
echo b > /proc/sysrq-trigger

# Esperar un tiempo para que el sistema reinicie
sleep 30

# Configuración de la IP en RouterOS tras el reboot
# Intenta conectarte hasta que la conexión esté disponible
while ! ssh admin@localhost -o StrictHostKeyChecking=no -o ConnectTimeout=5 <<EOF
/ip address add address=$ADDRESS interface=ether1 
/ip route add gateway=$GATEWAY
/ip dns set servers=8.8.8.8,8.8.4.4
EOF
do
    echo "Esperando a que MikroTik esté disponible..."
    sleep 5
done
