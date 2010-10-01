Name:           zzuf
Version:        0.13
Release:        1%{?dist}
Summary:        zzuf is a transparent application input fuzzer

Group:          Development/Tools
License:        
URL:            http://caca.zoy.org/wiki/zzuf
Source0:        http://caca.zoy.org/files/zzuf/%{name}-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

BuildRequires:  
Requires:       

%description


%prep
%setup -q


%build
%configure
make %{?_smp_mflags}


%install
rm -rf $RPM_BUILD_ROOT
make install DESTDIR=$RPM_BUILD_ROOT


%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root,-)
%doc



%changelog
