# To make this package relocateable, change the Prefix: line
Summary: The RPM package management system
Name: rpm
%define version 3.0.5
Version: %{version}
Release: 51
Group: System Environment/Base
Source: ftp://ftp.rpm.org/pub/rpm/dist/rpm-3.0.x/rpm-%{version}.tar.gz
Source1: rpm-wrapper
Source2: rpm-find-provides-aix.c
Patch0: rpm-%{version}-aix.patch
Patch1: rpm-%{version}-payload.patch
Patch2: rpm-%{version}-typechk.patch
Patch3: rpm-%{version}-ramfs.patch
Patch4: rpm-%{version}-mode.patch
Patch5: rpm-%{version}-unsetenv.patch
Patch6: rpm-%{version}-pyhack.patch
Patch7: rpm-%{version}-freespace.patch
Patch8: rpm-%{version}-dbpath.patch
Patch9: rpm-%{version}-glob.patch
Patch10: rpm-%{version}-stat64.patch
Patch11: rpm-%{version}-open64.patch
Patch12: rpm-%{version}-reloc.patch
Patch13: rpm-%{version}-nonrpm.patch
License: GPL
Conflicts: patch < 2.5
BuildRoot: /var/tmp/%{name}-root
BuildRequires: db, make, zlib-devel
#The following should probably be removed for later versions of rpm.
BuildRequires: automake = 1.4
BuildRequires: db = 2.7.7
BuildRequires: libtool = 1.3.5
BuildRequires: bison = 1.34
BuildRequires: python = 2.1.1
BuildRequires: python-devel = 2.1.1
BuildRequires: autoconf = 2.59

Prefix: %{_prefix}
%define DEFCC cc

%description
The RPM Package Manager (RPM) is a powerful command-line driven package
management system capable of installing, uninstalling, verifying, querying, and
updating software packages.  Each software package consists of an archive of
files along with information about the package like its version, a description,
etc.

%package devel
Summary: Development files for applications which will manipulate RPM packages.
Group: Development/Libraries
Requires: rpm = %{version}, popt

%description devel
This package contains the RPM C library and header files.  These development
files will simplify the process of writing programs which manipulate RPM
packages and databases. These files are intended to simplify the process of
creating graphical package managers or any other tools that need an intimate
knowledge of RPM packages in order to function.

This package should be installed if you want to develop programs that will
manipulate RPM packages and databases.

%package build
Summary: Scripts and executable programs used to build packages.
Group: Development/Tools
Requires: rpm = %{version}

%description build
This package contains scripts and executable programs that are used to build
packages using RPM.

%package -n popt
Summary: A C library for parsing command line parameters.
Group: Development/Libraries
Version: 1.5

%description -n popt
Popt is a C library for parsing command line parameters.  Popt was heavily
influenced by the getopt() and getopt_long() functions, but it improves on them
by allowing more powerful argument expansion.  Popt can parse arbitrary argv[]
style arrays and automatically set variables based on command line arguments.
Popt allows command line arguments to be aliased via configuration files and
includes utility functions for parsing arbitrary strings into argv[] arrays
using shell-like rules.

Install popt if you're a C programmer and you'd like to use its capabilities.

%prep
%setup -q
%patch0 -p0 -b .aix
%patch1 -p1 -b .payload
%patch2 -p1 -b .typechk
%patch3 -p1 -b .ramfs
%patch4 -p1 -b .mode
%patch5 -p1 -b .unsetenv
%patch6 -p1 -b .hack
%patch7 -p0 -b .freespace
%patch8 -p0 -b .dbpath
%patch9 -p0 -b .glob
%patch10 -p0 -b .stat64
%patch11 -p0 -b .open64
%patch12 -p0 -b .reloc
%patch13 -p0 -b .nonrpm

%build
# Use the default compiler for this platform - gcc otherwise
if [[ -z "$CC" ]]
then
    if test "X`type %{DEFCC} 2>/dev/null`" != 'X'; then
       export CC=%{DEFCC}
    else
       export CC=gcc
    fi
fi
if test "X$CC" != 'Xgcc'; then
    export RPM_OPT_FLAGS=`echo $RPM_OPT_FLAGS | sed 's:-fsigned-char::'`
fi
if test "X$CC" = 'Xcc'; then
    RPM_OPT_FLAGS="$RPM_OPT_FLAGS -ma"
fi

libtoolize --force
(cd popt; libtoolize --force)
autoconf-2.13
(cd popt; autoconf)

%ifarch ppc rs6000
LDFLAGS="-Wl,-brtl"
%else
LDFLAGS=
%endif

CFLAGS="$RPM_OPT_FLAGS" LDFLAGS="$LDFLAGS" MKDIR=/usr/bin/mkdir \
  ./configure --disable-static  --prefix=%{prefix}
make CFLAGS="$RPM_OPT_FLAGS" LDFLAGS="$LDFLAGS" test1_LDFLAGS= test2_LDFLAGS=

