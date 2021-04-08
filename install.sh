#!/usr/bin/env bash
PATH=/usr/bin:/usr/sbin:/usr/local/bin:/bin:/sbin:/usr/games
export DEBIAN_FRONTEND=noninteractive

#Setup Debian Package Manager
# $APT $APTOPTS $APTINST

APT="DEBIAN_FRONTEND=noninteractive apt-get"
APTOPTS="-o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold""
APTINST="--ignore-missing -yy -qq --allow-unauthenticated --assume-yes"

###############################################################################################
if [ ! -f $(which ntpd) ]; then
    sudo $APT $APTOPTS $APTINST install ntp ntpdate </dev/null >/dev/null 2>&1
    sudo systemctl stop ntp >/dev/null 2>&1
    sudo ntpdate ntp.casjay.in >/dev/null 2>&1
    sudo systemctl enable --now ntp >/dev/null 2>&1
fi

###############################################################################################
#update only
if [ "$update" == "yes" ]; then
    #    IFISONLINE=$( timeout 0.2 ping -c1 8.8.8.8 &>/dev/null ; echo $? )
    CURRIP4="$(/sbin/ifconfig | grep -E "venet|inet" | grep -v "127.0.0." | grep 'inet' | grep -v inet6 | awk '{print $2}' | sed s#addr:##g | head -n1)"
    #if [ "$IFISONLINE" -ne "0" ]; then
    #    exit 1
    #else

    if [ ! -d /usr/share/httpd/.git ]; then
        rm -Rf /usr/share/httpd
        git clone -q https://github.com/casjay-templates/default-web-assets /usr/share/httpd
    fi
    if [ -d /usr/share/httpd ]; then
        git -C  /usr/share/httpd pull -q
    fi

    git clone -q https://github.com/casjay-base/ubuntu /tmp/ubuntu
    find /tmp/ubuntu -type f -exec sed -i "s#MYHOSTIP#$CURRIP4#g" {} \; >/dev/null 2>&1
    find /tmp/ubuntu -type f -exec sed -i "s#MYHOSTNAME#$(hostname -s)#g" {} \; >/dev/null 2>&1
    sudo rm -Rf /tmp/ubuntu/etc/{apache2,nginx,postfix,samba} >/dev/null 2>&1
    sudo cp -Rf /tmp/ubuntu/{usr,etc,var}* / >/dev/null 2>&1
    sudo rm -Rf /etc/cron.*/0* >/dev/null 2>&1
    sudo rm -Rf /tmp/ubuntu >/dev/null 2>&1
    sudo cp -Rf /etc/casjaysdev/messages/legal.txt /etc/issue >/dev/null 2>&1
    sudo sh -c "/usr/games/fortune | /usr/games/cowsay > /etc/motd" >/dev/null 2>&1
    sudo echo -e "\n\n" >>/etc/motd >/dev/null 2>&1
    #fi

