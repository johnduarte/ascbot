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
COPY --chown=ascbot:ascbot external-scripts.json /home/ascbot/
COPY --chown=ascbot:ascbot package.json /home/ascbot/
COPY Procfile /home/ascbot/

RUN chmod 777 /srv

ENV HOME /home/ascbot
USER ascbot
WORKDIR /home/ascbot

RUN npm install

# add credentials on build
ARG SSH_PRIVATE_KEY
RUN mkdir ~/.ssh/
RUN echo "${SSH_PRIVATE_KEY}" > ~/.ssh/id_rsa

# make sure your domain is accepted
RUN touch ~/.ssh/known_hosts
RUN ssh-keyscan github.com >> ~/.ssh/known_hosts

RUN chmod 700 ~/.ssh/id_rsa
RUN chmod 600 ~/.ssh/*

RUN git config --global user.email "rpc-automation@rackspace.com"
RUN git config --global user.name "rpc-automation"

COPY --chown=ascbot:ascbot scripts /home/ascbot/scripts

CMD ./bin/hubot --alias ! -a slack -n ascbot
