#!/bin/bash 

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
CLONE_MAIN_DIR=/tmp/robo-shop

## Check Git Cred Variables 

if [ ! -n "$GIT_USER" ]; then 
  echo -e "\n $RB GIT_USER Variable is missing, export GIT_USER and try again!!\n"
  exit 1
fi 

if [ ! -n "$GIT_PASSWORD" ]; then 
  echo -e "\n $RB GIT_PASSWORD Variable is missing, export GIT_PASSWORD and try again!!\n"
  exit 1
fi 

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
  if [ -z "$2" ]; then
    mkdir -p $CLONE_MAIN_DIR
  else
    local CLONE_MAIN_DIR=$2
  fi
  cd $CLONE_MAIN_DIR
  if [ -d ${1} ]; then
    cd ${1}
    git pull &>>$LOG_FILE
    STAT $? "Pulling repo - $1"
  else
    git clone https://${GIT_USER}:${GIT_PASSWORD}@gitlab.com/batch46/robo-shop/${1}.git &>>$LOG_FILE
    STAT $? "Cloning repo - $1"
  fi
}

INSTALL_NODEJS()
{
  which node &>>$LOG_FILE
  if [ $? -eq 0 ];then
    STAT SKIP "Installing Node Js"
    return
  fi
  curl -s https://raw.githubusercontent.com/linuxautomations/labautomation/master/tools/nodejs/install.sh | bash &>>LOG_FILE
  STAT $? "Installing Node JS"
}

SERVICE_SETUP()
{
  cp /home/$USERNAME/$APPNAME/$APPNAME.service /etc/systemd/system/$APPNAME.service &>>$LOG_FILE
  systemctl daemon-reload &>>$LOG_FILE
  systemctl enable $APPNAME &>>$LOG_FILE
  systemctl start $APPNAME &>>$LOG_FILE
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

REPO_DIR=nginx-webapp
CLONE $REPO_DIR 


cp $CLONE_MAIN_DIR/$REPO_DIR/nginx-localhost.conf /etc/nginx/nginx.conf &>>$LOG_FILE
STAT $? "Updating Nginx Configuration"

rm -rf /usr/share/nginx/html &>>$LOG_FILE
cp -r $CLONE_MAIN_DIR/$REPO_DIR/static /usr/share/nginx/html &>>$LOG_FILE
STAT $? "Copying Nginx Static Content"

systemctl enable nginx &>>$LOG_FILE
systemctl start nginx &>>$LOG_FILE
STAT $? "Starting NGINX Service"

for app in CATALOGUE CART USER; do
  SERVICE_NAME=$app
  LOGGER INFO "Starting $app Setup"
  INSTALL_NODEJS
  USERNAME=$(echo $SERVICE_NAME|tr [A-Z] [a-z])
  APPNAME=$USERNAME
  id $USERNAME &>/dev/null
  if [ $? -eq 0 ];then
    STAT SKIP "Creating application User"
  else
    useradd $USERNAME
    STAT $? "Creating application User"
  fi
  cd /home/$USERNAME
  CLONE $USERNAME "/home/$USERNAME"
  cd /home/$USERNAME/$APPNAME
  npm install &>>$LOG_FILE
  STAT $? "Installing NodeJs dependencies"
  chown $USERNAME:$USERNAME /home/$USERNAME -R
  mkdir -p /var/log/robo-shop/
  SERVICE_SETUP
done

for app in DISPATCH SHIPPING; do
  SERVICE_NAME=$app
  LOGGER INFO "Starting $app Setup"
  if [ "$app" == "SHIPPING" ]; then
    yum install java -y &>>$LOG_FILE
    STAT $? "Installing Java"
  fi
  USERNAME=$(echo $SERVICE_NAME|tr [A-Z] [a-z])
  APPNAME=$USERNAME
  id $USERNAME &>/dev/null
  if [ $? -eq 0 ];then
    STAT SKIP "Creating application User"
  else
    useradd $USERNAME
    STAT $? "Creating application User"
  fi
  cd /home/$USERNAME
  CLONE $USERNAME "/home/$USERNAME"
  cd /home/$USERNAME/$APPNAME
  chown $USERNAME:$USERNAME /home/$USERNAME -R
  if [ "$app" == "DISPATCH" ]; then
    chmod ugo+x /home/dispatch/dispatch/dispatch &>>$LOG_FILE
    STAT $? "Give executable permissions"
  fi
  SERVICE_SETUP
done
