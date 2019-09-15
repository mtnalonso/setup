#!/bin/bash


if [ $(id -u) -ne 0 ]; then
    echo "This script must be run as root"
    exit 1
fi


# Basics
function install_basics {
    apt-get update
    apt-get install -y \
        gcc \
        gdb \
        vim \
        htop
}

# Security
## Antivirus
function install_clamav {
    # TODO: install clamav
}

function install_hashcat {
    git clone https://github.com/hashcat/hashcat.git
    cd hashcat
    make
    make install
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

function install_drivers_alfa_awus1900 {
    # it has chipset RTL8814au
    # but this repo installs rtl8812au / rtl8814au
    apt-get install bc
    apt-get install linux-headers-`uname -r`

    git clone -b v5.1.5 https://github.com/aircrack-ng/rtl8812au.git
    cd rtl*/
    make RTL8814=1
    make install RTL8814=1
    make clean

    sudo modprobe -r 8814au
    sudo modprobe 8814au rtw_led_ctrl=1
}

function install_hcx_tools {
    git clone https://github.com/ZerBea/hcxdumptool.git
    cd hcx*
    make
    make install
    cd -
    rm -rf hcx*

    sudo apt-get install -y \
        libcurl4-openssl-dev \
        libssl-dev \
        libz-dev \
        libpcap-dev
    git clone https://github.com/ZerBea/hcxtools.git
    cd hcxtools/
    make
    make install
    cd -
    rm -rf hcx
}

function install_metasploit {
    curl https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb > msfinstall && \
    chmod 755 msfinstall && \
    ./msfinstall
}

function install_other {

}

#install_basics
