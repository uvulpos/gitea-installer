# variablen setzen

shell_arguments=$1
giteadownloader_default="https://dl.gitea.io/gitea/1.15/gitea-1.15-linux-amd64"
deineIP="$(/sbin/ip -o -4 addr list eth0 | awk '{print $4}' | cut -d/ -f1)"
pwd="$(pwd)"
dbuser="giteauser"
dbpassword=$(date +%s | sha256sum | base64 | head -c 32)
dbtable="giteadb"

if [[ "$shell_arguments" == "--github-ci-test" ]]; then
  run_ci_tests=1
else
  run_ci_tests=0
fi

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

if [[ run_ci_tests == 1 ]]; then

  giteadownloader="${giteadownloader_default}"

else

  echo "Bitte gib den Downloadlink zur jeweiligen Version an. Alternativ nutze ich folgenden Link: ${giteadownloader_default}"
  read -p "-> " giteadownloader
  if [[ -z ${giteadownloader} ]]; then
    giteadownloader="${giteadownloader_default}"
  fi
  echo "Du hast folgenden Link gewaehlt: ${giteadownloader}"

fi

echo ""
echo ""
echo "//-->> Update"
apt-get update -q >> /dev/null 2>&1
apt-get upgrade -q -y >> /dev/null 2>&1

echo "//-->> Installiere Pakete"
apt-get install git mariadb-server mariadb-client nano -q -y >> /dev/null 2>&1

echo "//-->> Erstelle nutzer: git"
adduser --system --shell /bin/bash --gecos 'Git Version Control' --group --disabled-password --home /home/git git >> /dev/null 2>&1
cd /home/git/

echo "//-->> Gitea Herunterladen"
wget -q $giteadownloader -O gitea >> /dev/null 2>&1
chmod +x gitea

echo "//-->> Erstelle alle wichtigen Ordner"
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
echo "//-->> Erstelle die Datenbank"
mysql -e "CREATE USER '$dbuser'@'localhost' IDENTIFIED BY '$dbpassword';"
mysql -e "CREATE DATABASE $dbtable;"
mysql -e "GRANT ALL PRIVILEGES ON $dbtable . * TO '$dbuser'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"

# systemvariable setzen
echo "//-->> Systemvariablen setzen"
export GITEA_WORK_DIR=/var/lib/gitea/ >> /dev/null 2>&1

echo "//-->> Kopiere Gitea ins Verzeichnis: /usr/local/bin/gitea (Ersetze dort die Binary um Gitea zu aktualisieren.)"
mv gitea /usr/local/bin/gitea

# erstelle gitea als service
echo "//-->> Erstelle Gitea als Service"
cp "$pwd/config/gitea-service.txt" "/etc/systemd/system/gitea.service"
systemctl enable gitea >> /dev/null 2>&1
service gitea start >> /dev/null 2>&1

if [[ run_ci_tests == 0 ]]; then

  while true; do
      read -p "Möchtest du deine Datenbank absichern? [Y/n]" yn
      case $yn in
          [Yy]* ) mysql_secure_installation; break;;
          [Jj]* ) mysql_secure_installation; break;;
          [Nn]* ) break;;
          * ) echo "FEHLER! Bitte antworte mit ja oder nein";;
      esac
  done

fi

echo ""
echo ""
# datenbankverbindung ausgeben
echo "##########################################################################"
echo "Gitea wurde erfolgreich installiert!"
echo "Bitte öffne nun deinen bowser und besuche die webseite: http://$deineIP:3000"
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
echo "Viel Spaß!"
