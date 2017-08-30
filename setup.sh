#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

info() {
    if [ -t 2 ]; then
        echo -e "\033[0;37;44m$@\033[0;0m" >&2
    else
        echo -e "$@" >&2
    fi
}

greenline() {
    if [ -t 2 ]; then
        echo -e "\033[0;30;42m$@\033[0;0m" >&2
    else
        echo -e "$@" >&2
    fi
}
headerline() {
    echo ""
    if [ -t 2 ]; then
        echo -e "\033[0;37;45m** $@ **\033[0;0m" >&2
    else
        echo -e "$@" >&2
    fi
}

info "Updating packages.."

apt update

info "Upgrading packages.."
apt upgrade

info "Installing mail packages.."
apt install postfix dovecot-imapd dovecot-managesieved mailutils dirmngr -y

info "Installing acme (Let's Encrypt)"
echo 'deb http://ppa.launchpad.net/hlandau/rhea/ubuntu xenial main' > /etc/apt/sources.list.d/rhea.list
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 9862409EF124EC763B84972FF5AC9651EDB58DFA
apt-get update
apt-get install acmetool -y

info "Config time (manual steps)"

headerline "/etc/dovecot/conf.d/10-auth.conf"
greenline "auth_username_format = %n"

headerline "/etc/dovecot/conf.d/10-mail.conf"
greenline "mail_location = maildir:~/Maildir"

headerline "/etc/dovecot/conf.d/10-ssl.conf"
info "This file should point to certificate files"
greenline "ssl_cert = </var/lib/acme/live/DOMAIN/fullchain"
greenline "ssl_key = </var/lib/acme/live/DOMAIN/privkey"

headerline "/etc/dovecot/conf.d/15-lda.conf"
greenline "postmaster_address = postmaster@DOMAIN"
greenline "hostname = DOMAIN"
greenline "mail_plugins = $mail_plugins sieve"
