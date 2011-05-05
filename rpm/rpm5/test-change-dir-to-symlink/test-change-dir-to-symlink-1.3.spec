Summary:	Test Package for testing changing directory to symlink on upgrade
Name:		test-change-dir-to-symlink
Version:	1
Release:	3
License:	LGPL
Group:		Amusements/Games
BuildRoot:	%{_tmppath}/%{name}-%{version}-root-%(id -u -n)
URL:		http://www.rpm5.org
BuildArch:      noarch

%description
This is the third package release of %{name}
In this release the /tmp/%{name} directory became
a symbolic link to /tmp/%{name}-directory.

%prep
#empty

%build
#empty

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}/tmp/%{name}-directory
ln -s  /tmp/%{name}-directory %{buildroot}/tmp/%{name}


%pretrans  -p /bin/bash
if [ -d /tmp/%{name} ]
then
  mv /tmp/%{name} /tmp/%{name}-directory
  ln -s /tmp/%{name}-directory /tmp/%{name} 
fi

%preun
if [ $1 = 0 ] ; then
[ -d /tmp/%{name}-directory ] && rm -rf /tmp/%{name}-directory
fi



%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(644,root,root,755)
/tmp/%{name}

%changelog
* Mon Aug 4 2010 Elia Pinto <devzero2000@rpm5.org> 1-3
- First Build
