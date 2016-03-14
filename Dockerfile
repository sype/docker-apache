FROM bvuser/centos7:1.0

RUN yum update -y
RUN yum clean all
RUN yum install -y wget curl net-tools

# installation httpd + dependancies
WORKDIR /tmp
RUN wget "ftp://rpmfind.net/linux/centos/7.2.1511/os/x86_64/Packages/mailcap-2.1.41-2.el7.noarch.rpm"
RUN rpm -ivh mailcap-2.1.41-2.el7.noarch.rpm
RUN yum install -y httpd-tools.x86_64
RUN wget "ftp://rpmfind.net/linux/centos/7.2.1511/os/x86_64/Packages/centos-logos-70.0.6-3.el7.centos.noarch.rpm"
RUN rpm -ivh centos-logos-70.0.6-3.el7.centos.noarch.rpm
RUN wget "ftp://rpmfind.net/linux/centos/7.2.1511/os/x86_64/Packages/httpd-2.4.6-40.el7.centos.x86_64.rpm"
RUN rpm -ivh httpd-2.4.6-40.el7.centos.x86_64.rpm

# creation user apache
RUN userdel apache
RUN useradd -d /home/apache -m apache && mkdir /home/apache/.ssh
RUN chmod 600 /home/apache/.ssh

# installation supervisor
RUN yum install -y python-setuptools
RUN easy_install pip
RUN pip install supervisor

#creation user deployer 
USER root
RUN useradd -d /home/deployer -m deployer && mkdir /home/deployer/.ssh
RUN echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDLPqBcb8x/L03D0+FuJSwxXAuqmAeGzKdfNnezN24NZvP+b2s3m79kiUaN0HjDtPSNQqR9sgX8SMhNevaK/j9+qo1Zq3jSGax8czTEaZdNbcu+gfXTbek4YSnle6LR/5poELV5NA4auNfpYpnZ8mC7OwWXaisKkJ19YQDb4TUKQ7W1ThIsgKqu6/8fQd3+UZES0aprTumggvBhA6OXy3xuFqwF42lPD62q1F+PcbSGaAh6OUG2627KHipkRy0swtVVH+LTFutinxGNULt9V1uyuwBqlBBIfBH8S++8ZJAAT+zUPScLvbLJGJnmMx2QL5t3djSAhcQSekhYbkbypis3 deployer-key" > /home/deployer/.ssh/authorized_keys
RUN chown deployer: /home/deployer/.ssh/authorized_keys
RUN chmod 600 /home/deployer/.ssh/authorized_keys
RUN yum install sudo.x86_64 -y
RUN touch /etc/sudoers.d/90-cloud-init-users
RUN chmod 644 /etc/sudoers.d/90-cloud-init-users
RUN echo "deployer ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/90-cloud-init-users
RUN yum install passwd -y

COPY assets/install_supervisor.sh /tmp/install_supervisor.sh
RUN /tmp/install_supervisor.sh
RUN rm -f /tmp/install_supervisor.sh
RUN mkdir -p /appli/supervisor
RUN chmod 777 /appli/supervisor
COPY assets/supervisord.conf /etc/supervisord.conf

WORKDIR /home/apache

EXPOSE 80

CMD /usr/bin/supervisord -c /etc/supervisord.conf -n
