#!/bin/bash

N="\e[0m"
RB="${N}\e[1;31m"
GB="${N}\e[1;32m"
YB="${N}\e[1;33m"
BB="${N}\e[1;34m"
MB="${N}\e[1;35m"
CB="${N}\e[1;36m"
D="\e[0m\e[2m"
B="\e[0m\e[1m"
echo -e "${BB}[MONGO]${RB}[INFO] ${D}$(date +%F' '%T) ${B}MongoDB Install${N}"
echo -e "${BB}[RABBITMQ]${B}[INFO] ${D}$(date +%F' '%T) ${B}MongoDB Install${N}"
echo -e "${BB}[MYSQL]${B}[INFO] ${D}$(date +%F' '%T) ${B}MongoDB Install${N}"
echo -e "${BB}[REDIS]${B}[INFO] ${D}$(date +%F' '%T) ${B}MongoDB Install${N}"

echo -e "${MB}[NGINX]${B}[INFO] ${D}$(date +%F' '%T) ${B}MongoDB Install${N}"

echo -e "${CB}[CATALOGUE]${B}[INFO] ${D}$(date +%F' '%T) ${B}MongoDB Install${N}"
echo -e "${CB}[CART]${B}[INFO] ${D}$(date +%F' '%T) ${B}MongoDB Install${N}"
echo -e "${CB}[USER]${B}[INFO] ${D}$(date +%F' '%T) ${B}MongoDB Install${N}"
echo -e "${CB}[SHIPPING]${B}[INFO] ${D}$(date +%F' '%T) ${B}MongoDB Install${N}"
echo -e "${CB}[DISPATCH]${B}[INFO] ${D}$(date +%F' '%T) ${B}MongoDB Install${N}"
echo -e "${CB}[PAYMENT]${B}[INFO] ${D}$(date +%F' '%T) ${B}MongoDB Install${N}"


