FROM ubuntu:16.04
LABEL NAME="mongoaudit"

WORKDIR /root

RUN apt-get -qq update
RUN apt-get -qq -y install curl

RUN curl -s https://mongoaud.it/install | bash

RUN chmod +x /root/mongoaudit
# ENTRYPOINT [ "/root/mongoaudit" ]