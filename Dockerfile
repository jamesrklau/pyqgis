FROM ubuntu:20.04

ENV DEBIAN_FRONTEND noninteractive

WORKDIR /code

RUN export DEBIAN_FRONTEND=noninteractive \
    && export APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1 \
    && dpkg-divert --local --rename --add /sbin/initctl \
    && apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends apt-transport-https ca-certificates dirmngr gnupg2 wget \
    && wget -qO - https://qgis.org/downloads/qgis-2022.gpg.key | gpg --no-default-keyring --keyring gnupg-ring:/etc/apt/trusted.gpg.d/qgis-archive.gpg --import \
    && chmod a+r /etc/apt/trusted.gpg.d/qgis-archive.gpg \
    && echo "deb https://qgis.org/ubuntu focal main" > /etc/apt/sources.list.d/qgis.list \
    && apt-get -y update  \
    && apt-get install -y --no-install-recommends \
    python3-venv \
    && apt-get install -y --no-install-recommends \
    unzip \
    gosu \
    iputils-ping \
    xvfb \
    libgl1-mesa-dri \
    python3-psutil \
    python3-qgis \
    qgis-providers \
    qgis-server \
    && echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections \
    && apt-get -y --no-install-recommends install ttf-mscorefonts-installer \
    && apt-get -y purge wget \
    && apt-get clean && rm -rf /var/lib/apt/lists/* && rm -rf /usr/share/man \
    && rm -rf /root/.cache

RUN apt-get update && apt-get install -y --no-install-recommends python3-pip

ENV LC_ALL="C.UTF-8"

ENV QGIS_DISABLE_MESSAGE_HOOKS=1
ENV QGIS_NO_OVERRIDE_IMPORT=1

ENV PYTHONPATH=/usr/share/qgis/python
ENV LD_LIBRARY_PATH=/usr/lib
ENV QT_QPA_PLATFORM=offscreen

COPY patches/processing/tools/system.py /usr/share/qgis/python/plugins/processing/tools/system.py

COPY qgis-check-platform /usr/local/bin/

COPY ./requirements.txt ./requirements.txt
RUN python3 -m pip install --no-cache-dir --upgrade -r ./requirements.txt


CMD [ "qgis-check-platform" ]
