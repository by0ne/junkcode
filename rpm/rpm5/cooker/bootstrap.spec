%{?!_usrlibrpm: %global	_usrlibrpm /usr/lib/rpm}
%{?!_rpmhome: %global _rpmhome /usr/lib/rpm}
%{?!python_version: %global python_version %(%{__python} -c "import sys; print(sys.version[0:3])")}

# These cannot use %%global as they're relying on variables initialized later
# and must therefore use %%define in stead...
%if %{?EVRD:0}%{?!EVRD:1}
%define EVRD %{?epoch:%{epoch}:}%{?version:%{version}}%{?release:-%{release}}%{?distepoch::%{distepoch}}
%endif

%if %{?find_lang:0}%{?!find_lang:1}
%define find_lang %{_rpmhome}/%{_target_vendor}/find-lang.pl %{buildroot}
%endif

%if %{?makeinstall_std:0}%{?!makeinstall_std:1}
%define	makeinstall_std make DESTDIR=%{?buildroot:%{buildroot}} install
%endif

%if %{?mklibname:0}%{?!mklibname:1}
%define mklibname(ds)  %{_lib}%{1}%{?2:%{2}}%{?3:_%{3}}%{-s:-static}%{-d:-devel}
%endif

%if %{with bootstrap}

%define lib64arches	x86_64 ppc64 sparc64 s390x mips64

%ifarch %lib64arches
    %define _lib lib64
%else
    %define _lib lib
%endif

%define	_prefix		/usr
%define	_libdir		%{_prefix}/%{_lib}
%define	_bindir		%{_prefix}/bin
%define	_sysconfdir	/etc
%define	_datadir	%{_prefix}/share
%define	_defaultdocdir	%{_datadir}/doc
%define	_localstatedir	/var
%define	_infodir	%{_datadir}/info

%define	_host_vendor	mandriva

BuildRoot:	%{_tmppath}/%{name}-%{version}-%{release}-buildroot

# in case of missing %buildroot on newer rpm versions where BuildRoot is disabled..
%{!?buildroot: %define buildroot %{_tmppath}/%{name}-%{version}-%{release}-buildroot}


%define	__find_requires %{_rpmhome}/%{_host_vendor}/find-requires %{?buildroot:%{buildroot}} %{?_target_cpu:%{_target_cpu}}
%define	__find_provides %{_rpmhome}/%{_host_vendor}/find-provides

%endif
