#!/bin/bash


function installer {
    sudo apt-get $@
}

function configure_vim {
    wget https://mtnalonso.com/vimrc -O .vimrc
}

# Basics
function install_basics {
    installer update
    installer install -y \
        vim \
        htop \
        git \
        wget \
        curl \
        acl \
        grc
    configure_vim
}

function install_dev_utils {
    installer update
    installer install -y \
        gcc \
        gdb \
        python3 \
        python3-pip \
        python3-ipython \
        neofetch
}

# Security
## Antivirus
function install_security_utils {
    install_metasploit
    installer gobuster
}

function install_clamav {
    exit 1
}

function install_hashcat {
    if [[ ! $(which hashcat) ]]; then
        git clone https://github.com/hashcat/hashcat.git
        cd hashcat
        make
        sudo make install
        cd ..
        rm -rf hashcat

        git clone https://github.com/hashcat/hashcat-utils.git
        cd hashcat-utils/src
        make
        cd -
        mv hashcat-utils/src /opt/hashcat-utils
        rm -rf hashcat-utils
    fi
}

function install_network_utils {
    install_drivers_alfa_awus1900
    install_hcx_tools
    installer install -y \
        openvpn \
        network-manager-openvpn \
        network-manager-openvpn-gnome \
        build-essential \
        libpcap-dev \
        libusb-1.0-0-dev \
        libnetfilter-queue-dev \
        nmap \
        tshark \
        wifite

    install_bettercap
}

function install_go {
    if [[ ! $(which go) ]]; then
    wget https://golang.org/dl/go1.15.3.linux-armv6l.tar.gz
    sudo tar -C /usr/local -xzf go1.15.3.linux-armv6l.tar.gz

    sudo setfacl -R -m u:$USER:rX /usr/local/go
    sudo setfacl -R -m u:$USER:rwX /usr/local/go/src
    sudo setfacl -d -R -m u:$USER:rwX /usr/local/go/src

    sudo mkdir /opt/go
    sudo setfacl -R -m u:$USER:rwX /opt/go
    sudo setfacl -d -R -m u:$USER:rwX /opt/go

    sudo tee -a /etc/profile <<EOF
export GOPATH=/opt/go
export PATH=$PATH:/usr/local/go/bin
EOF
    fi
}

function install_bettercap {
    go get github.com/bettercap/bettercap
    cd $GOPATH/src/github.com/bettercap/bettercap
    make build
    sudo make install
    cd -
    sudo bettercap -eval "caplets.update; ui.update; q"
}


function install_assetfinder {
    if [[ ! $(which assetfinder) ]]; then
        git clone https://github.com/tomnomnom/assetfinder.git
        cd ./assetfinder
        go build
        cd -
    fi
}

function install_sublist3r {
    if [[ ! $(which sublist3r) ]]; then
        git clone https://github.com/aboul3la/Sublist3r.git /opt/sublist3r
        cd /opt/sublist3r
        sudo pip3 install -r requirements.txt
        cd -
    fi
}

function install_sherlock {
    git clone https://github.com/sherlock-project/sherlock.git /opt/sherlock
    cd /opt/sherlock
    sudo pip3 install -r requirements.txt
    cd -
}

function install_osint_utils {
    install_assetfinder
    install_sublist3r
    install_sherlock
}

function install_vulnerabilities_utils {
    install_openvas
}

function install_openvas {
    installer install openvas
    openvas-setup
}

function install_opensnitch {
    exit 1
}

function install_drivers_alfa_awus1900 {
    # it has chipset RTL8814au
    # but this repo installs rtl8812au / rtl8814au
    installer install bc
    installer install linux-headers-`uname -r`

    git clone -b v5.1.5 https://github.com/aircrack-ng/rtl8812au.git
    cd rtl8812au/
    make RTL8814=1
    sudo make install RTL8814=1
    make clean

    sudo modprobe -r 8814au
    sudo modprobe 8814au rtw_led_ctrl=1
    cd -
    rm -rf  rtl8812au
}

function install_hcx_tools {
    git clone https://github.com/ZerBea/hcxdumptool.git
    cd hcx*
    make
    sudo make install
    cd -
    rm -rf hcx*

    installer install -y \
        libcurl4-openssl-dev \
        libssl-dev \
        libz-dev \
        libpcap-dev
    git clone https://github.com/ZerBea/hcxtools.git
    cd hcxtools/
    make
    sudo make install
    cd -
    rm -rf hcx
}

function install_metasploit {
    if [[ ! $(which msfconsole) ]]; then
        curl https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb > msfinstall && \
        sudo chmod 755 msfinstall && \
        ./msfinstall
        rm msfinstall
    fi
    sudo systemctl enable postgresql
    sudo systemctl start postgresql
    sudo msfdb init
}

function print_usage {
    echo -e "\nSystem setup script\n"
    echo -e "Usage:"
    echo -e "\t(no args)\tInstall basic utilities\n"
    echo -e "\t-a | --all\tInstall all utilities"
    echo -e "\t-d | --dev\tInstall dev utilities"
    echo -e "\t-n | --network\tInstall network utilities only"
    echo -e "\t-s | --security\tInstall security utilities only"
    echo -e "\t-h | --help\tPrint this menu and exit\n"
}


if [ $# -gt 0 ]; then
    case $1 in
        -a|--all)
            install_basics
            install_dev_utils
            install_network_utils
            install_security_utils
        ;;
        -d|--dev)
            install_dev_utils
        ;;
        -n|--network)
            install_network_utils
        ;;
        -s|--security)
            install_security_utils
        ;;
        -h|--help|*)
            print_usage
        ;;
    esac
else
    install_basics
fi
