FROM bvuser/centos7:1.0

RUN yum update -y
RUN yum clean all
RUN yum install -y httpd wget curl net-tools openssh-client openssh-server
RUN yum clean all

# creation user apache
RUN userdel apache
RUN useradd -d /home/apache -m apache && mkdir /home/apache/.ssh
RUN chmod 600 /home/apache/.ssh
RUN chown -R apache:apache /home/apache 
RUN chmod 755 /var/log/httpd
RUN chmod 755 /usr/sbin/httpd

# installation supervisor
RUN yum install -y python-setuptools libapache2-mod-php5 php5-cli php5 php5-mcrypt php5-curl php5-pgsql php5-mysql
RUN easy_install pip
RUN pip install supervisor



ADD ./assets/virtualhost /etc/apache2/sites-available/


#Environement 
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid
ENV APACHE_RUN_DIR /var/run/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_SERVERADMIN admin@localhost
ENV APACHE_SERVERNAME localhost
ENV APACHE_SERVERALIAS docker.localhost
ENV APACHE_DOCUMENTROOT /var/www

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
