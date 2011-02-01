#!/bin/bash
# mrepo_redhat.sh.
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
# Toy scripts for sync rhn channel to a yum repo
# requires the package freedups and the utility xxexample_freedups.sh 

_BASEYUMREPO="/var/www/yumrepo/core/5Server/x86_64/updates/"
_REPOID="rhel-x86_64-server-5 epel rhel-x86_64-server-vt-5 rhel-x86_64-server-cluster-storage-5 rhel-x86_64-server-cluster-5 rhel-x86_64-server-supplementary-5 rhel-x86_64-server-productivity-5"

###############
# XXXX Begin
###############
/bin/rm -rf ${_BASEYUMREPO}/rhel-x86_64-server-5
/bin/rm -rf ${_BASEYUMREPO}/rhel-x86_64-server-vt-5
/bin/rm -rf ${_BASEYUMREPO}/rhel-x86_64-server-cluster-storage-5 
/bin/rm -rf ${_BASEYUMREPO}/rhel-x86_64-server-cluster-5
find $_BASEYUMREPO -type l -exec /bin/rm -f {} \;
#
ln -s ${_BASEYUMREPO}/Server ${_BASEYUMREPO}/rhel-x86_64-server-5 
ln -s ${_BASEYUMREPO}/ClusterStorage ${_BASEYUMREPO}/rhel-x86_64-server-cluster-storage-5 
ln -s ${_BASEYUMREPO}/VT ${_BASEYUMREPO}/rhel-x86_64-server-vt-5 
ln -s ${_BASEYUMREPO}/Cluster ${_BASEYUMREPO}/rhel-x86_64-server-cluster-5 

#mkdir ${_BASEYUMREPO}/rhn-tools-rhel-x86_64-5

for rhel_repoid in rhel-x86_64-server-5 rhel-x86_64-server-vt-5 rhel-x86_64-server-cluster-storage-5 rhel-x86_64-server-cluster-5 rhel-x86_64-server-supplementary-5 rhel-x86_64-server-productivity-5
do
 /bin/rm -rf ${_BASEYUMREPO}/${rhel_repoid}/GetPackage 
 /bin/rm -rf ${_BASEYUMREPO}/${rhel_repoid}/getPackage
 [ -d ${_BASEYUMREPO}/${rhel_repoid} ] && ln -s ${_BASEYUMREPO}/${rhel_repoid} ${_BASEYUMREPO}/${rhel_repoid}/getPackage
done
###############
# XXXX End
###############

for repoid in ${_REPOID}
do
 #reposync  -l -p $_BASEYUMREPO -r $repoid
 reposync -n -l -p $_BASEYUMREPO -r $repoid
done
#
/bin/rm -rf ${_BASEYUMREPO}/rhel-x86_64-server-5
/bin/rm -rf ${_BASEYUMREPO}/rhel-x86_64-server-vt-5
/bin/rm -rf ${_BASEYUMREPO}/rhel-x86_64-server-cluster-storage-5 
/bin/rm -rf ${_BASEYUMREPO}/rhel-x86_64-server-cluster-5
find $_BASEYUMREPO -type l -exec /bin/rm -f {} \;
/usr/bin/xxexample_freedups.sh
_YUMREPOID="epel Server ClusterStorage VT Cluster rhn-tools-rhel-x86_64 rhel-x86_64-server-supplementary-5 rhel-x86_64-server-productivity-5"

###############
# XXXX Begin
###############
/bin/rm -rf ${_BASEYUMREPO}/rhel-x86_64-server-5
/bin/rm -rf ${_BASEYUMREPO}/rhel-x86_64-server-vt-5
/bin/rm -rf ${_BASEYUMREPO}/rhel-x86_64-server-cluster-storage-5 
/bin/rm -rf ${_BASEYUMREPO}/rhel-x86_64-server-cluster-5
#
ln -s ${_BASEYUMREPO}/Server ${_BASEYUMREPO}/rhel-x86_64-server-5 
ln -s ${_BASEYUMREPO}/ClusterStorage ${_BASEYUMREPO}/rhel-x86_64-server-cluster-storage-5 
ln -s ${_BASEYUMREPO}/VT ${_BASEYUMREPO}/rhel-x86_64-server-vt-5 
ln -s ${_BASEYUMREPO}/Cluster ${_BASEYUMREPO}/rhel-x86_64-server-cluster-5 

mkdir ${_BASEYUMREPO}/rhn-tools-rhel-x86_64-5 &>/dev/null

for rhel_repoid in rhel-x86_64-server-5 rhel-x86_64-server-vt-5 rhel-x86_64-server-cluster-storage-5 rhel-x86_64-server-cluster-5 rhel-x86_64-server-supplementary-5 rhel-x86_64-server-productivity-5
do
 /bin/rm -rf ${_BASEYUMREPO}/${rhel_repoid}/GetPackage 
 /bin/rm -rf ${_BASEYUMREPO}/${rhel_repoid}/getPackage
done
###############
# XXXX End
###############

#
/bin/rm -rf ${_BASEYUMREPO}/rhel-x86_64-server-5
/bin/rm -rf ${_BASEYUMREPO}/rhel-x86_64-server-vt-5
/bin/rm -rf ${_BASEYUMREPO}/rhel-x86_64-server-cluster-storage-5 
/bin/rm -rf ${_BASEYUMREPO}/rhel-x86_64-server-cluster-5
find $_BASEYUMREPO -type l -exec /bin/rm -f {} \;
#######################################
for yum_repoid in ${_YUMREPOID}
do
 comps_file="$(/usr/bin/find  ${_BASEYUMREPO}/$yum_repoid -type f -name "comps*.xml")"
 if [ -z "$comps_file" ]
 then
/usr/bin/createrepo -c /var/cache/yum --update ${_BASEYUMREPO}/$yum_repoid
 else
 _basename_comps="$(basename $comps_file)"
 rm -f ${_BASEYUMREPO}/$yum_repoid/${_basename_comps}
 ln -s  ${comps_file} ${_BASEYUMREPO}/$yum_repoid/${_basename_comps}
/usr/bin/createrepo -g "$comps_file" -c /var/cache/yum --update ${_BASEYUMREPO}/$yum_repoid
 fi
done
########################################
# i386                                 
########################################
#
_BASEYUMREPO="/var/www/yumrepo/core/5Server/i386/updates/"
_REPOID="epel32"
_YUMREPOID="epel"
for repoid in ${_REPOID}
do
 #reposync  -l -p $_BASEYUMREPO -r $repoid
 reposync -n -l -p $_BASEYUMREPO -r $repoid
done
for yum_repoid in ${_REPOID}
do
/usr/bin/createrepo -c /var/cache/yum --update ${_BASEYUMREPO}/$yum_repoid &>/dev/null
done
############
# Move to the generic yumrepo name
############
/bin/rm -rf $_BASEYUMREPO/${_YUMREPOID} &>/dev/null 
mv $_BASEYUMREPO/${_REPOID} $_BASEYUMREPO/${_YUMREPOID}
#######################################
# XXXX : notify xmlrpc serv on esil224
#######################################
[ -x /usr/bin/mrepo_redhat_notification.py ] && /usr/bin/mrepo_redhat_notification.py &>/dev/null &
######################################
# Update the rhn profile
######################################
rhn-profile-sync
exit 0
