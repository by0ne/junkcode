auth --useshadow  --passalgo=md5
bootloader --location=mbr --timeout=5
firewall --disabled
install
logging --level=info
part / --size 1024 --fstype=ext3
repo --cost=1 --name=fedora
--mirrorlist=https://mirrors.fedoraproject.org/metalink?repo=fedora-13&arch=$basearch
repo --cost=2 --name=updates
--mirrorlist=https://mirrors.fedoraproject.org/metalink?repo=updates-released-f13&arch=$basearch
#repo --cost=3 --name=livna
--baseurl=http://rpm.livna.org/repo/13/$basearch/
repo --cost=4 --name=rpmfusion-free
--mirrorlist=http://mirrors.rpmfusion.org/mirrorlist?repo=free-fedora-13&arch=$basearch
repo --cost=5 --name=rpmfusion-free-updates
--mirrorlist=http://mirrors.rpmfusion.org/mirrorlist?repo=free-fedora-updates-released-13&arch=$basearch
repo --cost=6 --name=rpmfusion-nonfree
--mirrorlist=http://mirrors.rpmfusion.org/mirrorlist?repo=nonfree-fedora-13&arch=$basearch
repo --cost=7 --name=rpmfusion-nonfree-updates
--mirrorlist=http://mirrors.rpmfusion.org/mirrorlist?repo=nonfree-fedora-updates-released-13&arch=$basearch

# login: root; pwd: root_test
rootpw --plaintext root_test
selinux --enforcing
skipx
text

%packages --nobase --excludedocs

#vital tools
kernel
bash
#selinux-policy
#selinux-policy-targeted
policycoreutils
libsemanage
checkpolicy
policycoreutils-python

#essential tools
rsyslog
vim-minimal


%post --nochroot

# selinux-policy-*.rpm = custom-built policies (must exist!)
rpm -ivh --root $INSTALL_ROOT ~/selinux-policy-*.rpm
%end

%post
/sbin/restorecon -rip /
%end
#==========================================
#
#Then, make sure you have the (customised) selinux-policy files and from
#the command line execute the following:
#
#livecd-creator -c test-sel.ks -f test-image
