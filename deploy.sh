#!/bin/bash
#Variable
REPO="bootcamp-devops-2023"
USERID=$(id -u)
#colores
LRED='\033[1;31m'
LGREEN='\033[1;32m'
NC='\033[0m'
LBLUE='\033[0;34m'
LYELLOW='\033[1;33m'


echo -e "\n${LYELLOW}==== Comprobando permisos de usuario ===${NC}"

sleep 2

if [ "${USERID}" -ne 0 ]; 
    then
        echo -e "\n${LRED}Correr con usuario ROOT${NC}"
    else
        echo -e  "\n${LGREEN}El usuario es ROOT${NC}"
fi 

echo -e "\n${LYELLOW}==== actualizando el sistema operativo ====${NC}"

sleep 2

sudo apt-get update

echo -e "\n${LYELLOW}==== Instalando Git ====${NC}"

sleep 2


if dpkg -l | grep -q git ;
then 
    echo -e "\n${LGREEN} Git ya esta instalado${NC}"
else
    echo "${LRED}instalando Git${NC}"
        apt install git -y
fi
    
        

echo -e "\n${LYELLOW} ==== instalando la base de datos ====${NC}"

sleep 2


if dpkg -l | grep -q mariadb-server ;
then 
    echo -e "\n${LGREEN} la base de datos ya esta instalada${NC}"
else
    echo "${LRED}instalando la base de datos${NC}"
        apt install mariadb-server -y
         systemctl start mariadb
         systemctl enable mariadb
         systemctl status mariadb
fi

echo -e "\n${LYELLOW}==== Configurando la base de datos ====${NC}"

sleep 2

    mysql -e "
    CREATE DATABASE devopstravel;
    CREATE USER 'codeuser'@'localhost' IDENTIFIED BY 'codepass';
    GRANT ALL PRIVILEGES ON *.* TO 'codeuser'@'localhost';
    FLUSH PRIVILEGES; "

echo -e "\n${LYELLOW}====Agregando Información la base de datos====${NC}"

sleep 2


echo -e "\n${LYELLOW}==== Instalando PHP ====${NC}"

sleep 2

if dpkg -l | grep -q php libapache2-mod-php php-mysql php-mbstring php-zip php-gd php-json php-curl  ;
then 
    echo -e "\n${LGREEN} PHP esta instalado${NC}"
else
    echo "${LRED}instalando PHP${NC}"
       apt install -y php libapache2-mod-php php-mysql php-mbstring php-zip php-gd php-json php-curl
fi


echo -e "\n${LYELLOW}==== Instalando servidor Apache ====${NC}"

sleep 2

if dpkg -l | grep -q apache2 ;
then 
    echo -e "\n${LGREEN} Apache ya esta instalado${NC}"
else
    echo "${LRED}instalando Apache2${NC}"
        apt install apache2 -y
        sudo systemctl start apache2 
        sudo systemctl enable apache2 
        sudo systemctl status apache2
fi

echo -e "\n${LYELLOW}==== Actualizadon el archivo DirectoryIndex ====${NC}"

sudo sed -i 's/DirectoryIndex index.html/DirectoryIndex index.php index.html/' /etc/apache2/mods-enabled/dir.conf


systemctl reload apache2


echo -e "\n${LYELLOW}====  Agregando el repositorio ====${NC}"

sleep 2

    if [ -d "$REPO" ] ;
    then 
        echo -e "\n${LGREEN} el repo ya se encuentra agregado, actualizando..${NC}"
            cd bootcamp-devops-2023/
            git pull origin clase2-linux-bash
            
    else
         echo -e "\n${LGREEN}Clonando${NC}"
            git clone -b clase2-linux-bash --single-branch https://github.com/roxsross/$REPO.git
            mv /var/www/html/index.html /var/www/html/index.html.bkp
            cp -r $REPO/* /var/www/html/
    fi


systemctl reload apache2