# Workaround optimzation problem
rm lib/rpmio.o lib/rpmio.lo lib/librpm.la
RPM_OPT_FLAGS=`echo $RPM_OPT_FLAGS | sed 's:-O2::'`
make CFLAGS="$RPM_OPT_FLAGS" LDFLAGS="$LDFLAGS"

perl -pi -e "s|need_lib_prefix=unknown|need_lib_prefix=no|" libtool
perl -pi -e 's|-bnoentry|\\\$\{ENTRY\}|' libtool
make CC=gcc CFLAGS="-O2" LDFLAGS="$LDFLAGS -lpython2.1" -C python

${CC} -o find-provides-aix %{SOURCE2} -lld
ln -sf find-provides-aix find-provides


%install
rm -rf $RPM_BUILD_ROOT

make DESTDIR="$RPM_BUILD_ROOT" install
make DESTDIR="$RPM_BUILD_ROOT" install -C python
mkdir -p $RPM_BUILD_ROOT/etc/rpm

{ cd $RPM_BUILD_ROOT
  /usr/bin/strip .%{prefix}/bin/rpm
  /usr/bin/strip .%{prefix}/bin/rpm2cpio
  /usr/bin/strip .%{prefix}/lib/rpm/rpmputtext .%{prefix}/lib/rpm/rpmgettext
}

