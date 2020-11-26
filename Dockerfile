# Official Install Guide
#     Base on https://superset.apache.org/docs/installation/installing-superset-from-scratch
# FAQ
#     https://github.com/apache/incubator-superset/issues/2137

#ARG OS_VERSION="20.04"
#ARG LANG_VERSION="3.8.5"
FROM ubuntu:20.04

ENV APP_VERSION="0.37.2"
# docker build -t initenv/superset:$APP_VERSION .

LABEL maintainer="tokoyi@gmail.com"
LABEL version=$APP_VERSION
LABEL description="Ubuntu20.04 + Python3 + Pip3 + Superset($APP_VERSION) Initially Project（with official samples）"

ENV BASE_DIR="/opt"
ENV PROJECT_HOME="initenv_superset"

ENV DEFAULT_USER="admin"
ENV DEFAULT_FIRSTNAME="admin"
ENV DEFAULT_LASTNAME="user"
ENV DEFAULT_EMAIL="admin@fab.org"
ENV DEFAULT_PASSWORD="admin"


#################################################
# Change apt-get Registry (Optional)
#################################################
RUN cp /etc/apt/sources.list /etc/apt/sources.list.bak \
    && echo "deb http://mirrors.aliyun.com/ubuntu/ focal main restricted universe multiverse\n\
deb http://mirrors.aliyun.com/ubuntu/ focal-security main restricted universe multiverse\n\
deb http://mirrors.aliyun.com/ubuntu/ focal-updates main restricted universe multiverse\n\
deb http://mirrors.aliyun.com/ubuntu/ focal-proposed main restricted universe multiverse\n\
deb http://mirrors.aliyun.com/ubuntu/ focal-backports main restricted universe multiverse\n\
deb-src http://mirrors.aliyun.com/ubuntu/ focal main restricted universe multiverse\n\
deb-src http://mirrors.aliyun.com/ubuntu/ focal-security main restricted universe multiverse\n\
deb-src http://mirrors.aliyun.com/ubuntu/ focal-updates main restricted universe multiverse\n\
deb-src http://mirrors.aliyun.com/ubuntu/ focal-proposed main restricted universe multiverse\n\
deb-src http://mirrors.aliyun.com/ubuntu/ focal-backports main restricted universe multiverse" > /etc/apt/sources.list


#################################################
# Update Packages List
#################################################
RUN apt-get update && mkdir -p $BASE_DIR/$PROJECT_HOME &&cd $BASE_DIR/$PROJECT_HOME


#################################################
# Install OS level dependencies
#################################################
RUN apt-get install -y build-essential libssl-dev libffi-dev python3-dev python3-pip libsasl2-dev libldap2-dev


#################################################
# Change pip Registry (Optional)
#################################################
RUN mkdir -p ~/.pip && touch pip.conf \
    && echo "[global]\n\
index-url = https://mirrors.aliyun.com/pypi/simple/\n\
[install]\n\
trusted-host=mirrors.aliyun.com" > ~/.pip/pip.conf


#################################################
# Install language(Python) level dependencies
#################################################
RUN pip3 --no-cache-dir install Pillow


#################################################
# Install Superset
#################################################
#RUN pip3 --no-cache-dir install apache-superset==$APP_VERSION \
RUN pip3 --no-cache-dir install apache-superset \
    && superset db upgrade \
    && export FLASK_APP=superset \
    && superset fab create-admin --username $DEFAULT_USER --firstname $DEFAULT_FIRSTNAME --lastname $DEFAULT_LASTNAME --email $DEFAULT_EMAIL --password $DEFAULT_PASSWORD \
    && superset load_examples \
    && superset init


#################################################  
# Clean up
#################################################
RUN apt-get -y clean && rm -rf /var/lib/apt/lists/* && rm -rf /tmp/pear/


EXPOSE 8088
HEALTHCHECK CMD ["curl", "-f", "http://localhost:8088/health"]

WORKDIR $BASE_DIR/$PROJECT_HOME

#ENTRYPOINT superset run --host=0.0.0.0 -p 8088 --with-threads --reload --debugger


CMD cd $BASE_DIR/$PROJECT_HOME \
    && echo '--- OS  Info --------------------------------------------------' \
    && cat /etc/issue \
    && uname -a \
    && date \
    && du -hsx / \
    && echo '--- ENV Info --------------------------------------------------' \
    && python3 -V \
    && pip3 -V \
    && pip3 list | grep setuptools \
    && pip3 list | grep superset \
    && echo '--- APP Info --------------------------------------------------' \
    && superset run --host=0.0.0.0 -p 8088 --with-threads --reload --debugger \
    #&& /bin/bash \
