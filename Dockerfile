
FROM registry.access.redhat.com/rhel7/rhel:7.4

MAINTAINER Matej R.

 

ARG user=jenkins

ARG group=jenkins

ARG uid=1000

ARG gid=1000

ARG GID_DOCKER=296

ARG JENKINS_AGENT_HOME=/home/${user}

 

## NOTE: Proxy required to download Docker CE

##

 

# Sync with node, and enable required repos

RUN yum repolist --disablerepo=* && \

    yum-config-manager --disable \* > /dev/null && \

    yum-config-manager --enable rhel-7-server-rpms > /dev/null && \

    yum-config-manager --enable rhel-7-server-extras-rpms > /dev/null

 

# Install packages without docs. Variable is used to cause yum to fail if missing

RUN INSTALL_PKGS="git java-1.8.0-openjdk-devel openssh-server" && \

    yum install -y $INSTALL_PKGS --setopt tsflags=nodocs && \

    yum clean all && \

    rm -rf /var/cache/yum

 

## NOTE: Docker CE is *NOT* supported on RHEL. Unable to get RHEL Docker working on Swarm cluster, forced to use CE.

ENV DOCKER_VERSION=17.12.1-ce

RUN curl -fsSLO https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz \

    && tar --strip-components=1 -xvzf docker-${DOCKER_VERSION}.tgz -C /usr/local/bin \

    && chmod -R +x /usr/local/bin/docker

 

ENV JENKINS_AGENT_HOME ${JENKINS_AGENT_HOME}


 



 

RUN groupadd -g ${gid} ${group} \

  && useradd -d "${JENKINS_AGENT_HOME}" -u "${uid}" -g "${gid}" -m -s /bin/bash "${user}" \

  && update-ca-trust extract \

  && groupadd docker -g $GID_DOCKER &&  gpasswd -a jenkins docker

 

# setup SSH server

RUN sed -i 's/#PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config \

  && sed -i 's/#RSAAuthentication.*/RSAAuthentication yes/' /etc/ssh/sshd_config \

  && sed -i 's/#PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config \

  && sed -i 's/#SyslogFacility.*/SyslogFacility AUTH/' /etc/ssh/sshd_config \

  && sed -i 's/#LogLevel.*/LogLevel INFO/' /etc/ssh/sshd_config \

  && mkdir /var/run/sshd \

  && rm /var/run/nologin

 

WORKDIR "${JENKINS_AGENT_HOME}"

 

COPY entrypoint.sh /usr/local/bin/entrypoint.sh

 

EXPOSE 22

 

ENTRYPOINT ["entrypoint.sh"]
