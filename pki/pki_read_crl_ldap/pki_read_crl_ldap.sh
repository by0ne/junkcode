#!/bin/bash
#
####################################################################
# pki_read_crl_ldap.sh
# $Id: pki_read_crl_ldap.sh,v 2.3  Thu Sep 29 15:06:19 CEST 2011 EP Exp $
####################################################################
# Function: 
#   - Extract crl from an LDAP repository and publish in
#     DER format  onto a locally folder accessible from a web server 
#     for the PKI project
#
# Author: 
#   - Divisione Architetture e Sicurezza (SISI)  - Banca D'Italia 
# Changelog:
#   - Mon Dec  6 18:35:28 CET 2004 v1.0
#     Initial release
#   - Mon Dec 20 12:14:49 CET 2004 v1.1
#     Rewrite for more uniform style
#   - Mon Jan 14 17:28:44 CET 2008 v2.0
#     Fixup for Linux style
#   - Tue Jan 29 17:19:10 CET 2008 v2.1
#     Added TimeOut function
#   - Mon Dec  6 11:37:36 CET 2010 v2.2
#     Add CA_APPLICATIVA
#     and use the xxx_APPLICATIVA env. Change TITOLARI definition
#     in ACCREDITATA : was wrong semantically
#     delete anyway ldapsearch-certificateRevocation from tmp
#   - Thu Sep 29 15:05:32 CEST 2011 v2.3
#     add CA_COLLAUDO 
# Credit   : style inspired from rhel-eal3.bash 
####################################################################
# Note on style (quoted from rhel-eal3.bash):
#  unipolar branches use && or || for readability
#  variables are in CAPS
#  backtick expansions $(use parens syntax)
#  functions are prefixed with a : comment for use with set -x
#  all code is inside a function (for tracking syntax errors w/set -x)
#  function names use StudlyCaps
#  local and readonly are used where appropriate
#  global vars and constants have a leading _
# End quote
#  command are invoked with assolute path for safety
##################################################################### 
:
: -- %Function Definitions
:

: --Die
#####################
# Purpose:
#  write an error message to syslog and to a logfile.
#  Then exit with error
# Parameters:
# $@ contain the error message
#####################
Die () {
   local MESSAGE="$@"
   local HOSTNAME="$(/bin/hostname)"
   local DATE="$(/bin/date '+%a %b %d %X')"

   echo "$DATE $HOSTNAME $_PROGNAME: ERROR: $MESSAGE" >> "${_LOGFILE}"
   /bin/chmod 444 ${_LOGFILE} >/dev/null 2>&1
   
   /usr/bin/logger -p ${_LOGFACILITY}.${_LOGPRI} -t "${_PROGNAME}" "ERROR: ${MESSAGE}"

   exit $_EXIT_FAILURE
}

: --Warn
#####################
# Purpose:
#  write an error message to syslog and to a logfile.
#  Then return with error
# Parameters:
# $@ contain the error message
#####################
Warn () {
   local MESSAGE="$@"
   local HOSTNAME="$(/bin/hostname)"
   local DATE="$(/bin/date '+%a %b %d %X')"

   echo "$DATE $HOSTNAME $_PROGNAME: ERROR: $MESSAGE" >> "${_LOGFILE}"
   /bin/chmod 444 ${_LOGFILE} >/dev/null 2>&1
   
   /usr/bin/logger -p ${_LOGFACILITY}.${_LOGPRI} -t "${_PROGNAME}" "ERROR: ${MESSAGE}"

   return $_EXIT_FAILURE
}
: --Backup_And_Copy_Crl
#####################
# Purpose:
#  Backup in .old the crl and move the result from ldapsearch
#  (hold in /tmp/ldapsearch*) in the final crl destination,
#  setting the correct permission for the httpd server
# Parameters:
#  $1 the old crl on the http server 
#  $2 the (temporary) crl estract from ldap search 
#####################
Backup_And_Copy_Crl () {

 [ ! -f "${2}" ] && Die "error Backup_And_Copy_Crl:  ${2} doesn't exist"
 [ -f "${1}" ]   && { /bin/cp "${1}" "${1}".old || Die "error Backup_And_Copy_Crl: backup copy of ${1}" ; }
 /bin/cp "${2}" "${1}" || Die "error Backup_And_Copy_Crl: cp of ${2} to ${1}"
 /bin/chmod 444 "${1}" || Die "error Backup_And_Copy_Crl: permess setting of ${1}"
 /bin/rm -f  "${2}" >/dev/null 2>&1
 ################################
 # For Selinux Label Tranquility
 # not so useful 
 ################################
 [ -x  /usr/bin/chcon ] && { /usr/sbin/selinuxenabled && /usr/bin/chcon -t httpd_sys_content_t  "${1}" "${1}".old &>/dev/null ; }
}