###############################################################################################
else

    # Installation

    # Path fix
    clear
    echo ""
    echo ""
    # Define colors
    PURPLE='\033[0;35m'
    BLUE='\033[0;34m'
    RED='\033[0;31m'
    GREEN='\033[32m'
    NC='\033[0m'
    ###
    # Welcome message

    wait_time=10 # seconds
    temp_cnt=${wait_time}
    printf "${GREEN}            *** ${RED}•${GREEN} Welcome to my Ubuntu Installer ${RED}•${GREEN} ***${NC}\n"
    while [[ ${temp_cnt} -gt 0 ]]; do
        printf "\r  ${GREEN}*** ${RED}•${GREEN} You have %2d second(s) remaining to hit Ctrl+C to cancel ${RED}•${GREEN} ***" ${temp_cnt}
        sleep 1
        ((temp_cnt--))
    done
    printf "${NC}\n\n"

    # Install needed packages
    printf "\n  ${GREEN}*** ${RED}•${BLUE} installing needed packages ${RED}•${GREEN} ***${NC}\n"
    sudo $APT $APTOPTS $APTINST install apt-utils dirmngr git curl wget apt-transport-https debian-archive-keyring debian-keyring bzip2 unattended-upgrades </dev/null >/dev/null 2>&1

    # Add Ubuntu keys
    printf "\n  ${GREEN}*** ${RED}•${BLUE} installing apt keys ${RED}•${GREEN} ***${NC}\n"
    sudo $APT $APTOPTS $APTINST install vim debian-archive-keyring debian-keyring </dev/null >/dev/null 2>&1
    sudo $APT $APTOPTS $APTINST update >/dev/null 2>&1
    sudo $APT $APTOPTS $APTINST update >/dev/null 2>&1
    sudo $APT $APTOPTS $APTINST update >/dev/null 2>&1

    # Clone repo
    printf "\n  ${GREEN}*** ${RED}•${GREEN} cloning the repository ${RED}•${GREEN} ***${NC}\n"
    sudo rm -Rf /tmp/ubuntu >/dev/null 2>&1
    git clone -q https://github.com/casjay-base/ubuntu /tmp/ubuntu >/dev/null 2>&1

    # Copy apt sources
    printf "\n  ${GREEN}*** ${RED}•${BLUE} copy apt sources ${RED}•${GREEN} ***${NC}\n"
    sudo cp -Rf /tmp/ubuntu/etc/apt/* /etc/apt/ >/dev/null 2>&1

    # Install additional packages
    printf "\n  ${GREEN}*** ${RED}•${BLUE} installing additional packages ${RED}•${GREEN} ***${NC}\n"
    sudo $APT $APTOPTS $APTINST update >/dev/null 2>&1
    sudo $APT $APTOPTS $APTINST update >/dev/null 2>&1
    sudo $APT $APTOPTS $APTINST update >/dev/null 2>&1
    sudo $APT $APTOPTS $APTINST install net-tools uptimed downtimed mailutils postfix apache2 nginx ntp gnupg cron openssh-server cowsay fortune-mod figlet geany fonts-hack-ttf fonts-hack-otf fonts-hack-web </dev/null >/dev/null 2>&1
    sudo $APT $APTOPTS $APTINST install samba tmux neofetch vim-nox fish zsh libapache2-mod-fcgid libapache2-mod-geoip libapache2-mod-php </dev/null >/dev/null 2>&1

    # Remove anacron stuff
    sudo rm -Rf /etc/cron.*/0*

    #Set ip and hostname
    CURRIP4="$(/sbin/ifconfig | grep -E "venet|inet" | grep -v "127.0.0." | grep 'inet' | grep -v inet6 | awk '{print $2}' | sed s#addr:##g | head -n1)"
    find /tmp/ubuntu -type f -exec sed -i "s#MYHOSTIP#$CURRIP4#g" {} \; >/dev/null 2>&1
    find /tmp/ubuntu -type f -exec sed -i "s#MYHOSTNAME#$(hostname -s)#g" {} \; >/dev/null 2>&1

    # Copy configurations to system
    printf "\n  ${GREEN}*** ${RED}•${BLUE} copying system files ${RED}•${GREEN} ***${NC}\n"
    chmod -Rf 755 /tmp/ubuntu/usr/local/bin/*.sh >/dev/null 2>&1
    sudo cp -Rf /tmp/ubuntu/{usr,etc,var}* / >/dev/null 2>&1
    mkdir -p /etc/casjaysdev/updates/versions >/dev/null 2>&1
    cp -Rf /tmp/ubuntu/version.txt /etc/casjaysdev/updates/versions/ubuntu.txt >/dev/null 2>&1

    # Cleanup
    rm -Rf /tmp/ubuntu >/dev/null 2>&1
    rm -Rf /var/www/html/index*.html >/dev/null 2>&1

    # Setup postfix
    sudo newaliases >/dev/null 2>&1
    sudo systemctl enable --now postfix >/dev/null 2>&1

    # Setup apache2
    if [ -d /usr/share/httpd/.git ]; then
      git -C  /usr/share/httpd pull
    else
      rm -Rf /usr/share/httpd
      sudo git clone -q https://github.com/casjay-templates/default-web-assets /usr/share/httpd
    fi
    sudo a2enmod access_compat fcgid expires userdir asis autoindex brotli cgid cgi charset_lite data deflate dir env geoip headers http2 lbmethod_bybusyness lua php7.3 proxy proxy_http2 request rewrite session_dbd speling ssl status vhost_alias xml2enc >/dev/null 2>&1
    mkdir -p /var/www/html/.well-known >/dev/null 2>&1
    chown -Rf www-data:www-data /var/www /usr/share/httpd >/dev/null 2>&1

    # Install My CA cert
    sudo cp -Rf /etc/ssl/CA/CasjaysDev/certs/ca.crt /usr/local/share/ca-certificates/CasjaysDev.crt >/dev/null 2>&1
    sudo update-ca-certificates >/dev/null 2>&1

    # Setup systemd
    printf "\n  ${GREEN}*** ${RED}•${BLUE} setup systemd ${RED}•${GREEN} ***${NC}\n"
    sudo timedatectl set-local-rtc 0 >/dev/null 2>&1
    sudo timedatectl set-ntp 1 >/dev/null 2>&1
    sudo timedatectl status >/dev/null 2>&1
    sudo timedatectl set-timezone America/New_York >/dev/null 2>&1
    sudo systemctl enable --now ssh >/dev/null 2>&1
    sudo systemctl enable --now apache2 nginx >/dev/null 2>&1

    #Add your public key to ssh
    #set GH to your github username
    #use  sudo GH=username bash -c "$(wget -qO - https://github.com/casjay-base/ubuntu/raw/master/install.sh)"
    if [ ! -z $GH ]; then
        printf "${GREEN}\n  *** ${RED}•${PURPLE} Installing $GH.keys into $HOME/.ssh/authorized_keys  ${RED}•${GREEN} ***${NC}\n\n\n"
        mkdir -p ~/.ssh >/dev/null 2>&1
        chmod 700 ~/.ssh >/dev/null 2>&1
        curl -s https://github.com/$GH.keys | grep -v "Not Found" >>~/.ssh/authorized_keys >/dev/null 2>&1
    fi

    #Make motd
    if [ -f /usr/games/fortune ] && [ -f /usr/games/cowsay ]; then
        sudo sh -c "/usr/games/fortune | /usr/games/cowsay > /etc/motd" >/dev/null 2>&1
        sudo echo -e "\n\n" >>/etc/motd >/dev/null 2>&1
    fi

    # Print installed version
    NEWVERSION="$(echo $(curl -Lsq https://github.com/casjay-base/ubuntu/raw/master/version.txt | grep -v "#" | tail -n 1))"
    RESULT=$?
    #if [ $RESULT -eq 0 ]; then
    printf "${GREEN}      *** 😃 installation of ubuntu complete 😃 *** ${NC}\n"
    printf "${GREEN}  *** 😃 You now have version number: $NEWVERSION 😃 *** ${NC}\n\n"
    #else
    #printf "${RED} *** • installation of dotfiles completed with errors: $RESULT ***${NC}\n\n"
    #fi
###############################################################################################
###printf "\n  ${GREEN}*** ${RED}•${BLUE} #### ${RED}•${GREEN} ***${NC}\n"###

fi

#### END
