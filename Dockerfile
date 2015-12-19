FROM centos:6
MAINTAINER Gabe Conradi <gabe.conradi@gmail.com>

ENV OUTPUT_DIR /output
ENV GENESIS_DIR /genesis
VOLUME /output

# needed for livecd-creator
RUN curl -o epel.rpm https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm && \
  rpm -ivh epel.rpm && \
  rm epel.rpm

RUN yum install -y livecd-tools createrepo curl unzip rpm-build && \
  yum clean all


COPY . /genesis
WORKDIR /genesis

# perform the build of the image at runtime
CMD ["/genesis/docker-entrypoint.sh"]
