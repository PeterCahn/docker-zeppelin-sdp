# Clone from the CentOS 7
FROM centos/systemd

MAINTAINER Pietro Cannalire

RUN yum swap -y -- remove fakesystemd -- install systemd systemd-libs && yum clean all


### Installing FreeIPA client
RUN yum install -y ipa-client dbus-python perl 'perl(Data::Dumper)' 'perl(Time::HiRes)' && yum clean all

### Adding dbus.service and systemctl
ADD systemd/dbus.service /etc/systemd/system/dbus.service
RUN ln -sf dbus.service /etc/systemd/system/messagebus.service

ADD systemd/systemctl /usr/bin/systemctl
RUN chmod -v +x /usr/bin/systemctl


### Installing Java - OpenJDK
RUN yum install -y java-1.8.0-openjdk-devel && java -version


### Installing Zeppelin
ARG DIST_MIRROR=http://archive.apache.org/dist/zeppelin 
ARG VERSION=0.7.3

ENV ZEPPELIN_HOME=/opt/zeppelin

RUN yum install -y curl ntp jq && yum clean all && \
    mkdir -p ${ZEPPELIN_HOME} && \
	curl ${DIST_MIRROR}/zeppelin-${VERSION}/zeppelin-${VERSION}-bin-all.tgz | tar xvz -C ${ZEPPELIN_HOME} && \
	mv ${ZEPPELIN_HOME}/zeppelin-${VERSION}-bin-all/* ${ZEPPELIN_HOME} && \
	rm -rf ${ZEPPELIN_HOME}/zeppelin-${VERSION}-bin-all && \
	rm -rf *.tgz
	
RUN printf "[HDP-2.6]\nname=HDP-2.6\nbaseurl=http://public-repo-1.hortonworks.com/HDP/centos6/2.x/updates/2.6.0.3\n\npath=/\nenabled=1\ngpgcheck=0\n" > /etc/yum.repos.d/HDP-2.6.repo && \
   mkdir -p /tmpzepp/selected && \
   yum install --downloadonly --downloaddir=/tmpzepp zeppelin && \
   cd /tmpzepp/selected && \
   rpm2cpio ../zeppelin_2_6_0_3_8-0.7.0.2.6.0.3-8.noarch.rpm | cpio -ivd './usr/hdp/2.6.0.3-8/zeppelin/interpreter/jdbc/*' && \
   /bin/cp -f /tmpzepp/selected/usr/hdp/2.6.0.3-8/zeppelin/interpreter/jdbc/* /opt/zeppelin/interpreter/jdbc/ && \
   yum clean all && rm -rf /tmpzepp

EXPOSE 8080 8443 
VOLUME ${ZEPPELIN_HOME}/logs \
       ${ZEPPELIN_HOME}/notebook \
       /etc/security/freeipa-backups
		   
# Add files to start/stop Zeppelin and manage freeipa backup files
ADD scripts/zeppelin-stop /usr/sbin/zeppelin-stop
ADD scripts/backupfiles.sh /usr/sbin/backupfiles.sh
ADD scripts/zeppelin-start /usr/sbin/zeppelin-start
ADD scripts/default-notebooks/ ${ZEPPELIN_HOME}/default-notebooks/
RUN chmod -v +x /usr/sbin/zeppelin-stop /usr/sbin/backupfiles.sh /usr/sbin/zeppelin-start

WORKDIR ${ZEPPELIN_HOME}

RUN mkdir -p /etc/security/backups && \
        chmod 777 /etc/security/backups

CMD ["/usr/sbin/zeppelin-start"]
