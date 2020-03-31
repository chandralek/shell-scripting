#!/bin/bash 

## 

RB="\e[0m\e[1;31m"
GB="\e[0m\e[1;32m"
YB="\e[0m\e[1;33m"
BB="\e[0m\e[1;34m"
MB="\e[0m\e[1;35m"
CB="\e[0m\e[1;36m"
N="\e[0m"
D="\e[0m\e[2m"
B="\e[0m\e[1m"

LOG_FILE=/tmp/project.log 
rm -f $LOG_FILE 
#echo -e "${BB}[MONGO]${B}[INFO] ${D}$(date +%F' '%T) ${B}MongoDB Install${N}"
#echo -e "${BB}[RABBITMQ]${B}[INFO] ${D}$(date +%F' '%T) ${B}MongoDB Install${N}"
#echo -e "${BB}[MYSQL]${B}[INFO] ${D}$(date +%F' '%T) ${B}MongoDB Install${N}"
#echo -e "${BB}[REDIS]${B}[INFO] ${D}$(date +%F' '%T) ${B}MongoDB Install${N}"
#
#echo -e "${MB}[NGINX]${B}[INFO] ${D}$(date +%F' '%T) ${B}MongoDB Install${N}"
#
#echo -e "${CB}[CATALOGUE]${B}[INFO] ${D}$(date +%F' '%T) ${B}MongoDB Install${N}"
#echo -e "${CB}[CART]${B}[INFO] ${D}$(date +%F' '%T) ${B}MongoDB Install${N}"
#echo -e "${CB}[USER]${B}[INFO] ${D}$(date +%F' '%T) ${B}MongoDB Install${N}"
#echo -e "${CB}[SHIPPING]${B}[INFO] ${D}$(date +%F' '%T) ${B}MongoDB Install${N}"
#echo -e "${CB}[DISPATCH]${B}[INFO] ${D}$(date +%F' '%T) ${B}MongoDB Install${N}"
#echo -e "${CB}[PAYMENT]${B}[INFO] ${D}$(date +%F' '%T) ${B}MongoDB Install${N}"

LOGGER() {

  case $1 in 
    INFO) 
      STAT_COLOR=${B}
      ;; 
    FAIL) 
      STAT_COLOR=${RB}
      ;;
    SUCC) 
      STAT_COLOR=${GB}
      ;;
    SKIP) 
      STAT_COLOR=${YB}
  esac 

  case $SERVICE_NAME in 
    MONGODB|RABBITMQ|MYSQL|REDIS)
      echo -e "${D}$(date +%F' '%T) ${STAT_COLOR}[$1] ${BB}[$SERVICE_NAME] ${B}${2}${N}"
      ;;
    NGINX) 
      echo -e "${D}$(date +%F' '%T) ${STAT_COLOR}[$1] ${MB}[$SERVICE_NAME] ${B}${2}${N}"
      ;;
    CATALOGUE|CART|USER|SHIPPING|DISPATCH|PAYMENT) 
      echo -e "${D}$(date +%F' '%T) ${STAT_COLOR}[$1] ${CB}[$SERVICE_NAME] ${B}${2}${N}"
      ;;
  esac
}

STAT() {
  case $1 in 
    SKIP) 
      LOGGER SKIP "$2"
      ;;
    0) 
      LOGGER SUCC "$2"
      ;; 
    *) 
      LOGGER FAIL "$2"
      ;;
  esac
}

## Main Program 
SERVICE_NAME=MONGODB
LOGGER INFO "Starting MongoDB Setup"
echo '[mongodb-org-4.2]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/4.2/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-4.2.asc
'>/etc/yum.repos.d/mongodb-org-4.2.repo
STAT $? "Setting Up YUM Repository"

yum install -y mongodb-org &>>$LOG_FILE
STAT $? "Installing MONGODB"