(cd $RPM_BUILD_ROOT
 mv .%{prefix}/src/redhat .%{prefix}/src/packages
 for dir in bin include src
 do
    mkdir -p usr/$dir
    cd usr/$dir
    ln -sf ../..%{prefix}/$dir/* .
    cd -
 done

 mkdir -p usr/lib
 cd usr/lib
 ln -sf ../..%{prefix}/lib/* .
)

#Install the wrapper script in /usr/bin.
rm -f $RPM_BUILD_ROOT/usr/bin/rpm
cp %{SOURCE1} ${RPM_BUILD_ROOT}/usr/bin/rpm

%clean
rm -rf $RPM_BUILD_ROOT

%post
/bin/rpm --initdb
mkdir -p /var/lib 2>/dev/null || :
chmod 755 /var/lib
ln -sf ../..%{prefix}/lib/rpm /var/lib/rpm

%files
%defattr(-,root,root)
%doc COPYING RPM-PGP-KEY CHANGES GROUPS doc/manual/*
%{prefix}/bin/rpm
%{prefix}/bin/rpm2cpio
%{prefix}/bin/gendiff
/usr/bin/rpm
/usr/bin/rpm2cpio
/usr/bin/gendiff

%{prefix}/lib/rpm/brp-*
%{prefix}/lib/rpm/config.guess
%{prefix}/lib/rpm/config.sub
%{prefix}/lib/rpm/convertrpmrc.sh
%{prefix}/lib/rpm/find-prov.pl
%{prefix}/lib/rpm/find-provides
%{prefix}/lib/rpm/find-req.pl
%{prefix}/lib/rpm/find-requires
%{prefix}/lib/rpm/macros
%{prefix}/lib/rpm/mkinstalldirs
%{prefix}/lib/rpm/rpmpopt
%{prefix}/lib/rpm/rpmrc
%{prefix}/lib/rpm/vpkg-provides.sh
%{prefix}/lib/rpm/vpkg-provides2.sh
/usr/lib/rpm

%dir %{prefix}/src/packages
%dir %{prefix}/src/packages/BUILD
%dir %{prefix}/src/packages/SPECS
%dir %{prefix}/src/packages/SOURCES
%dir %{prefix}/src/packages/SRPMS
%dir %{prefix}/src/packages/RPMS
%{prefix}/src/packages/RPMS/*
%dir /usr/src
%{prefix}/share/locale/*/LC_MESSAGES/rpm.mo
%{prefix}/man/man[18]/*.[18]*
%lang(pl) %{prefix}/man/pl/man[18]/*.[18]*
%lang(ru) %{prefix}/man/ru/man[18]/*.[18]*

%{prefix}/lib/librpm.so*
%{prefix}/lib/librpmbuild.so*
/usr/lib/librpm.so*
/usr/lib/librpmbuild.so*

%files build
%defattr(-,root,root)
%{prefix}/lib/rpm/check-prereqs
%{prefix}/lib/rpm/cpanflute
%{prefix}/lib/rpm/find-lang.sh
%{prefix}/lib/rpm/find-provides.perl
%{prefix}/lib/rpm/find-requires.perl
%{prefix}/lib/rpm/get_magic.pl
%{prefix}/lib/rpm/getpo.sh
%{prefix}/lib/rpm/http.req
%{prefix}/lib/rpm/magic.prov
%{prefix}/lib/rpm/magic.req
%{prefix}/lib/rpm/perl.prov
%{prefix}/lib/rpm/perl.req
%{prefix}/lib/rpm/rpmdiff
%{prefix}/lib/rpm/rpmdiff.cgi
%{prefix}/lib/rpm/rpmgettext
%{prefix}/lib/rpm/rpmputtext
%{prefix}/lib/rpm/u_pkg.sh

%files devel
%defattr(-,root,root)
%{prefix}/include/rpm
/usr/include/rpm

%files -n popt
%defattr(-,root,root)
%{prefix}/lib/libpopt.*
%{prefix}/share/locale/*/LC_MESSAGES/popt.mo
%{prefix}/man/man3/popt.3*
/usr/lib/libpopt.*

# These could go in a separate popt-devel but it doesn't seem worth it.
%{prefix}/include/popt.h
/usr/include/popt.h

%changelog
* Thu Jan 21 2010 Reza Arbab <arbab@austin.ibm.com> 3.0.5-50
- Update to accomodate possible future version numbers of AIX.

* Fri Jul 10 2009 Reza Arbab <arbab@austin.ibm.com> 3.0.5-49
- Fix bug where `rpm -i [non-rpm package file]` still returns 0.

* Wed Oct 22 2008 Reza Arbab <arbab@austin.ibm.com> 3.0.5-46
- Fix a bug reported with the --prefix flag.

* Tue Apr 15 2008 Reza Arbab <arbab@austin.ibm.com> 3.0.5-44
- Change the debug variable for find-provides from $DEBUG to $FIND_PROVIDES_DEBUG.
- Use open64/stat64 instead of open/stat.

* Fri Mar 14 2008 Reza Arbab <arbab@austin.ibm.com> 3.0.5-43
- Change %%{_dbpath} from a symlink to the actual directory.
- Tweak source to enable AIX 5.2 build environment.

* Tue Jan  8 2008 Reza Arbab <arbab@austin.ibm.com> 3.0.5-42
- New optimizations for find-provides.
- Add AIX 6.1 support in config.guess.

* Wed Jun  6 2006 Reza Arbab <arbab@austin.ibm.com> 3.0.5-41
- Add "os_compat" lines to rpmrc for possible future AIX releases.
- /usr/bin/rpm is now a wrapper script rather than a symlink.
- find-provides is now fast native code instead of a script

* Mon Apr 17 2006 Reza Arbab <arbab@austin.ibm.com> 3.0.5-38
- Attempt to fix a "space needed" calculation bug on systems with huge filesystems.

* Thu Nov 04 2004 David Clissold <cliss@austin.ibm.com> 3.0.5-37
- Rebuild with a find-provides fix (OBJECT_MODE)
-   While I'm at it, clean up some unused ia64 stuff.

* Mon Jul 02 2001 Marc Stephenson <marc@austin.ibm.com>
- Fix locale references

* Fri Mar 30 2001 Marc Stephenson <marc@austin.ibm.com>
- Disable mntent()-related calls

* Tue Mar 27 2001 Marc Stephenson <marc@austin.ibm.com>
- Fix mode verification comparison

* Sat Mar 24 2001 Marc Stephenson <marc@austin.ibm.com>
- Work in AIX RAM filesystem

* Thu Mar 08 2001 Marc Stephenson <marc@austin.ibm.com>
- Add logic for default compiler
- Rebuild against new shared objects

* Tue Feb 20 2001 aixtoolbox <aixtoollbox-l@austin.ibm.com>
- Account for different standard lib location in IA64 32-bit ABI

* Fri Oct 27 2000 pkgmgr <pkgmgr@austin.ibm.com>
- Modify for AIX Freeware distribution

* Fri Oct 27 2000 rpmpkg <rpmpkg@austin.ibm.com>
- Modify for build and installation on AIX 4.3 and 5.1

* Wed Mar  1 2000 Jeff Johnson <jbj@redhat.com>
- fix rpmmodule.so python bindings.

* Sun Feb 27 2000 Jeff Johnson <jbj@redhat.com>
- rpm-3.0.4 release candidate.

* Fri Feb 25 2000 Jeff Johnson <jbj@redhat.com>
- fix: filter excluded paths before adding install prefixes (#8709).
- add i18n lookaside to PO catalogue(s) for i18n strings.
- try for /etc/rpm/macros.specspo so that specspo autoconfigures rpm.
- per-platform configuration factored into /usr/lib/rpm subdir.

* Tue Feb 15 2000 Jeff Johnson <jbj@redhat.com>
- new rpm-build package to isolate rpm dependencies on perl/bash2.
- always remove duplicate identical package entries on --rebuilddb.
- add scripts for autogenerating CPAN dependencies.

* Wed Feb  9 2000 Jeff Johnson <jbj@redhat.com>
- brp-compress deals with hard links correctly.

* Mon Feb  7 2000 Jeff Johnson <jbj@redhat.com>
- brp-compress deals with symlinks correctly.

* Mon Jan 24 2000 Jeff Johnson <jbj@redhat.com>
- explicitly expand file lists in writeRPM for rpmputtext.
