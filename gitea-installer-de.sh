# variablen setzen
giteadownloader="https://dl.gitea.io/gitea/1.11.4/gitea-1.11.4-linux-amd64"
deineIP="$(/sbin/ip -o -4 addr list eth0 | awk '{print $4}' | cut -d/ -f1)"
pwd="$(pwd)"
dbuser="giteauser"
dbpassword=$(date +%s | sha256sum | base64 | head -c 32)
dbtable="giteadb"

echo ""
echo ""
echo "  Gitea installer"
echo "-------------------------------------------------------------------------"
echo "author: Tim Riedl - uVulpos"
echo "license: MIT"
echo "sourcecode: https://github.com/uvulpos/gitea-installer"
echo "-------------------------------------------------------------------------"
echo ""

sleep 3s

echo "//-->> update"
apt-get update -q >> /dev/null 2>&1
apt-get upgrade -q -y >> /dev/null 2>&1

echo "//-->> install packages"
apt-get install git mariadb-server mariadb-client nano -q -y >> /dev/null 2>&1

echo "//-->> erstelle nutzer: git"
adduser --system --shell /bin/bash --gecos 'Git Version Control' --group --disabled-password --home /home/git git >> /dev/null 2>&1
cd /home/git/

echo "//-->> download gitea"
wget -q $giteadownloader -O gitea >> /dev/null 2>&1
chmod +x gitea

echo "//-->> erstelle alle wichtigen ordner mit berechtigungen"
mkdir -p /var/lib/gitea/custom
mkdir -p /var/lib/gitea/data
mkdir -p /var/lib/gitea/data/lfs
mkdir -p /var/lib/gitea/log
chown -R git:git /var/lib/gitea
chmod -R 750 /var/lib/gitea/
mkdir /etc/gitea
chown root:git /etc/gitea
chmod 770 /etc/gitea

# insert gitea user
echo "//-->> prepare database"
mysql -e "CREATE USER '$dbuser'@'localhost' IDENTIFIED BY '$dbpassword';"
mysql -e "CREATE DATABASE $dbtable;"
mysql -e "GRANT ALL PRIVILEGES ON $dbtable . * TO '$dbuser'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"

# systemvariable setzen
echo "//-->> systemvariable setzen"
export GITEA_WORK_DIR=/var/lib/gitea/ >> /dev/null 2>&1

echo "//-->> kopiere gitea ins verzeichnis /usr/local/bin/gitea (dort binary zum gitea updaten einfach ersetzen)"
mv gitea /usr/local/bin/gitea

# erstelle gitea als service
echo "//-->> erstelle gitea als service"
cp "$pwd/config/gitea-service.txt" "/etc/systemd/system/gitea.service"
systemctl enable gitea >> /dev/null 2>&1
service gitea start >> /dev/null 2>&1

while true; do
    read -p "möchtest du noch deine datenbank absichern? [Y/n]" yn
    case $yn in
        [Yy]* ) mysql_secure_installation; break;;
        [Jj]* ) mysql_secure_installation; break;;
        [Nn]* ) break;;
        * ) echo "FEHLER! bitte antworte mit ja oder nein";;
    esac
done

echo ""
echo ""
# datenbankverbindung ausgeben
echo "##########################################################################"
echo "gitea wurde erfolgreich installiert!"
echo "bitte öffne nun deinen bowser und besuche die webseite: http://$deineIP:3000"
echo ""
echo "--- Datenbank ---"
echo "username: $dbuser"
echo "password: $dbpassword"
echo "database: $dbtable"
echo ""
echo "author: Tim Riedl - uVulpos"
echo "license: MIT"
echo "sourcecode: https://github.com/uvulpos/gitea-installer"
echo "##########################################################################"
