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
  echo -e "************************END OF $2*******************************" &>>$LOG_FILE
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

CLONE()
{
  mkdir -p /tmp/robo-shop
  cd /tmp/robo-shop
  git clone https://gitlab.com/batch46/robo-shop/${1}.git
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

systemctl enable mongod
systemctl start mongod 
STAT $? "Starting MongoDB Service"

SERVICE_NAME=RABBITMQ
LOGGER INFO "Starting RABBITMQ Setup"
yum list installed | grep erlang &>/dev/null

case $? in
    0)
      STAT SKIP "Installing ErLang Package"
      ;;
    *)
      yum install https://packages.erlang-solutions.com/erlang/rpm/centos/7/x86_64/esl-erlang_22.2.1-1~centos~7_amd64.rpm -y &>>$LOG_FILE
      STAT $? "Installing ErLang Package"
      ;;
esac

curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | sudo bash &>>$LOG_FILE
STAT $? "Setting up Yum repositories"

yum install rabbitmq-server -y &>>$LOG_FILE 
STAT $? "Installing RabbitMQ Server"

systemctl enable rabbitmq-server &>>$LOG_FILE 
systemctl start rabbitmq-server &>>$LOG_FILE 
STAT $? "Start RabbitMq Server"


SERVICE_NAME=MYSQL
LOGGER INFO "Starting MYSQL Setup"
LOGGER INFO "Downloading MYSQL"
yum remove mariadb-libs -y &>/dev/null
yum list installed | grep mysql-community-server &> /dev/null
case $? in
0)
  STAT SKIP "Downloading MYSQL"
  ;;
*)
  wget https://downloads.mysql.com/archives/get/p/23/file/mysql-5.7.28-1.el7.x86_64.rpm-bundle.tar&>>$LOG_FILE
  STAT $? "Downloaded MYSQL"
  tar -xf mysql-5.7.28-1.el7.x86_64.rpm-bundle.tar &>/dev/null
  yum install mysql-community-client-5.7.28-1.el7.x86_64.rpm \
              mysql-community-common-5.7.28-1.el7.x86_64.rpm \
              mysql-community-libs-5.7.28-1.el7.x86_64.rpm \
              mysql-community-server-5.7.28-1.el7.x86_64.rpm -y &>>$LOG_FILE
  STAT $? "Installing MYSQL Database"
  rm -rf mysql-5* *.rpm
  ;;
esac

systemctl enable mysqld &>>$LOG_FILE
systemctl start mysqld &>>$LOG_FILE
STAT $? "Starting MYSQL Database"

SERVICE_NAME=REDIS
LOGGER INFO "Starting REDIS Setup"

yum install epel-release yum-utils -y &>>$LOG_FILE 
STAT $? "Installing EPEL & YUM UTILS Package"

yum list installed | grep remi-release &>/dev/null
case $? in 
  0) 
    STAT SKIP "Setting Up YUM Repos"
    ;;
  *) 
    yum install http://rpms.remirepo.net/enterprise/remi-release-7.rpm -y &>>$LOG_FILE
    STAT $? "Setting Up YUM Repos"
    yum-config-manager --enable remi &>/dev/null 
    ;;
esac

yum install redis -y &>>$LOG_FILE
STAT $? "Installing Redis"

systemctl enable redis &>>$LOG_FILE
systemctl start redis &>>$LOG_FILE
STAT $? "Starting REDIS Service"


SERVICE_NAME=NGINX
LOGGER INFO "Starting Nginx Setup"

yum install nginx -y &>>$LOG_FILE
STAT $? "Installing Nginx"

CLONE nginx-webapp 