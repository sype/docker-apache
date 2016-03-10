FROM bvuser/centos7:1.0

RUN yum update -y
RUN yum clean
RUN yum install -y wget curl net-tools httpd


# installation supervisor
RUN yum install -y python-setuptools
RUN easy_install pip
RUN pip install supervisor

#creation user deployer 
RUN useradd -d /home/deployer -m deployer && mkdir /home/deployer/.ssh
RUN echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDLPqBcb8x/L03D0+FuJSwxXAuqmAeGzKdfNnezN24NZvP+b2s3m79kiUaN0HjDtPSNQqR9sgX8SMhNevaK/j9+qo1Zq3jSGax8czTEaZdNbcu+gfXTbek4YSnle6LR/5poELV5NA4auNfpYpnZ8mC7OwWXaisKkJ19YQDb4TUKQ7W1ThIsgKqu6/8fQd3+UZES0aprTumggvBhA6OXy3xuFqwF42lPD62q1F+PcbSGaAh6OUG2627KHipkRy0swtVVH+LTFutinxGNULt9V1uyuwBqlBBIfBH8S++8ZJAAT+zUPScLvbLJGJnmMx2QL5t3djSAhcQSekhYbkbypis3 deployer-key" > /home/deployer/.ssh/authorized_keys
RUN chown deployer: /home/deployer/.ssh/authorized_keys
RUN chmod 600 /home/deployer/.ssh/authorized_keys
RUN touch /etc/sudoers.d/90-cloud-init-users
RUN chmod 644 /etc/sudoers.d/90-cloud-init-users
RUN echo "deployer ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/90-cloud-init-users

COPY assets/install_supervisor.sh /tmp/install_supervisor.sh
RUN /tmp/install_supervisor.sh
RUN rm -f /tmp/install_supervisor.sh
RUN mkdir -p /appli/supervisor
RUN chmod 777 /appli/supervisor
COPY assets/supervisord.conf /etc/supervisord.conf

EXPOSE 80

CMD /usr/bin/supervisord -c /etc/supervisord.conf -n
