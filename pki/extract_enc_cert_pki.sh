#!/bin/bash
# extract_enc_cert_pki.sh.  
# Copyright (C) 2008-2010 Elia Pinto <yersinia.spiros@gmail.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#
# 
# Toy scripts for extracting the encryption cert from a LDAP directory
# Requires the openldap-clients and openssl rpm packages
##############
# Global Var
##############
# 
readonly TEMP_DIR="/tmp/pki_certs"
readonly LDAP_HOST="xxxxxx.xxxxx.xxxxx.xxxx"
readonly TEMP_DIR_ENCRYPTION="$TEMP_DIR/encryptioncert"
##############
# Main program
##############
[ ! -d $TEMP_DIR ] && mkdir -p $TEMP_DIR 
echo "extract_enc_cert_pki: searching the LDAP server $LDAP_HOST.........." 
/usr/bin/ldapsearch -x -T $TEMP_DIR -t -h $LDAP_HOST -E pr=100/noprompt -s sub -b "o=Banca d'Italia/00950501007,c=IT" "(cn=*)" >$TEMP_DIR/result.lis
cd $TEMP_DIR
[ ! -d $TEMP_DIR_ENCRYPTION ] && mkdir -p $TEMP_DIR_ENCRYPTION
echo "extract_enc_cert_pki: finding the encryption certificate in $TEMP_DIR.........." >&2
for f in $(/bin/find $TEMP_DIR -type f -name "ldapsearch*" ); do /usr/bin/openssl x509 -in "$f" -inform DER  -purpose | grep -E "S/MIME encryption.*:.*Yes" &>/dev/null; [ "$?" = 0 ] && echo "$f is an encryption certificate" >> $TEMP_DIR/result.lis && cp $f $TEMP_DIR_ENCRYPTION ; done &
echo "extract_enc_cert_pki: waiting for the finding to finish.........." >&2
wait
echo "extract_enc_cert_pki: SUCCESS. The encryption certs are in $TEMP_DIR_ENCRYPTION" >&2
exit 0
