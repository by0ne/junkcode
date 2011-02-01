#!/bin/bash
_BASEYUMREPO="/var/www/yumrepo/core/5Server/x86_64/updates/"
_REPOID="Cluster  ClusterStorage  rhn-tools-rhel-x86_64 VT"
touch $HOME//md5sum-v1.cache

###############
# XXXX Begin
###############

for repoid in ${_REPOID}
do
freedups --actuallylink ${_BASEYUMREPO}/Server/ ${_BASEYUMREPO}/${repoid}/
done
#
