# are requirements satisfied
if ! command -v jq &> /dev/null
then
    echo "---"
    echo "⚠️ Dependencies not satisfied! ⚠️"
    echo "Please install 'jq' to continue => sudo apt install jq -y"
    echo "---"
    exit
fi

if ! command -v curl &> /dev/null
then
    echo "---"
    echo "⚠️ Dependencies not satisfied! ⚠️"
    echo "Please install 'curl' to continue => sudo apt install curl -y"
    echo "---"
    exit
fi


# variablen setzen

shell_arguments=$1
gitea_latest_version=${1:-$(curl --silent "https://api.github.com/repos/go-gitea/gitea/releases/latest" | jq -r '.tag_name' 2>&1 | sed -e 's|.*-||' -e 's|^v||')}
gitea_download_url_default="https://github.com/go-gitea/gitea/releases/download/v${gitea_latest_version}/gitea-${gitea_latest_version}-linux-amd64"
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

# specify your version
echo "Please insert your needed download-url"
echo "Alternatively version ${gitea_latest_version} for (amd64) is used: ${gitea_download_url_default}"
echo "Check out the available versions at: https://github.com/go-gitea/gitea/releases"

read -p "-> " giteadownloader
if [[ -z ${giteadownloader} ]]; then
  giteadownloader="${gitea_download_url_default}"
fi
echo "You choose: ${giteadownloader}"



echo ""
echo ""
echo "//-->> Update"
apt-get update -q >> /dev/null 2>&1
apt-get upgrade -q -y >> /dev/null 2>&1

echo "//-->> Install packages"
apt-get install git mariadb-server mariadb-client nano -q -y >> /dev/null 2>&1

echo "//-->> Create user: git"
adduser --system --shell /bin/bash --gecos 'Git Version Control' --group --disabled-password --home /home/git git >> /dev/null 2>&1
cd /home/git/

echo "//-->> Download Gitea"
wget -q $giteadownloader -O gitea >> /dev/null 2>&1
chmod +x gitea

echo "//-->> Create important folder"
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
echo "//-->> Prepare database"
mysql -e "CREATE USER '$dbuser'@'localhost' IDENTIFIED BY '$dbpassword';"
mysql -e "CREATE DATABASE $dbtable;"
mysql -e "GRANT ALL PRIVILEGES ON $dbtable . * TO '$dbuser'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"

# systemvariable setzen
echo "//-->> Set system variables"
export GITEA_WORK_DIR=/var/lib/gitea/ >> /dev/null 2>&1

echo "//-->> Copy Gite to: /usr/local/bin/gitea (replace binary to upgrade.)"
mv gitea /usr/local/bin/gitea

# erstelle gitea als service
echo "//-->> Create gitea-servive"
cp "$pwd/config/gitea-service.txt" "/etc/systemd/system/gitea.service"
systemctl enable gitea >> /dev/null 2>&1
service gitea start >> /dev/null 2>&1

if [[ run_ci_tests == 0 ]]; then

  while true; do
    read -p "Do you want to secure your mysql-installation? [Y/n]" yn
    case $yn in
      [Yy]* ) mysql_secure_installation; break;;
      [Jj]* ) mysql_secure_installation; break;;
      [Nn]* ) break;;
      * ) echo "ERROR! Please answer with [Y/n]";;
    esac
  done

fi

echo ""
echo ""
# datenbankverbindung ausgeben
echo "##########################################################################"
echo "Gitea was installed successfully!"
echo "Now, open your browser and visit: http://$deineIP:3000"
echo ""
echo "--- Database ---"
echo "username: $dbuser"
echo "password: $dbpassword"
echo "database: $dbtable"
echo ""
echo "author: Tim Riedl - uVulpos"
echo "license: MIT"
echo "sourcecode: https://github.com/uvulpos/gitea-installer"
echo "##########################################################################"
echo "Have fun :)"
