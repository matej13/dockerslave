#!/bin/bash

 

set -ex

 

# Usage:

#  docker run jenkinsci/ssh-slave <public key>

# or

#  docker run -e "JENKINS_SLAVE_SSH_PUBKEY=<public key>" jenkinsci/ssh-slave

 

write_key() {

                mkdir -p "${JENKINS_AGENT_HOME}/.ssh"

                echo "$1" > "${JENKINS_AGENT_HOME}/.ssh/authorized_keys"

                chown -Rf jenkins:jenkins "${JENKINS_AGENT_HOME}/.ssh"

                chmod 0700 -R "${JENKINS_AGENT_HOME}/.ssh"

}

 

# ensure variables passed to docker container are also exposed to ssh sessions

env | grep _ >> /etc/environment

 

ssh-keygen -A

 

if [[ $JENKINS_SLAVE_SSH_PUBKEY == ssh-* ]]; then

  write_key "${JENKINS_SLAVE_SSH_PUBKEY}"

fi

if [[ $# -gt 0 ]]; then

  if [[ $1 == ssh-* ]]; then

    write_key "$1"

    shift 1

  else

    exec "$@"

  fi

fi

 

exec /usr/sbin/sshd -D -e
