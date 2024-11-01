# RPA
FROM ubuntu:latest

#=======================================
# Install Python and Basic Python Tools
#=======================================
RUN apt-get -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false update
RUN apt-get install -y python3 python3-pip python3-setuptools python3-dev python-distribute
RUN alias python=python3
RUN echo "alias python=python3" >> ~/.bashrc

#=================================
# Install Bash Command Line Tools
#=================================
RUN apt-get -qy --no-install-recommends install \
    sudo \
    unzip \
    wget \
    curl \
    libxi6 \
    libgconf-2-4 \
    vim \
    xvfb \
  && rm -rf /var/lib/apt/lists/*

#================
# Install Chrome
#================
RUN curl -sS -o - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && \
    echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list && \
    apt-get -yqq update && \
    apt-get -yqq install google-chrome-stable && \
    rm -rf /var/lib/apt/lists/*

#=================
# Install Firefox
#=================
RUN apt-get -qy --no-install-recommends install \
     $(apt-cache depends firefox | grep Depends | sed "s/.*ends:\ //" | tr '\n' ' ') \
  && rm -rf /var/lib/apt/lists/* \
  && cd /tmp \
  && wget --no-check-certificate -O firefox-esr.tar.bz2 \
    'https://download.mozilla.org/?product=firefox-esr-latest&os=linux64&lang=en-US' \
  && tar -xjf firefox-esr.tar.bz2 -C /opt/ \
  && ln -s /opt/firefox/firefox /usr/bin/firefox \
  && rm -f /tmp/firefox-esr.tar.bz2

#===========================
# Configure Virtual Display
#===========================

RUN sudo apt-get update
ENV TZ=America/Sao_Paulo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN sudo apt-get install x11vnc fluxbox -y

RUN set -e
RUN echo "Starting X virtual framebuffer (Xvfb) in background..."
RUN export DISPLAY=:1
RUN Xvfb -ac :1 -screen 1 1024x768x16 & \
    fluxbox & \
    x11vnc -display $DISPLAY -bg -forever -nopw -quiet -listen localhost -xkb > /dev/null 2>&1 &
RUN exec "$@"

EXPOSE 5900

CMD x11vnc -create -env FD_PROG=/usr/bin/fluxbox \
    -env X11VNC_FINDDISPLAY_ALWAYS_FAILS=1 \
        -env X11VNC_CREATE_GEOM=${1:-1024x768x16} \
        -gone 'killall Xvfb' \
        -bg -nopw -ncache 20


############################################################################################################################################

# #=======================
# # Update Python Version
# #=======================
# RUN apt-get update -y
# RUN apt-get -qy --no-install-recommends install python3.10
# RUN rm /usr/bin/python3
# RUN ln -s python3.10 /usr/bin/python3

# #=============================================
# # Allow Special Characters in Python Programs
# #=============================================
# RUN export PYTHONIOENCODING=utf8
# RUN echo "export PYTHONIOENCODING=utf8" >> ~/.bashrc

# #=====================
# # Set up SeleniumBase
# #=====================
# COPY sbase /SeleniumBase/sbase/
# COPY seleniumbase /SeleniumBase/seleniumbase/
# COPY examples /SeleniumBase/examples/
# COPY integrations /SeleniumBase/integrations/
# COPY requirements.txt /SeleniumBase/requirements.txt
# COPY setup.py /SeleniumBase/setup.py
# RUN find . -name '*.pyc' -delete
# RUN find . -name __pycache__ -delete
# RUN pip3 install --upgrade pip
# RUN pip3 install --upgrade setuptools
# RUN pip3 install --upgrade setuptools-scm
# RUN cd /SeleniumBase && ls && pip3 install -r requirements.txt --upgrade
# RUN cd /SeleniumBase && pip3 install .

# #=====================
# # Download WebDrivers
# #=====================
# RUN wget https://github.com/mozilla/geckodriver/releases/download/v0.33.0/geckodriver-v0.33.0-linux64.tar.gz
# RUN tar -xvzf geckodriver-v0.33.0-linux64.tar.gz
# RUN chmod +x geckodriver
# RUN mv geckodriver /usr/local/bin/
# RUN wget https://chromedriver.storage.googleapis.com/72.0.3626.69/chromedriver_linux64.zip
# RUN unzip chromedriver_linux64.zip
# RUN chmod +x chromedriver
# RUN mv chromedriver /usr/local/bin/

# #==========================================
# # Create entrypoint and grab example tests
# #==========================================
# COPY integrations/docker/docker-entrypoint.sh /
# COPY integrations/docker/run_docker_test_in_firefox.sh /
# COPY integrations/docker/run_docker_test_in_chrome.sh /
# RUN chmod +x *.sh
# COPY integrations/docker/docker_config.cfg /SeleniumBase/examples/
# # ENTRYPOINT ["/docker-entrypoint.sh"]
# # CMD ["/bin/bash"]

#######################################################################################################################################################

# #==========================================
# # Install VNC
# #==========================================

# ARG DOCKER_LANG=en_US
# ARG DOCKER_TIMEZONE=America/New_York
# ARG X11VNC_VERSION=latest

# ENV LANG=$DOCKER_LANG.UTF-8 \
#     LANGUAGE=$DOCKER_LANG:UTF-8 \
#     LC_ALL=$DOCKER_LANG.UTF-8

# WORKDIR /tmp

# ARG DEBIAN_FRONTEND=noninteractive

# # Install some required system tools and packages for X Windows and ssh.
# # Also remove the message regarding unminimize.
# # Note that Ubuntu 22.04 uses snapd for firefox, which does not work properly,
# # so we install it from ppa:mozillateam/ppa instead.
# RUN apt-get update && \
#     DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
#         apt-utils \
#         apt-file \
#         locales \
#         language-pack-en && \
#     locale-gen $LANG && \
#     dpkg-reconfigure -f noninteractive locales && \
#     DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
#         curl \
#         less \
#         vim \
#         psmisc \
#         runit \
#         apt-transport-https ca-certificates \
#         software-properties-common \
#         man \
#         sudo \
#         rsync \
#         libarchive-tools \
#         net-tools \
#         gpg-agent \
#         inetutils-ping \
#         csh \
#         tcsh \
#         zsh zsh-autosuggestions \
#         build-essential autoconf automake autotools-dev pkg-config \
#         libssl-dev \
#         git \
#         dos2unix \
#         dbus-x11 \
#         \
#         openssh-server \
#         python3-distutils \
#         python3-tk \
#         python3-dbus \
#         \
#         xserver-xorg-video-dummy \
#         lxde \
#         x11-xserver-utils xdotool \
#         xterm \
#         gnome-themes-standard \
#         gtk2-engines-pixbuf \
#         gtk2-engines-murrine \
#         libcanberra-gtk-module libcanberra-gtk3-module \
#         fonts-liberation \
#         xfonts-base xfonts-100dpi xfonts-75dpi xfonts-scalable xfonts-cyrillic \
#         libopengl0 mesa-utils libglu1-mesa libgl1-mesa-dri libjpeg8 libjpeg62 \
#         xauth xdg-utils \
#         x11vnc && \
#     chmod 755 /usr/local/share/zsh/site-functions && \
#     add-apt-repository -y ppa:mozillateam/ppa && \
#     echo 'Package: *' > /etc/apt/preferences.d/mozilla-firefox && \
#     echo 'Pin: release o=LP-PPA-mozillateam' >> /etc/apt/preferences.d/mozilla-firefox && \
#     echo 'Pin-Priority: 1001' >> /etc/apt/preferences.d/mozilla-firefox && \
#     apt install -y firefox && \
#     apt-get -y autoremove && \
#     ssh-keygen -A && \
#     bash -c "test ! -f /lib64/ld-linux-x86-64.so.2 || ln -s -f /lib64/ld-linux-x86-64.so.2 /lib64/ld-lsb-x86-64.so " && \
#     perl -p -i -e 's/#?X11Forwarding\s+\w+/X11Forwarding yes/g; \
#         s/#?X11UseLocalhost\s+\w+/X11UseLocalhost no/g; \
#         s/#?PasswordAuthentication\s+\w+/PasswordAuthentication no/g; \
#         s/#?PermitEmptyPasswords\s+\w+/PermitEmptyPasswords no/g' \
#         /etc/ssh/sshd_config && \
#     rm -f /etc/update-motd.d/??-unminimize && \
#     rm -f /etc/xdg/autostart/lxpolkit.desktop && \
#     chmod a-x /usr/bin/lxpolkit && \
#     rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# # Install websokify and noVNC
# RUN curl -O https://bootstrap.pypa.io/get-pip.py && \
#     python3 get-pip.py && \
#     pip3 install --no-cache-dir \
#         setuptools && \
#     pip3 install -U https://github.com/novnc/websockify/archive/refs/tags/v0.10.0.tar.gz && \
#     mkdir /usr/local/noVNC && \
#     curl -s -L https://github.com/x11vnc/noVNC/archive/refs/heads/x11vnc.zip | \
#           bsdtar zxf - -C /usr/local/noVNC --strip-components 1 && \
#     (chmod a+x /usr/local/noVNC/utils/launch.sh || \
#         (chmod a+x /usr/local/noVNC/utils/novnc_proxy && \
#          ln -s -f /usr/local/noVNC/utils/novnc_proxy /usr/local/noVNC/utils/launch.sh)) && \
#     rm -rf /tmp/* /var/tmp/*

# # Install latest version of x11vnc from source
# # Also, fix issue with Shift-Tab not working
# # https://askubuntu.com/questions/839842/vnc-pressing-shift-tab-tab-only
# RUN apt-get update && \
#     apt-get install -y libxtst-dev libssl-dev libvncserver-dev libjpeg-dev && \
#     \
#     mkdir -p /tmp/x11vnc-${X11VNC_VERSION} && \
#     curl -s -L https://github.com/LibVNC/x11vnc/archive/refs/heads/master.zip | \
#         bsdtar zxf - -C /tmp/x11vnc-${X11VNC_VERSION} --strip-components 1 && \
#     cd /tmp/x11vnc-${X11VNC_VERSION} && \
#     bash autogen.sh --prefix=/usr/local CFLAGS='-O2 -fno-common -fno-stack-protector' && \
#     make && \
#     make install 

# ########################################################
# # Customization for user and location
# ########################################################
# # Set up user so that we do not run as root in DOCKER
# ENV DOCKER_USER=ubuntu \
#     DOCKER_UID=9999 \
#     DOCKER_GID=9999 \
#     DOCKER_SHELL=/bin/zsh

# ENV DOCKER_GROUP=$DOCKER_USER \
#     DOCKER_HOME=/home/$DOCKER_USER \
#     SHELL=$DOCKER_SHELL


# # Change the default timezone to $DOCKER_TIMEZONE
# # Run ldconfig so that /usr/local/lib etc. are in the default
# # search path for dynamic linker
# RUN groupadd -g $DOCKER_GID $DOCKER_GROUP && \
#     useradd -m -u $DOCKER_UID -g $DOCKER_GID -s $DOCKER_SHELL -G sudo $DOCKER_USER && \
#     echo "$DOCKER_USER:"`openssl rand -base64 12` | chpasswd && \
#     echo "$DOCKER_USER ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
#     echo "$DOCKER_TIMEZONE" > /etc/timezone && \
#     ln -s -f /usr/share/zoneinfo/$DOCKER_TIMEZONE /etc/localtime

# ADD image/etc /etc
# ADD image/usr /usr
# ADD image/sbin /sbin
# ADD image/home $DOCKER_HOME

# # Make home directory readable to work with Singularity
# RUN mkdir -p $DOCKER_HOME/.config/mozilla && \
#     ln -s -f .config/mozilla $DOCKER_HOME/.mozilla && \
#     touch $DOCKER_HOME/.sudo_as_admin_successful && \
#     mkdir -p $DOCKER_HOME/shared && \
#     mkdir -p $DOCKER_HOME/.ssh && \
#     mkdir -p $DOCKER_HOME/.log && touch $DOCKER_HOME/.log/vnc.log && \
#     chown -R $DOCKER_USER:$DOCKER_GROUP $DOCKER_HOME && \
#     chmod -R a+r $DOCKER_HOME && \
#     find $DOCKER_HOME -type d -exec chmod a+x {} \;

# WORKDIR $DOCKER_HOME


# EXPOSE 5900
# EXPOSE 6080

# USER root
# ENTRYPOINT ["/sbin/my_init", "--", "/sbin/setuser", "root"]

# ENV DOCKER_CMD=startvnc.sh
# CMD ["$DOCKER_CMD"]

# CMD bash
# https://stackoverflow.com/questions/12050021/how-to-make-xvfb-display-visible
