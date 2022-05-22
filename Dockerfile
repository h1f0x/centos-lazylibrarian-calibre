FROM amd64/centos:7
MAINTAINER h1f0x

# Enabled systemd
ENV container docker

ENV CALIBRE_INSTALLER_SOURCE_CODE_URL https://raw.githubusercontent.com/kovidgoyal/calibre/master/setup/linux-installer.py
ENV CALIBRE_CONFIG_DIRECTORY="/config/calibre/"
ENV CALIBRE_TEMP_DIR="/config/calibre/tmp/"
ENV CALIBRE_CACHE_DIRECTORY="/config/cache/calibre/"

RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == \
systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*; \
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*; \
rm -f /lib/systemd/system/anaconda.target.wants/*;

RUN yum clean all && rm -rf /var/cache/yum/*
RUN yum update -y

# Python 2.7.14
WORKDIR /tmp
RUN yum groupinstall -y "development tools"
RUN yum install -y zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel gdbm-devel db4-devel libpcap-devel xz-devel expat-devel
RUN yum install -y wget
RUN wget http://python.org/ftp/python/2.7.14/Python-2.7.14.tar.xz
RUN tar xf Python-2.7.14.tar.xz
WORKDIR /tmp/Python-2.7.14
RUN ./configure --prefix=/usr/local --enable-unicode=ucs4 --enable-shared LDFLAGS="-Wl,-rpath /usr/local/lib"
RUN make && make altinstall
RUN wget https://bootstrap.pypa.io/get-pip.py
RUN python2.7 get-pip.py

# Qt Fixes
RUN yum install -y mesa-libGL-devel
RUN yum install -y qt5-qtbase-gui
RUN yum install -y http://rpms.famillecollet.com/enterprise/remi-release-7.rpm
RUN yum --enablerepo remi info ImageMagick7
RUN yum --enablerepo remi install -y ImageMagick7
RUN yum install -y which
RUN yum install -y chromedriver chromium xorg-x11-server-Xvfb

# Unrar
WORKDIR /tmp/
RUN wget https://rarlab.com/rar/unrarsrc-5.6.8.tar.gz
RUN tar -xvf unrarsrc-5.6.8.tar.gz
RUN ls -la
RUN make -C unrar lib
RUN make -C unrar install-lib
RUN pip2.7 install --global-option=build_ext --global-option="-I$(pwd)" unrardll

# Calibre
RUN wget -O- ${CALIBRE_INSTALLER_SOURCE_CODE_URL} | python2.7 -c "import sys; main=lambda:sys.stderr.write('Download failed\n'); exec(sys.stdin.read()); main(install_dir='/opt', isolated=True)"

# LazyLibrarian
RUN git clone --depth 1 https://gitlab.com/LazyLibrarian/LazyLibrarian.git /opt/lazylibrarian

# Upgrade pip and add apprise
RUN pip2.7 install --upgrade pip
RUN pip2.7 install apprise

# add local files
COPY rootfs/ /

# crontab
RUN yum install -y cronie
RUN (crontab -l 2>/dev/null; echo "* * * * * /usr/bin/verify-services.sh") | crontab -

#configure services (systemd)
RUN systemctl enable prepare-config.service
RUN systemctl enable lazylibrarian.service

VOLUME /config /books /audiobooks /magazines /comics /downloads

# End
CMD ["/usr/sbin/init"]