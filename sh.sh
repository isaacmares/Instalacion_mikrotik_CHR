#!/bin/bash -e

echo
echo "=== azadrah.org ==="
echo "=== https://github.com/azadrahorg ==="
echo "=== MikroTik 7 Installer ==="
echo
sleep 3

# Descargar e instalar MikroTik
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
echo "Ok, configurando script de inicialización..." && \

# Crear un script de inicialización
cat <<EOF > /mnt/init.rsc
/ip address add address=$ADDRESS/24 interface=ether1
/ip route add gateway=$GATEWAY
/ip dns set servers=8.8.8.8,8.8.4.4
EOF

# Añadir el script al scheduler para que se ejecute al inicio
echo "/system script add name='Configurar_IP' source='/file exec init.rsc'" >> /mnt/init.rsc
echo "/system scheduler add name='Ejecutar_Configurar_IP' on-event='Configurar_IP' start-time=startup;" >> /mnt/init.rsc

# Reiniciar el router
echo "Configuraciones aplicadas, ahora reiniciando..."
sleep 2 && \
echo 1 > /proc/sys/kernel/sysrq && \
echo b > /proc/sysrq-trigger
