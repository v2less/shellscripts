FROM openjdk:17-alpine
LABEL maintainer="freelxs@gmail.com"

ARG TARGET_SRC_DIR

ENV INSTALL_DIR /usr/local/lib
ENV CHECKSTYLE_VERSION 10.15.0 
ENV PMD_VERSION 6.55.0
ENV SHELLCHECK_VERSION v0.10.0
ENV SHFMT_VERSION v3.8.0

# Install curl
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories
RUN apk add --update --no-cache wget unzip curl tzdata git bash libxml2-utils py3-pip cppcheck jq
RUN cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone
# Install checkstyle
RUN curl -L -o ${INSTALL_DIR}/checkstyle.jar https://mirror.ghproxy.com/https://github.com/checkstyle/checkstyle/releases/download/checkstyle-${CHECKSTYLE_VERSION}/checkstyle-${CHECKSTYLE_VERSION}-all.jar
# Install PMD
RUN cd ${INSTALL_DIR} && \
  curl -L https://mirror.ghproxy.com/https://github.com/pmd/pmd/releases/download/pmd_releases%2F${PMD_VERSION}/pmd-bin-${PMD_VERSION}.zip --output pmd-bin-${PMD_VERSION}.zip &&\
  unzip pmd-bin-${PMD_VERSION}.zip && \
  mv pmd-bin-${PMD_VERSION} pmd && \
  rm pmd-bin-${PMD_VERSION}.zip
# Install shellcheck
RUN cd ${INSTALL_DIR} && \
    curl -L https://mirror.ghproxy.com/https://github.com/koalaman/shellcheck/releases/download/${SHELLCHECK_VERSION}/shellcheck-${SHELLCHECK_VERSION}.linux.x86_64.tar.xz --output shellcheck.tar.xz && \
    tar -xf shellcheck.tar.xz && \
    mv shellcheck-${SHELLCHECK_VERSION} shellcheck && \
    chmod +x shellcheck/shellcheck && \
    rm -rf shellcheck.tar.xz
# Install shfmt
RUN cd ${INSTALL_DIR} && \
  curl -L https://mirror.ghproxy.com/https://github.com/mvdan/sh/releases/download/${SHFMT_VERSION}/shfmt_${SHFMT_VERSION}_linux_amd64 --output shfmt && \
  chmod +x shfmt
RUN pip3 install pip --upgrade -i https://pypi.tuna.tsinghua.edu.cn/simple && \
    pip3 install --upgrade --ignore-installed black pylint pylint-json2checkstyle -i https://pypi.tuna.tsinghua.edu.cn/simple
# Copy scripts
COPY ./bin/ /usr/local/bin/
COPY ./rules/ /opt/rules/
RUN chmod +x /usr/local/bin/*

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
