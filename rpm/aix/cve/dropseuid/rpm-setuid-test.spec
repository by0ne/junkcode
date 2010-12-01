# Based on hardlink.spec

Name:		rpm-setuid-test
Version:	0
# rpmbuild -D 'rel 1' ... 
Release:	%{rel}%{?dist}
Summary:	Package to test RPM handling of setuid files

License:	GPL+
Source0:	rpm-setuid-test.c
BuildRoot:	%(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)

%description


%prep
%setup -q -c -T
install -pm 644 %{SOURCE0} rpm-setuid-test.c


%build
gcc -Wall -DVERSION='"%{version}"' -DRELEASE='"%{release}"' rpm-setuid-test.c -o rpm-setuid-test


%install
rm -rf $RPM_BUILD_ROOT
install -D -m 755 rpm-setuid-test $RPM_BUILD_ROOT%{_bindir}/rpm-setuid-test


%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root,-)
%attr(4755,root,root) /usr/bin/rpm-setuid-test
#%doc



%changelog

