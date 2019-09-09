# FROM jenkins/jenkins:lts
FROM jenkins/jenkins:2.176.2

LABEL maintainer="leonard.lee@praqma.com"

COPY extra_plugins.txt /usr/share/jenkins/ref/extra_plugins.txt

ENV JENKINS_HOME /var/jenkins_home

ARG JAVA_OPTS
ENV JAVA_OPTS "-Djenkins.install.runSetupWizard=false ${JAVA_OPTS:-}"

RUN xargs /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/extra_plugins.txt
