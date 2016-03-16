FROM node:latest

EXPOSE 8080

RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y \
  build-essential \
  curl \
  sudo \
  supervisor \
  wget

# Superviser configuration
RUN mkdir -p /var/log/supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Create a nonroot user and add it as a sudo user
RUN /usr/sbin/useradd --create-home --home-dir /usr/local/nonroot --shell /bin/bash nonroot
RUN /usr/sbin/adduser nonroot sudo
RUN echo "nonroot ALL=NOPASSWD: ALL" >> /etc/sudoers

RUN mkdir -p /var/log/app && chmod a+w /var/log/app

RUN npm install -g \
 bower \
 nodemon \
 mountebank

ADD package.json /usr/local/lib/package.json
RUN cd /usr/local/lib && npm install
RUN chown -R nonroot /usr/local/lib/node_modules

COPY ./ /usr/local/nonroot/app
RUN chown -R nonroot /usr/local/nonroot/app

WORKDIR /usr/local/nonroot/app

USER nonroot

CMD ["/usr/bin/supervisord"]
