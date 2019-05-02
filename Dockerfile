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
	
EXPOSE 8080 8443 
VOLUME ${ZEPPELIN_HOME}/logs \
       ${ZEPPELIN_HOME}/notebook \
       /etc/security/freeipa-backups
		   
# Add files to start/stop Zeppelin and manage freeipa backupt files
ADD scripts/zeppelin-stop /usr/sbin/zeppelin-stop
ADD scripts/freeipa-backupfiles.sh /usr/sbin/freeipa-backupfiles.sh
ADD scripts/zeppelin-start /usr/sbin/zeppelin-start
RUN chmod -v +x /usr/sbin/zeppelin-stop /usr/sbin/freeipa-backupfiles.sh /usr/sbin/zeppelin-start

WORKDIR ${ZEPPELIN_HOME}

RUN mkdir -p /etc/security/freeipa-backups && \
        chmod 777 /etc/security/freeipa-backups

CMD ["/usr/sbin/zeppelin-start"]
