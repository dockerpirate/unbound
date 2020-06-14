#!/bin/bash
# Updating Unbound resources.
# Place this into e.g. /etc/cron.monthly or /etc/cron.weekly
###[ unbound_ad_servers ]###
wget -O root.hints https://www.internic.net/domain/named.root
if [[ $? -eq 0 ]]; then
  mv /etc/unbound/unbound.conf.d/unbound_ad_servers /etc/unbound/unbound.conf.d/unbound_ad_servers.bak
  mv /etc/unbound/unbound.conf.d/unbound_ad_servers.new /etc/unbound/unbound.conf.d/unbound_ad_servers
  unbound-checkconf >/dev/null
  if [[ $? -eq 0 ]]; then
    rm /etc/unbound/unbound.conf.d/unbound_ad_servers.bak
    service unbound reload >/dev/null
  else
    echo "Warning: Errors in unbound configuration due to probably failed update of"
    echo "/etc/unbound/unbound.conf.d/unbound_ad_servers:"
    unbound-checkconf
    mv /etc/unbound/unbound.conf.d/unbound_ad_servers /etc/unbound/unbound.conf.d/unbound_ad_servers.new
    mv /etc/unbound/unbound.conf.d/unbound_ad_servers.bak /etc/unbound/unbound.conf.d/unbound_ad_servers
  fi
else
  echo "Download of unbound_ad_servers list failed!"
fi
###[ root.hints ]###
curl -o /etc/unbound/root.hints.new https://www.internic.net/domain/named.cache
if [[ $? -eq 0 ]]; then
  mv /etc/unbound/root.hints /etc/unbound/root.hints.bak
  mv /etc/unbound/root.hints.new /etc/unbound/root.hints
  unbound-checkconf >/dev/null
  if [[ $? -eq 0 ]]; then
    rm /etc/unbound/root.hints.bak
    service unbound reload >/dev/null
  else
    echo "Warning: Errors in newly downloaded root.hints file probably due to incomplete download:"
    unbound-checkconf
    mv /etc/unbound/root.hints /etc/unbound/root.hints.new
    mv /etc/unbound/root.hints.bak /etc/unbound/root.hints
  fi
else
  echo "Download of unbound root.hints failed!"
fi
