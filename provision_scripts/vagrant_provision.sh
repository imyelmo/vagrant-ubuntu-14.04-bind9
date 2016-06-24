#!/bin/bash

# set parameter
DOMAINNAME=linux.example
DNSHOSTNAME=ubuntu-14-04-dns
DNSHOSTIP=192.168.96.111
DNSREVERSEZONE=96.168.192
RZONEOC1=${DNSHOSTIP%%.*}
DNSIPOC4=111

# install tools to automate this install
sudo apt-get -y update
sudo apt-get -y install bind9 bind9utils dnsutils bind9-doc

# configure bind9 options
sudo cp /vagrant/config_templ/named.conf.options.templ /etc/bind/named.conf.options
sudo sed -i -e "s/#{dnshostip}/${DNSHOSTIP}/g" /etc/bind/named.conf.options

# configure local file
sudo cp /vagrant/config_templ/named.conf.local.templ /etc/bind/named.conf.local
sudo sed -i -e "s/#{domainname}/${DOMAINNAME}/g" /etc/bind/named.conf.local
sudo sed -i -e "s/#{reversezone}/${DNSREVERSEZONE}/g" /etc/bind/named.conf.local
sudo sed -i -e "s/#{rzone1octet}/${RZONEOC1}/g" /etc/bind/named.conf.local

# configure forward zone
if [ ! -d "/etc/bind/zones" ]; then
  sudo mkdir "/etc/bind/zones"
fi
sudo cp /vagrant/config_templ/db.domain.templ /etc/bind/zones/db.${DOMAINNAME}
sudo sed -i -e "s/#{dnshostname}/${DNSHOSTNAME}/g" /etc/bind/zones/db.${DOMAINNAME}
sudo sed -i -e "s/#{domainname}/${DOMAINNAME}/g" /etc/bind/zones/db.${DOMAINNAME}
sudo sed -i -e "s/#{dnshostip}/${DNSHOSTIP}/g" /etc/bind/zones/db.${DOMAINNAME}
sudo cp /vagrant/config_templ/db.reverse.templ /etc/bind/zones/db.${RZONEOC1}
sudo sed -i -e "s/#{dnshostname}/${DNSHOSTNAME}/g" /etc/bind/zones/db.${RZONEOC1}
sudo sed -i -e "s/#{domainname}/${DOMAINNAME}/g" /etc/bind/zones/db.${RZONEOC1}
sudo sed -i -e "s/#{dnslastoctet}/${DNSIPOC4}/g" /etc/bind/zones/db.${RZONEOC1}

# check configuration
# sudo named-checkconf
# sudo named-checkzone ${DOMAINNAME} /etc/bind/zones/db.${DOMAINNAME}
# sudo named-checkzone ${RZONEOC1}.in-addr.arpa /etc/bind/zones/db.${RZONEOC1}

# restart bind service
# sudo /etc/init.d/bind9 start
# sudo /etc/init.d/bind9 stop
sudo /etc/init.d/bind9 restart

# configure client
sudo cp /vagrant/config_templ/resolv.conf.templ /etc/resolv.conf
sudo sed -i -e "s/#{dnshostip}/${DNSHOSTIP}/g" /etc/resolv.conf

# create key for nupdate
# configure forward zone
if [ ! -d "/home/vagrant/nsupdate_key" ]; then
  sudo mkdir "/home/vagrant/nsupdate_key"
fi
cd /home/vagrant/nsupdate_key
dnssec-keygen -a HMAC-MD5 -b 512 -n USER admin.${DOMAINNAME}
