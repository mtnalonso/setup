#!/bin/bash

USERNAME="martin"
USERPASS="$1"


sudo apt update -y
sudo apt upgrade -y
sudo apt install -y gnupg acl vim grc


# Kali repos ==================================================================
wget 'https://archive.kali.org/archive-key.asc'
sudo apt-key add archive-key.asc
rm archive-key.asc

sudo tee -a /etc/apt/sources.list<<EOF
deb http://http.kali.org/kali kali-rolling main non-free contrib
deb-src http://http.kali.org/kali kali-rolling main non-free contrib
EOF

sudo tee -a /etc/apt/preferences.d/kali.pref <<EOF
Package: *
Pin: release a=kali-rolling
Pin-Priority: 50
EOF

sudo apt update -y
sudo apt upgrade -y

# NOTE: to force install from kali repos:
# sudo aptitude install -t kali-rolling wpscan

# User config =================================================================
sudo useradd -s /bin/bash $USERNAME
sudo mkdir /home/$USERNAME
# TODO: check this -> https://stackoverflow.com/questions/714915/using-the-passwd-command-from-within-a-shell-script
sudo passwd $USERNAME -p "$USERPASS"
sudo usermod -aG sudo martin

sudo chown -R $USERNAME:$USERNAME /home/$USERNAME

sudo mkdir /home/$USERNAME/.ssh
sudo chmod 700 /home/$USERNAME/.ssh
sudo cp /root/.ssh/authorized_keys /home/$USERNAME/.ssh/
sudo chown -R $USERNAME:$USERNAME /home/$USERNAME/.ssh

sudo sed -i 's/^PermitRootLogin\ yes$/PermitRootLogin no/g' /etc/ssh/sshd_config
sudo systemctl restart sshd

sudo wget https://mtnalonso/vimrc -O /root/.vimrc
sudo cp /root/.vimrc /home/$USERNAME/

sudo tee -a /home/$USERNAME/.bashrc <<EOF
export PS1="\e[0;36m\u\e[m\e[0;35m@\e[m\e[0;33m\h\e[m\e[0;35m:\e[m\w\\e[0;35m$\e[m "
#Bold prompt
#export PS1="\e[1;36m\u\e[m\e[1;35m@\e[m\e[1;33m\h\e[m\e[1;35m:\e[m\e[1m\w\\e[m\e[1;35m$\e[m "

[[ -s "/etc/grc.bashrc" ]] && source /etc/grc.bashrc

alias myip="dig +short myip.opendns.com @resolver1.opendns.com"
EOF

if [ ! -s "/etc/grc.bashrc" ]; then
    sudo wget https://raw.githubusercontent.com/garabik/grc/master/grc.bashrc -O /etc/grc.bashrc
    sudo chmod 644 /etc/grc.bashrc
    sudo sed -i 's/#alias/alias/g' /etc/grc.bashrc
fi

sudo tee -a /home/$USERNAME/.bash_profile <<EOF
if [ -f ~/.bashrc ]; then
  . ~/.bashrc
fi
EOF

sudo chown $USERNAME:$USERNAME /home/$USERNAME/.bashrc
sudo chown $USERNAME:$USERNAME /home/$USERNAME/.bash_profile


# Base packages ===============================================================
sudo apt install -y \
    man \
    htop \
    git \
    traceroute \
    dnsutils \
    curl \
    neofetch


# Recon =======================================================================
sudo apt install -y \
    nmap \
    amass
