FROM centos:7
MAINTAINER Gabe Conradi <gabe.conradi@gmail.com>

ENV OUTPUT_DIR /output
ENV GENESIS_DIR /genesis
ENV KICKSTART genesis-sl7.ks
VOLUME /output

RUN yum install -y livecd-tools createrepo rpm-build && \
  yum clean all

COPY . /genesis
WORKDIR /genesis

# perform the build of the image at runtime
CMD ["/genesis/docker-entrypoint.sh"]
