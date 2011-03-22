#!/bin/bash
#
##########################################################
#  Enumerates package  dependencies  for  the  set  of  file
#  on the directory argument
#
#  rpm-find-deps.sh <RPM_BUILD_ROOT directory>
#
#  Copyright (C) 2006 Elia Pinto
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  The Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
##########################################################
Usage() {
   echo "${_PROGNAME}: Error: usage : ${_PROGNAME} [-R|-P] <RPM_BUILD_ROOT dir>" >&2
   exit 1
}
readonly _PROGNAME=${0##*/}
[ $# -ne 2 ] &&  Usage
while getopts "RP" opt; do
        case "$opt" in
        R)    _type_dep="-R" ; break;;
        P)    _type_dep="-P" ; break;;
        *)      Usage;;
        \?)     Usage;;
        esac
done
shift $(($OPTIND - 1))
[ $# -ne 1 ] && Usage
[ ! -d "$1" ] && { echo "${_PROGNAME}: Error: $1 not found or not a directory" >&2 ; exit 1 ; }
[ ! -x /usr/lib/rpm/rpmdeps ] && { echo "${_PROGNAME}: Error: /usr/lib/rpm/rpmdeps not found" >&2 ; exit 1 ; }
for _f in $(/usr/bin/find "$1" ! -name "*.debug" -type f )
do
_risdep=$(/usr/lib/rpm/rpmdeps ${_type_dep} <<EOF
${_f}
EOF
)
[ -n "${_risdep}" ] && { echo "${_f}"; echo -e "${_risdep}" ; }
done
