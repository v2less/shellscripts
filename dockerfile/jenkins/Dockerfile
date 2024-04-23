FROM jenkins/jenkins:2.440.3-lts-jdk17
USER root
ARG DOCKER_GID=999  # 宿主机的 docker 组的 GID
ARG HOST_UID=1002   # 宿主机的 用户ID

RUN groupadd -g ${DOCKER_GID} docker \
    && usermod -u ${HOST_UID} -aG docker jenkins
USER jenkins
