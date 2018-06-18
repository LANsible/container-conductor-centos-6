FROM centos:6
LABEL maintainer="Wilmar den Ouden <info@wilmardenouden.nl>"

ENV ANSIBLE_CONTAINER=1

RUN yum install -y epel-release && \
    yum install -y make gcc git python-devel curl rsync libffi-devel openssl-devel centos-release-scl && \
    yum install -y python27 && \
    yum clean all

RUN source /opt/rh/python27/enable && \
    (curl https://bootstrap.pypa.io/get-pip.py | python - --no-cache-dir ) && \
    mkdir -p /etc/ansible/roles /_ansible/src && \
    (curl https://get.docker.com/builds/Linux/x86_64/docker-latest.tgz \
       | tar -zxC /usr/local/bin/ --strip-components=1 docker/docker )

# The COPY here will break cache if the version of Ansible Container changed
COPY ansible-container/ /_ansible/container/conductor-build/

RUN source /opt/rh/python27/enable && \
    cd /_ansible && \
    pip install --no-cache-dir -r container/conductor-build/conductor-requirements.txt && \
    PYTHONPATH=. LC_ALL="en_US.UTF-8" python container/conductor-build/setup.py develop -v -N && \
    ansible-galaxy install -p /etc/ansible/roles -r container/conductor-build/conductor-requirements.yml

ENTRYPOINT ["source /opt/rh/python27/enable"]
