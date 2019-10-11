

function install_docker_ce {
    sudo dnf install -y \
        device-mapper-persistent-data \
        lvm2

    sudo dnf config-manager --add-repo \
        https://download.docker.com/linux/centos/docker-ce.repo

    sudo dnf update

    sudo dnf install -y \
        docker-ce \
        docker-ce-cli \
        containerd.io

    sudo systemctl start docker

    sudo curl -L \
        "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" \
        -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

    sudo usermod -aG docker $USER
    sudo setfacl -m user:$USER:rw /var/run/docker.sock
}


function install_tig {
    sudo dnf -y install ncurses-devel

    wget https://github.com/jonas/tig/releases/download/tig-2.4.1/tig-2.4.1.tar.gz
    tar xzvf tig*.tar.gz
    cd ./tig*

    ./configure
    make prefix=/usr/local
    sudo make install prefix=/usr/local

    cd -
}


function install_facetimehd_drivers {
    sudo dnf update
    sudo dnf install -y kernel-devel

    git clone https://github.com/patjak/bcwc_pcie.git
    cd ./bcwc_pcie/firmware
    # NOTE: Check for installed depedencies: curl, xzcat, cpio
    make
    sudo make install

    depmod
    modprobe facetimehd # load the module
    lsmod | grep facetimehd # check if all relevant modules are loaded

    echo "[+] Drivers installed, check if the camera works properly"
}