: --Retrieve_CRL_From_DSA
#
# Note: if the ldap search go wrong don't die
# but if the Backup go wrong die instead
Retrieve_CRL_From_DSA () {
        

        [ $# -ne 1 ] && Die "error Retrieve_CRL_From DSA: bad argument number" 
        
        local CA_TYPE="$1"
        if [[ ${CA_TYPE} = "CA_ACCREDITATA" ]]
        then
        	local SEARCH_BASE="${_SEARCH_BASE_ACCREDITATA}"
        	local WEB_CRL_FILE="${_WEB_CRL_FILE_ACCREDITATA}"
        else
       		if [[ ${CA_TYPE} = "CA_APPLICATIVA" ]]
       	        then
        		local SEARCH_BASE="${_SEARCH_BASE_APPLICATIVA}"
        		local WEB_CRL_FILE="${_WEB_CRL_FILE_APPLICATIVA}"
		else
       			if [[ ${CA_TYPE} = "CA_COLLAUDO" ]]
       	        	then
        			local SEARCH_BASE="${_SEARCH_BASE_COLLAUDO}"
        			local WEB_CRL_FILE="${_WEB_CRL_FILE_COLLAUDO}"
                        else
              			Die "error Retrieve_CRL_From DSA: bad parameter" 
                        fi
		fi
        fi 
	local LDAPSEARCH_TEMP=
	local LDAPSCOPE=base

	LDAPSEARCH_TEMP=$($_LDAPSEARCH -h $_LDAPHOST -b "${SEARCH_BASE}" -s "${LDAPSCOPE}" "${_LDAP_SEARCHFILTER}"  'CertificateRevocationList;binary' 2>/dev/null | /usr/bin/perl -0777 -ne 's/\n//gs; s/ //sg; print $1 if /:<\s*file:\s*(\/.*\/.*)/s ;' )

	if [[ "$?" -eq 0 && -e "${LDAPSEARCH_TEMP}" ]]
	then
	  Backup_And_Copy_Crl "${WEB_CRL_FILE}" "${LDAPSEARCH_TEMP}"
	  _LDAPSEARCH_TEMP_ALL="${LDAPSEARCH_TEMP} ${_LDAPSEARCH_TEMP_ALL}"
	else 
	  Warn "error in ldap search for PKI CRL"
	  return $_EXIT_FAILURE
	fi
}
: --TimeOut
#####################
# Purpose:
#  Set a script Timeout (a.k.a. SIGNALRM)
# Parameters:
# $1 contain the script pid
# $2 the timeout limit
#####################
TimeOut () {
 [ "$#" -ne 2 ] && return
 local PIDSELF="$1"
 local TIMEOUT_LIMIT="$2"

 kill -0 "$PIDSELF" >/dev/null 2>&1 || return
 sleep "$TIMEOUT_LIMIT"
 kill -0 "$PIDSELF" >/dev/null 2>&1 && \
           { Info "TimeOut reached....... Kill my self (pid=$PIDSELF)!!!!!!" ; kill -2 "$PIDSELF" >/dev/null 2>&1 ; kill -9 "$PIDSELF" >/dev/null 2>&1 ; }
}
:
: -- %Global Constants
:
##############################
# Error Constant
##############################
readonly _EXIT_SUCCESS=0
readonly _EXIT_FAILURE=1
##############################
# Program Name
##############################
readonly _PROGNAME="${0##*/}"
readonly _PROGNAME_CLEAN="${_PROGNAME%%.*}"
#
##############################
# Logfile and logging param
##############################
readonly _LOGFILE="/var/log/${_PROGNAME_CLEAN}/${_PROGNAME_CLEAN}.log"
##############################
# Priority/Facility for syslog
##############################
#
readonly _LOGPRI=err
readonly _LOGFACILITY=cron
#############
# Utility path:
#############
#
# This one is from openldap client ( which have the -t switch 
# to dump binary data in file - /tmp/ldapsearch* )
# Simple bind and anonymous search
_LDAPSEARCH="/usr/bin/ldapsearch -x -LLL -t"
#
:
: -- %Global Variables
:
# set PATH to include /sbin and /usr/sbin. Be paranoid as well.
PATH="/bin/:/sbin:/usr/bin:/usr/sbin"
export PATH
#
# Glob Temp file holdind the result files extracted by ldapsearch 
# with attribute 
# Certificate revocation list
#
_LDAPSEARCH_TEMP_ALL=""
#
###################
# Config File
###################
readonly _PKG_CONF_FILE=/etc/${_PROGNAME_CLEAN}/${_PROGNAME_CLEAN}.conf
#################################################
# TimeOut Function
# Please define _TIMEOUT_LIMIT(seconds)<= cron scheduling
#################################################
readonly _PIDSELF="$$"
readonly _TIMEOUT_LIMIT="50"
#
: --Main 
#######################################
# Main Program
#######################################
# Begin the Main Program body
#######################################
#
trap '[ -n "${_LDAPSEARCH_TEMP_ALL}" ] && /bin/rm -f "${_LDAPSEARCH_TEMP_ALL}" /tmp/ldapsearch-certificateRevocationList* ' EXIT 1 2 3 15
#
#
##############
# Control
##############
#
if [ ! -x "/usr/bin/ldapsearch" ] # bong: openldap rpm miss?
then
 Die "error /usr/bin/ldapsearch not found"
fi
[ ! -r "$_PKG_CONF_FILE" ] && Die "error file $_PKG_CONF_FILE not found"
###########################
# Configuration Parameters
# check
###########################
##
source "${_PKG_CONF_FILE}" 2>/dev/null || Die "error on executing ${_PKG_CONF_FILE}"
for _VAR_CONF in _LDAPHOST _LDAPSUFFIX_ACCREDITATA _LDAPSUFFIX_APPLICATIVA _WEB_DOCUMENT_ROOT_APPLICATIVA_ACCREDITATA _WEB_DOCUMENT_ROOT_COLLAUDO _WEB_CRL_DIR_ACCREDITATA _WEB_CRL_DIR_APPLICATIVA _WEB_CRL_DIR_COLLAUDO _WEB_CRL_FILE_ACCREDITATA _WEB_CRL_FILE_APPLICATIVA _WEB_CRL_FILE_COLLAUDO _OU_ACCREDITATA _OU_APPLICATIVA _OU_COLLAUDO _CN _OBJECTCLASS_CDP
do
   eval _var_indirect=\$${_VAR_CONF}
   [ -z "${_var_indirect}" ] && Die "error the configuration var $_VAR_CONF is not set"
done
##########################
# Set the TimeOut
# _PID_TIMEOUT_FUNCTION referenced on the
# program end
##########################
TimeOut "$_PIDSELF" "$_TIMEOUT_LIMIT" &
readonly _PID_TIMEOUT_FUNCTION="$!"
####################################
#
# Derived from above
#
readonly _SEARCH_BASE_ACCREDITATA="${_OU_ACCREDITATA},${_LDAPSUFFIX_ACCREDITATA}"
readonly _SEARCH_BASE_APPLICATIVA="${_OU_APPLICATIVA},${_LDAPSUFFIX_APPLICATIVA}"
readonly _SEARCH_BASE_COLLAUDO="${_OU_COLLAUDO},${_LDAPSUFFIX_COLLAUDO}"
readonly _LDAP_SEARCHFILTER="(objectClass=${_OBJECTCLASS_CDP})"
#
# Use below if you Want use SmartCard Logon (AD) in face of a CA Key Change
#readonly _LDAP_SEARCHFILTER="(&(${_CN})(objectClass=${_OBJECTCLASS_CDP}))"
#
#
# Create subdirectories of web document root
# First Accreditata/Applicativa next collaudo
#
if [  -d "${_WEB_DOCUMENT_ROOT_APPLICATIVA_ACCREDITATA}" ]
then
   ################################
   # First pass: try to create it
   # if they doesn't exists
   ################################
	if [ ! -d "${_WEB_CRL_DIR_ACCREDITATA}" ]
	then
         /bin/mkdir -p "${_WEB_CRL_DIR_ACCREDITATA}"     || Die "error in creating dir ${_WEB_CRL_DIR_ACCREDITATA}"
         /bin/chmod +rx "${_WEB_CRL_DIR_ACCREDITATA}"    || Die "error in setting perms ${_WEB_CRL_DIR_ACCREDITATA}"
	fi
	if [ ! -d "${_WEB_CRL_DIR_APPLICATIVA}" ]
	then
         /bin/mkdir -p "${_WEB_CRL_DIR_APPLICATIVA}"     || Die "error in creating dir ${_WEB_CRL_DIR_APPLICATIVA}"
         /bin/chmod +rx "${_WEB_CRL_DIR_APPLICATIVA}"    || Die "error in setting perms ${_WEB_CRL_DIR_APPLICATIVA}"
	fi
else
 Die "error the directory ${_WEB_DOCUMENT_ROOT_APPLICATIVA_ACCREDITATA} doesn't exist"
fi
#
[  ! -d "${_WEB_DOCUMENT_ROOT_COLLAUDO}" ] && /bin/rm -f "${_WEB_DOCUMENT_ROOT_COLLAUDO}" && /bin/mkdir -p "${_WEB_DOCUMENT_ROOT_COLLAUDO}"
if [ ! -d "${_WEB_CRL_DIR_COLLAUDO}" ]
then
    /bin/mkdir -p "${_WEB_CRL_DIR_COLLAUDO}"     || Die "error in creating dir ${_WEB_CRL_DIR_COLLAUDO}"
    /bin/chmod +rx "${_WEB_CRL_DIR_COLLAUDO}"    || Die "error in setting perms ${_WEB_CRL_DIR_COLLAUDO}"
fi

#############################
# First crl : CA_ACCREDITATA 
#############################
Retrieve_CRL_From_DSA CA_ACCREDITATA
#############################
# Seconf : CA_APPLICATIVA 
#############################
Retrieve_CRL_From_DSA CA_APPLICATIVA
#############################
# Third : CA_COLLAUDO 
#############################
Retrieve_CRL_From_DSA CA_COLLAUDO
##############################
# Not necessary but anyway ...
##############################
# 
/bin/rm -f  "${_LDAPSEARCH_TEMP_ALL}" /tmp/ldapsearch-certificateRevocationList*
#
##############################
# Destroy the TimeOut function
##############################
kill -0 "$_PID_TIMEOUT_FUNCTION" >/dev/null 2>&1 && kill -9 "$_PID_TIMEOUT_FUNCTION" >/dev/null 2>&1
##############################
#
exit $_EXIT_SUCCESS
