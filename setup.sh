#!/bin/bash


function installer {
    sudo apt-get $@
}


# Basics
function install_basics {
    installer update
    installer install -y \
        vim \
        htop \
        grc
}

function install_dev_utils {
    installer update
    installer install -y \
        gcc \
        gdb \
        python3 \
        python3-pip \
        vim
}

function configure_vim {
    wget https://mtnalonso.com/vimrc -O .vimrc
}

# Security
## Antivirus
function install_clamav {
    exit 1
}

function install_hashcat {
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
}

function install_network_utils {
    install_drivers_alfa_awus1900
    install_hcx_tools
}

function install_vulnerabilities_utils {
    install_openvas
}

function install_openvas {
    apt-get install openvas
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
    cd rtl*/
    make RTL8814=1
    sudo make install RTL8814=1
    make clean

    sudo modprobe -r 8814au
    sudo modprobe 8814au rtw_led_ctrl=1
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
    curl https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb > msfinstall && \
    sudo chmod 755 msfinstall && \
    ./msfinstall
}

function print_usage {
    echo -e "\nSystem setup script\n"
    echo -e "Usage:"
    echo -e "\t(no args)\tInstall basic utilities\n"
    echo -e "\t-a | --all\tInstall all utilities"
    echo -e "\t-d | --dev\tInstall dev utilities"
    echo -e "\t-n | --network\tInstall network utilities only"
    echo -e "\t-h | --help\tPrint this menu and exit\n"
}


if [ $# -gt 0 ]; then
    case $1 in
        -a|--all)
            install_basics
            install_network_utils
        ;;
        -d|--dev)
            install_dev_utils
        ;;
        -n|--network)
            install_network_utils
        ;;
        -h|--help|*)
            print_usage
        ;;
    esac
else
    install_basics
fi
