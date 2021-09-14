FROM ubuntu:focal

RUN apt upgrade
RUN apt update

# ===========================================================================
# download apache, use the noninteractive installation for docker setup
ENV DEBIAN_FRONTEND=noninteractive
RUN apt install -y apache2

# ===========================================================================
# create SSL certificates in apache2 config directory
# can be replaced with any SSL certs, just put them in /etc/apache2/ssl/
RUN mkdir /etc/apache2/ssl
RUN openssl req -x509 -nodes -days 1095 -newkey rsa:2048 \
  -out /etc/apache2/ssl/server.crt \
  -keyout /etc/apache2/ssl/server.key \
  -subj "/C=US"

# enable SSL on the apache server
RUN a2enmod ssl

# replace the default site with our own site
COPY ./docker/httpd.conf /etc/apache2/sites-available/000-shib.conf
RUN a2dissite 000-default
RUN a2ensite 000-shib


# ===========================================================================
# download the shibboleth repo
# shibboleth 3.2.2
WORKDIR /downloads
RUN apt install -y curl
RUN curl --fail --remote-name \
  https://pkg.switch.ch/switchaai/ubuntu/dists/focal/main/binary-all/misc/switchaai-apt-source_1.0.0~ubuntu20.04.1_all.deb
RUN apt install ./switchaai-apt-source_1.0.0~ubuntu20.04.1_all.deb
RUN apt update

# install shibboleth
RUN apt install -y --install-recommends shibboleth
RUN apt -y full-upgrade

# ===========================================================================

# shibboleth config
COPY ./docker/shib/attribute-map.xml /etc/shibboleth/
COPY ./docker/shib/sp-signing-cert.pem /etc/shibboleth/
COPY ./docker/shib/sp-signing-key.pem /etc/shibboleth/
COPY ./docker/shib/sp-encrypt-cert.pem /etc/shibboleth/
COPY ./docker/shib/sp-encrypt-key.pem /etc/shibboleth/
COPY ./docker/shib/inc-md-cert-mdq.pem /etc/shibboleth/

# add shibboleth protection to the apache server
COPY ./docker/shib.conf /etc/apache2/conf-enabled

# run entrypoint script to generate shibboleth2.xml
# based on entity ID received from runtime argument
RUN apt install -y gettext
COPY ./docker/shib/shibboleth2.xml /etc/shibboleth/shibboleth2.xml
COPY ./docker/entrypoint-shib.sh /
ENTRYPOINT ["/entrypoint-shib.sh"]

# save space
RUN apt autoclean && apt autoremove
