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

echo -e "\n${LYELLOW}==== Poblando la base de datos ====${NC}"

mysql < /var/www/html/app-295devops-travel/database/devopstravel.sql
sudo sed -i 's/""/"codepass";/g' /var/www/html/app-295devops-travel/config.php

systemctl reload apache2

echo -e "\n${LYELLOW}====  Enviado notificación a Discord ====${NC}"


# Configura el token de acceso de tu bot de Discord
DISCORD="https://discord.com/api/webhooks/1154865920741752872/au1jkQ7v9LgQJ131qFnFqP-WWehD40poZJXRGEYUDErXHLQJ_BBszUFtVj8g3pu9bm7h"

# Verifica si se proporcionó el argumento del directorio del repositorio
#if [ $# -ne 1 ]; then
  #echo "Uso: $0 <"
  #exit 1
#fi

# Cambia al directorio del repositorio
#cd "$1"

# Obtiene el nombre del repositorio
REPO_NAME=$(basename $(git rev-parse --show-toplevel))
# Obtiene la URL remota del repositorio
REPO_URL=$(git remote get-url origin)
WEB_URL="localhost"
# Realiza una solicitud HTTP GET a la URL
HTTP_STATUS=$(curl -Is "$WEB_URL" | head -n 1)

# Verifica si la respuesta es 200 OK (puedes ajustar esto según tus necesidades)
if [[ "$HTTP_STATUS" == *"200 OK"* ]]; then
  # Obtén información del repositorio
    DEPLOYMENT_INFO2="Despliegue del repositorio $REPO_NAME: "
    DEPLOYMENT_INFO="La página web $WEB_URL está en línea."
    COMMIT="Commit: $(git rev-parse --short HEAD)"
    AUTHOR="Autor: Nicolás Stecher"
    DESCRIPTION="Descripción: $(git log -1 --pretty=format:'%s')"
else
  DEPLOYMENT_INFO="La página web $WEB_URL no está en línea."
fi

# Obtén información del repositorio


# Construye el mensaje
MESSAGE="$DEPLOYMENT_INFO2\n$DEPLOYMENT_INFO\n$COMMIT\n$AUTHOR\n$REPO_URL\n$DESCRIPTION"

# Envía el mensaje a Discord utilizando la API de Discord
curl -X POST -H "Content-Type: application/json" \
     -d '{
       "content": "'"${MESSAGE}"'"
     }' "$DISCORD"