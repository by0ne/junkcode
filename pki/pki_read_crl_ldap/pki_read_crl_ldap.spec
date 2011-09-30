%define PackageName    pki_read_crl_ldap
%define PackageVersion 2.3
%define PackageRelease 1

###################################
%define web_document_root_applicativa_accreditata  /var/www/html
%define web_document_root_collaudo  /var/www/pkicrlcollaudo
%define web_crl_dir_accreditata        %{web_document_root_applicativa_accreditata}/crl
%define web_crl_dir_applicativa        %{web_document_root_applicativa_accreditata}/crl
%define web_crl_dir_collaudo           %{web_document_root_collaudo}/crl
###################################

Summary: Shell Utility for downloading a CRL in DER format from a DSA LDAP
Name:    %{PackageName}
Version: %{PackageVersion}
Release: %{PackageRelease}
URL: http://www.bancaditalia.it/
Packager: Divisione Sviluppo e Supporto Sistemi
Vendor:   Banca D'Italia
License:  GPL
Group: Applications/System

Source0: %{name}.sh
Source1: %{name}.crond
Source2: %{name}.logrotate
Source3: %{name}.conf

BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildRequires: /bin/bash
Requires: coreutils util-linux /usr/bin/perl openldap >= 2.0.11 httpd >= 2.2.3
BuildArch: noarch

# Patches 

%description
This utility retrieve in DER format the Certification Revocation List(s)
of the Bank of Italy PKI CA from a local DSA LDAP and 
store this on a local Web Server public folder.

%prep

cat <<EOF >README.%{name}
----------------------------------------------------------
             Description of the package
----------------------------------------------------------

================================
WHAT IS %{name} PACKAGE
================================

It retrieve in DER format the Certification Revocation List(s)
of the Bank of Italy PKI CA from a local DSA LDAP and 
store this on a local Web Server public folder.

It execute every minute via cron.

The utility write to /var/log/%{name}/%{name}.log the Error Log and
also to syslog with facility cron, priority err.
EOF

#empty

%build
#empty

%install
rm -rf $RPM_BUILD_ROOT
%{__mkdir_p} $RPM_BUILD_ROOT/%{_sbindir}
%{__mkdir_p} -p $RPM_BUILD_ROOT/%{web_crl_dir_accreditata}
%{__mkdir_p} -p $RPM_BUILD_ROOT/%{web_crl_dir_applicativa}
%{__mkdir_p} -p $RPM_BUILD_ROOT/%{web_crl_dir_collaudo}
%{__mkdir_p} $RPM_BUILD_ROOT/%{_localstatedir}/log/%{name}


%{__install} -m 755 %{SOURCE0}  $RPM_BUILD_ROOT/%{_sbindir}/

# install log rotation stuff
%{__mkdir_p} $RPM_BUILD_ROOT/etc/logrotate.d
%{__install} -m 644 %{SOURCE2} \
        $RPM_BUILD_ROOT/etc/logrotate.d/%{name}
# install cron stuf
%{__mkdir_p} $RPM_BUILD_ROOT%{_sysconfdir}/cron.d
%{__install} -m 644 %{SOURCE1} \
        $RPM_BUILD_ROOT%{_sysconfdir}/cron.d/%{name}
# install conf stuf
%{__mkdir_p} $RPM_BUILD_ROOT%{_sysconfdir}/%{name}
%{__install} -m 644 %{SOURCE3} \
	$RPM_BUILD_ROOT%{_sysconfdir}/%{name}
exit 0

%preun
if [ $1 = 0 ]; then
        [ -d "%{web_crl_dir_accreditata}" ] && %{__rm} -f %{web_crl_dir_accreditata}/*.*
        [ -d "%{web_crl_dir_applicativa}" ] && %{__rm} -f %{web_crl_dir_applicativa}/*.*
        [ -d "%{web_crl_dir_collaudo}" ] && %{__rm} -f %{web_crl_dir_collaudo}/*.*
fi
exit 0

%postun
if [ $1 = 0 ]; then
        %{__rm} -f  %{_localstatedir}/log/%{name}/%{name}.*
        %{__rm} -rf %{_localstatedir}/log/%{name}
fi
exit 0

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root)
%attr(755,root,root) %{_sbindir}/%{name}.sh
%attr(755,root,root) %dir %{web_crl_dir_accreditata}
%attr(755,root,root) %dir %{web_crl_dir_applicativa}
%attr(755,root,root) %dir %{web_crl_dir_collaudo}
%attr(755,root,root) %dir %{_localstatedir}/log/%{name}
%config(noreplace) %{_sysconfdir}/logrotate.d/%{name}
%config(noreplace) %{_sysconfdir}/cron.d/%{name}
%attr(755,root,root) %dir %{_sysconfdir}/%{name}
%config(noreplace) %{_sysconfdir}/%{name}/%{name}.conf
%doc README.pki_read_crl_ldap


%changelog
* Fri Sep 30 2011 Pinto Elia <elia.pinto@bancaditalia.it> 2.3-1
- update to version 2.3 : add crl to CA "collaudo" also
* Mon Dec  6 2010 Pinto Elia <elia.pinto@bancaditalia.it> 2.2-1
- update to version 2.2 : add crl to CA "applicativa" also
- added Requires for parent dir
* Thu Feb 21 2008 Pinto Elia <elia.pinto@bancaditalia.it> 2.1-3
- missing ownership of dir /etc/pki_read_crl_ldap
- erase log dir in last removal
* Tue Feb 12 2008 Pinto Elia <elia.pinto@bancaditalia.it> 2.1-2
- modified conf file and program because the new CA cn attr
* Tue Jan 29 2008 Pinto Elia <elia.pinto@bancaditalia.it> 2.1-1
- Added timeout function to pki_read_crl_ldap
* Mon Jan 14 2008 Pinto Elia <elia.pinto@bancaditalia.it> 2.0-1
- Review and upgrade for the RHEL5 PKI LDAP Proxy
* Mon Dec 20 2004 Pinto Elia <elia.pinto@bancaditalia.it> 1.0-1
- Initial Release on AIX(TM) 4.3.3

