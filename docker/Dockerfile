FROM xrobau/atlassian-base:20220425.05


ARG CROWD_VERSION
ARG CROWD_FILE
ARG CROWD_SRCURL
ARG CONTAINER_UID=1000
ARG CONTAINER_GID=1000
ARG CONTAINER_USER=crowd
ARG CONTAINER_GROUP=crowd
ARG CROWD_HOME=/var/atlassian/crowd
ARG CROWD_INSTALL=/opt/atlassian/crowd

RUN addgroup --gid ${CONTAINER_GID} ${CONTAINER_GROUP}
RUN adduser --system --uid ${CONTAINER_UID} --ingroup ${CONTAINER_GROUP} --home /home/crowd --shell /bin/bash ${CONTAINER_USER}

RUN wget ${CROWD_SRCURL} -O /usr/local/${CROWD_FILE} && \
	mkdir -p ${CROWD_INSTALL} && \
	tar --directory=${CROWD_INSTALL} --strip-components=1 -xvf /usr/local/${CROWD_FILE} && \
	chown -R ${CONTAINER_UID}.${CONTAINER_GID} ${CROWD_INSTALL} && \
	echo "crowd.home=${CROWD_HOME}" > ${CROWD_INSTALL}/crowd-webapp/WEB-INF/classes/crowd-init.properties

ENV CROWD_URL=http://localhost:8095/crowd \
    LOGIN_BASE_URL=http://localhost:8095 \
    CROWD_CONTEXT=ROOT \
    SPLASH_CONTEXT= \
    DEMO_CONTEXT= \
    CROWDID_CONTEXT= \
    OPENID_CONTEXT= \
    CROWD_INSTALL=${CROWD_INSTALL} \
    CROWD_PROXY_NAME=sso.xrob.au \
    CROWD_PROXY_PORT=443 \
    CROWD_PROXY_SCHEME=https

WORKDIR /var/atlassian/crowd
VOLUME /var/atlassian/crowd
EXPOSE 8095

RUN /usr/local/bin/patch.sh

COPY launch.sh common.sh docker-entrypoint.sh /home/crowd/

RUN export MYSQL_DRIVER_VERSION=5.1.44 && \
    mkdir -p ${CROWD_INSTALL}/crowd-webapp/WEB-INF/classes && \
    mkdir -p ${CROWD_INSTALL}/apache-tomcat/lib && \
    mkdir -p ${CROWD_INSTALL}/apache-tomcat/webapps/ROOT && \
    mkdir -p ${CROWD_INSTALL}/apache-tomcat/conf/Catalina/localhost && \
    rm -f ${CROWD_INSTALL}/apache-tomcat/lib/mysql-connector-java*.jar &&  \
    wget -O /tmp/mysql-connector-java-${MYSQL_DRIVER_VERSION}.tar.gz \
      http://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-${MYSQL_DRIVER_VERSION}.tar.gz && \
    tar xzf /tmp/mysql-connector-java-${MYSQL_DRIVER_VERSION}.tar.gz \
      -C /tmp && \
    cp /tmp/mysql-connector-java-${MYSQL_DRIVER_VERSION}/mysql-connector-java-${MYSQL_DRIVER_VERSION}-bin.jar \
      ${CROWD_INSTALL}/apache-tomcat/lib/mysql-connector-java-${MYSQL_DRIVER_VERSION}-bin.jar

RUN  ls -al ${CROWD_INSTALL} && \
    mv ${CROWD_INSTALL}/apache-tomcat/webapps/ROOT ${CROWD_INSTALL}/splash-webapp && \
    mv ${CROWD_INSTALL}/apache-tomcat/conf/Catalina/localhost ${CROWD_INSTALL}/webapps && \
    mkdir -p ${CROWD_INSTALL}/apache-tomcat/conf/Catalina/localhost && \
    chown -R 1000.1000 ${CROWD_INSTALL}

COPY splash-context.xml ${CROWD_INSTALL}/webapps/splash.xml


CMD ["/home/crowd/docker-entrypoint.sh", "crowd"]
