#!/bin/bash

# https://superuser.com/a/1717924
### Script installs root.cert.pem to certificate trust store of applications using NSS
### (e.g. Firefox, Thunderbird, Chromium)
### Mozilla uses cert8, Chromium and Chrome use cert9

###
### Requirement: apt install libnss3-tools
###

###
### CA file to install (CUSTOMIZE!)
###

certfile="blumilk-environment-mkcert-root-ca-cert.pem"
certname="My Root CA"

###
### For cert8 (legacy - DBM)
###

while IFS= read -r -d '' certDB
do
    certdir=$(dirname "${certDB}")
    certutil -A -n "${certname}" -t "TCu,Cu,Tu" -i "${certfile}" -d dbm:"${certdir}"
done < <(find ~/ -name "cert8.db" -print0)

###
### For cert9 (SQL)
###

while IFS= read -r -d '' certDB
do
    certdir=$(dirname "${certDB}")
    certutil -A -n "${certname}" -t "TCu,Cu,Tu" -i "${certfile}" -d sql:"${certdir}"
done < <(find ~/ -name "cert9.db" -print0)
