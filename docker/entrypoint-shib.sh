#!/bin/sh
envsubst < /etc/shibboleth/shibboleth2.xml > /etc/shibboleth/shibboleth2.xml.tmp
mv /etc/shibboleth/shibboleth2.xml.tmp /etc/shibboleth/shibboleth2.xml
envsubst < /etc/apache2/sites-available/000-shib.conf > /etc/apache2/sites-available/000-shib.conf.tmp
mv /etc/apache2/sites-available/000-shib.conf.tmp /etc/apache2/sites-available/000-shib.conf

service apache2 start
service shibd start
/bin/sh
