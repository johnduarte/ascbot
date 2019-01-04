FROM debian:jessie

# Install base nodejs.

RUN apt-get update
RUN apt-get install -y sudo \
                       curl \
                       git  \
                       vim


ENV VERSION=v4.9.1
ENV DISTRO=linux-x64
RUN curl -O https://nodejs.org/dist/$VERSION/node-$VERSION-$DISTRO.tar.gz
RUN mkdir /usr/local/lib/nodejs
RUN tar -xzvf node-$VERSION-$DISTRO.tar.gz  -C /usr/local/lib/nodejs
RUN mv /usr/local/lib/nodejs/node-$VERSION-$DISTRO /usr/local/lib/nodejs/node-$VERSION
RUN ln -s /usr/local/lib/nodejs/node-$VERSION/bin/node /usr/local/bin/node
RUN ln -s /usr/local/lib/nodejs/node-$VERSION/bin/npm /usr/local/bin/npm
RUN npm install -g coffee-script
RUN ln -s /usr/local/lib/nodejs/node-$VERSION/bin/coffee /usr/local/bin/coffee

# Install ascbot

RUN apt-get install bsdmainutils
RUN apt-get install cowsay

RUN adduser --disabled-password --gecos "" ascbot

COPY bin /home/ascbot/bin
COPY external-scripts.json /home/ascbot/
COPY package.json /home/ascbot/
COPY Procfile /home/ascbot/
COPY scripts /home/ascbot/scripts

RUN chmod 777 /srv

ENV HOME /home/ascbot
USER ascbot
WORKDIR /home/ascbot

RUN npm install
CMD ./bin/hubot -a slack -n ascbot
