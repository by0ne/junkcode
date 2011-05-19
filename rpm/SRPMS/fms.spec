# Don't try fancy stuff like debuginfo, which is useless on binary-only
# packages.
# Be sure buildpolicy set to do nothing
%define	SSPP fms
%define	__spec_install_post %{nil}
%define	debug_package %{nil} 
%define	__os_install_post %{_dbpath}/brp-compress
#
%define	_fms_name fms
%define	_fms_version 3.5.4

#
Summary: Flash Media Interactive Server
Name: %{_fms_name}
Version: %{_fms_version}
Release: 1%{?dist}
Source0: %{_fms_name}-%{version}.tar.gz
Source1: fms.init
Source2: fms-ld.conf
Patch1: fms-3.5.3-status.patch

NoSource:0
NoSource:1
NoSource:2
License: Commercial
Group: System Environment/Daemons
BuildRoot:  %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildRequires: /bin/cp
Requires(post): /sbin/chkconfig
Requires(postun): /sbin/service
Requires(pre): shadow-utils 

%description
Adobe Flash Media Interactive Server software is a scalable, high-performance 
streaming media server that also supports multiway applications, including 
webcam chat, online games, VoIP, and a range of other interactive possibilities

%prep
#
#
%setup -q -c  
#%{__mv} %{name}/docs .
perl -i -pe 's#SERVER.PROCESS_UID\s*=\s*.*#SERVER.PROCESS_UID = 10003#g' opt/adobe/fms/conf/fms.ini 
perl -i -pe 's#SERVER.PROCESS_GID\s*=\s*.*#SERVER.PROCESS_GID = 10003#g' opt/adobe/fms/conf/fms.ini 
cp %{SOURCE1} .

%patch1 -p0 -b .status

# Filter unwanted Requires:
cat << \EOF > %{name}-req
#!/bin/sh
%{__perl_requires} \
| grep -v 'perl(namespace)'
EOF
%define __perl_requires %{_builddir}/%{name}-%{version}/%{name}-req
chmod +x %{__perl_requires}


%build
cat <<EOF >%{SSPP}_uidgid

########### Notes on UID/GID allocation ################
The package %{name} create the user and group
%{SSPP} as follow:

UID: 10003
GID: 10003

EOF


%install
%{__rm} -rf $RPM_BUILD_ROOT
%{__mkdir_p} -m 755 \
	$RPM_BUILD_ROOT/opt/adobe
%{__mkdir_p} -m 755 \
	$RPM_BUILD_ROOT%{_sysconfdir}/adobe
%{__mkdir_p} -m 755 $RPM_BUILD_ROOT%{_localstatedir}/log/%{name}
%{__mkdir_p} -m 755 \
	$RPM_BUILD_ROOT%{_sysconfdir}/ld.so.conf.d
##
# General install of binary data.
#

%{__cp} -ap etc opt $RPM_BUILD_ROOT/

# SYSV init stuff
%{__mkdir} -p $RPM_BUILD_ROOT%{_sysconfdir}/rc.d/init.d
%{__install} -m755 fms.init \
	$RPM_BUILD_ROOT%{_sysconfdir}/rc.d/init.d/fms
%{__install} -m644 %{S:2} $RPM_BUILD_ROOT%{_sysconfdir}/ld.so.conf.d/fms.conf

# symlinks for /var/log/fsm
rm -rf $RPM_BUILD_ROOT/opt/adobe/%{name}/logs
ln -s ../../..%{_localstatedir}/log/%{name} $RPM_BUILD_ROOT/opt/adobe/%{name}/logs
%{__mkdir} -p $RPM_BUILD_ROOT%{_localstatedir}/log/%{name}/_defaultVHost_
%{__mkdir} -p $RPM_BUILD_ROOT%{_localstatedir}/log/%{name}/_defaultVHost_/registry
%{__mkdir} -p $RPM_BUILD_ROOT%{_localstatedir}/log/%{name}/_defaultVHost_/registry/_definst_
# install log rotation stuff
#mkdir -p $RPM_BUILD_ROOT/etc/logrotate.d
#install -m644 %{SOURCE5} \
#	$RPM_BUILD_ROOT/etc/logrotate.d/fms
###################
# Remove log files
###################
/usr/bin/find $RPM_BUILD_ROOT/opt/adobe/%{name}/logs -type f -name "*.log" -exec %{__rm} -f {} \;
/usr/bin/find $RPM_BUILD_ROOT/opt/adobe/%{name}/logs -type f -name "*.rot" -exec %{__rm} -f {} \;
rm -rf $RPM_BUILD_ROOT/opt/adobe/%{name}/tmp/*
###################
# drop apache 
# internal not used anyway
###################
rm -rf $RPM_BUILD_ROOT/opt/adobe/%{name}/Apache2.2
#######################
# XXX undo prelinked binary
#######################

#prelink -u $RPM_BUILD_ROOT/opt/adobe/%{name}/libexpat.so.1
###################
# add new dir for checking SWF verification
# XXX drop buildpolicy build
%{__mkdir} -p $RPM_BUILD_ROOT/opt/adobe/%{name}/swf
exit 0

%pre 
#
# First Install
if [ $1 = 1 ] 
then
 if $(/usr/bin/getent passwd %{SSPP} >/dev/null 2>&1)
 then
	/usr/sbin/groupmod -g 10003 %{SSPP} 2> /dev/null || :
	/usr/sbin/usermod -g %{SSPP} -c "User for Flash Media Interactive Server"  \
		-s /sbin/nologin -u 10003 -d /opt/adobe/%{name} %{SSPP} 2>/dev/null || :
 else
# Add the "SSPP" user
/usr/sbin/groupadd -g 10003 %{SSPP} 2> /dev/null || :
/usr/sbin/useradd -c "User for User for Flash Media Interactive Server" \
	-s /sbin/nologin -g %{SSPP} -M -u 10003 -d /opt/adobe/%{name} %{SSPP} 2> /dev/null || :
 fi

fi


%post

/sbin/chkconfig --add %{name} || :
/sbin/ldconfig
exit 0

%preun
if [ $1 = 0 ]; then
	/sbin/service %{name} stop > /dev/null 2>&1 || :
	/sbin/chkconfig --del fms || :
		%{__rm} -rf /opt/adobe/%{name}/tmp/* >/dev/null 2>&1
fi
exit 0

%postun
if [ $1 -ge 1 ]; then
  /sbin/service %{name} condrestart >/dev/null 2>&1 || :
fi
if [ $1 = 0 ] ; then
	/sbin/ldconfig
fi
exit 0

%clean
rm -rf $RPM_BUILD_ROOT

%files 
%defattr(-,root,root,-)
%config %{_sysconfdir}/rc.d/init.d/%{name}
%doc %{SSPP}_uidgid
# drop this from manifest original as it is a symbolic link
# rember to clean also tmp
%{_localstatedir}/log/%{name}
########################
########### BEGIN FILE MANIFEST ##########################
%dir %attr(755,fms,fms) /opt/adobe/%{name}/swf
########### BEGIN FILE MANIFEST ##########################
%config(noreplace) %attr(644,root,root) /etc/adobe/fms/services/fmsadmin
%config(noreplace) %attr(644,root,root) /etc/adobe/fms/services/fms
%config(noreplace) %attr(644,root,root) /etc/ld.so.conf.d/fms.conf
%config(noreplace) %attr(644,fms,fms) /opt/adobe/fms/conf/fms.ini
%config(noreplace) %attr(644,fms,fms) /opt/adobe/fms/conf/Logger.xml
%config(noreplace) %attr(644,fms,fms) /opt/adobe/fms/conf/_defaultRoot_/Adaptor.xml
%config(noreplace) %attr(644,fms,fms) /opt/adobe/fms/conf/_defaultRoot_/_defaultVHost_/Application.xml
%config(noreplace) %attr(644,fms,fms) /opt/adobe/fms/conf/_defaultRoot_/_defaultVHost_/Vhost.xml
%config(noreplace) %attr(644,fms,fms) /opt/adobe/fms/conf/Users.xml
%config(noreplace) %attr(644,fms,fms) /opt/adobe/fms/conf/Server.xml
%config(noreplace) %attr(755,fms,fms) /opt/adobe/fms/applications/vod/Application.xml
%config(noreplace) %attr(755,fms,fms) /opt/adobe/fms/applications/live/Application.xml
%dir %attr(755,root,root) /etc/adobe
%dir %attr(755,root,root) /etc/adobe/fms
%dir %attr(755,root,root) /etc/adobe/fms/services
%attr(755,fms,fms) /opt/adobe/fms/adminserver
%attr(755,fms,fms) /opt/adobe/fms/shmrd
%attr(755,fms,fms) /opt/adobe/fms/modules/codecs/Screenshare.so
%attr(755,fms,fms) /opt/adobe/fms/modules/streams/libflv.so
%attr(755,fms,fms) /opt/adobe/fms/modules/streams/libmp3.so
%attr(755,fms,fms) /opt/adobe/fms/modules/streams/libid3.so
%attr(755,fms,fms) /opt/adobe/fms/modules/streams/liblog.so
%attr(755,fms,fms) /opt/adobe/fms/modules/streams/libmp4.so
%attr(755,fms,fms) /opt/adobe/fms/.services
%attr(755,fms,fms) /opt/adobe/fms/fmsmaster
%attr(755,fms,fms) /opt/adobe/fms/fmsedge
%attr(755,fms,fms) /opt/adobe/fms/scriptlib/components.asc
%attr(755,fms,fms) /opt/adobe/fms/scriptlib/RecordSet.as
%attr(755,fms,fms) /opt/adobe/fms/scriptlib/application.asc
%attr(755,fms,fms) /opt/adobe/fms/scriptlib/RsDataProviderClass.as
%attr(755,fms,fms) /opt/adobe/fms/scriptlib/NetServices.as
%attr(755,fms,fms) /opt/adobe/fms/scriptlib/facade.asc
%attr(755,fms,fms) /opt/adobe/fms/scriptlib/components/videoconference.asc
%attr(755,fms,fms) /opt/adobe/fms/scriptlib/components/roomlist.asc
%attr(755,fms,fms) /opt/adobe/fms/scriptlib/components/people.asc
%attr(755,fms,fms) /opt/adobe/fms/scriptlib/components/audioconference.asc
%attr(755,fms,fms) /opt/adobe/fms/scriptlib/components/connectionlight.asc
%attr(755,fms,fms) /opt/adobe/fms/scriptlib/components/setbandwidth.asc
%attr(755,fms,fms) /opt/adobe/fms/scriptlib/components/videoplayback.asc
%attr(755,fms,fms) /opt/adobe/fms/scriptlib/components/avpresence.asc
%attr(755,fms,fms) /opt/adobe/fms/scriptlib/components/presentationtext.asc
%attr(755,fms,fms) /opt/adobe/fms/scriptlib/components/whiteboard.asc
%attr(755,fms,fms) /opt/adobe/fms/scriptlib/components/cursor.asc
%attr(755,fms,fms) /opt/adobe/fms/scriptlib/components/chat.asc
%attr(755,fms,fms) /opt/adobe/fms/scriptlib/components/simpleconnect.asc
%attr(755,fms,fms) /opt/adobe/fms/scriptlib/components/component.asc
%attr(755,fms,fms) /opt/adobe/fms/scriptlib/components/version.asc
%attr(755,fms,fms) /opt/adobe/fms/scriptlib/components/usercolor.asc
%attr(755,fms,fms) /opt/adobe/fms/scriptlib/netservices.asc
%attr(755,fms,fms) /opt/adobe/fms/scriptlib/webservices/XMLSchemaConstants.asc
%attr(755,fms,fms) /opt/adobe/fms/scriptlib/webservices/WebServices.asc
%attr(755,fms,fms) /opt/adobe/fms/scriptlib/webservices/SOAP.asc
%attr(755,fms,fms) /opt/adobe/fms/scriptlib/webservices/Log.asc
%attr(755,fms,fms) /opt/adobe/fms/scriptlib/webservices/XMLSchema.asc
%attr(755,fms,fms) /opt/adobe/fms/scriptlib/webservices/Namespace.asc
%attr(755,fms,fms) /opt/adobe/fms/scriptlib/webservices/WebServicesClass.asc
%attr(755,fms,fms) /opt/adobe/fms/scriptlib/webservices/XMLSchemaDataTypes.asc
%attr(755,fms,fms) /opt/adobe/fms/scriptlib/webservices/WSDL.asc
%attr(755,fms,fms) /opt/adobe/fms/scriptlib/webservices/SOAPConstants.asc
%attr(755,fms,fms) /opt/adobe/fms/scriptlib/webservices/ServiceManager.asc
%attr(755,fms,fms) /opt/adobe/fms/scriptlib/webservices/XMLUtil.asc
%attr(755,fms,fms) /opt/adobe/fms/scriptlib/webservices/WSDLConstants.asc
%attr(755,fms,fms) /opt/adobe/fms/scriptlib/framework.asc
%attr(755,fms,fms) /opt/adobe/fms/uninstallFMS
%attr(644,fms,fms) /opt/adobe/fms/logo.gif
%attr(755,fms,fms) /opt/adobe/fms/tools/far
%attr(755,fms,fms) /opt/adobe/fms/tools/AC_RunActiveContent.js
%attr(755,fms,fms) /opt/adobe/fms/tools/fms_adminConsole.swf
%attr(755,fms,fms) /opt/adobe/fms/tools/fmscheck
%attr(755,fms,fms) /opt/adobe/fms/tools/fms_adminConsole.htm
%attr(755,fms,fms) /opt/adobe/fms/tools/flvcheck
%attr(644,fms,fms) /opt/adobe/fms/License.htm
%attr(644,root,root) /opt/adobe/fms/.autostart
%attr(755,fms,fms) /opt/adobe/fms/License.txt
%attr(755,fms,fms) /opt/adobe/fms/licenses/sif.bin
%attr(755,fms,fms) /opt/adobe/fms/licenses/sif35.bin
%attr(755,fms,fms) /opt/adobe/fms/server
%attr(755,fms,fms) /opt/adobe/fms/libasneu.so.1
%attr(644,fms,fms) /opt/adobe/fms/readme.htm
%attr(755,fms,fms) /opt/adobe/fms/fmscore
%attr(755,fms,fms) /opt/adobe/fms/tcSrvMsg
%attr(755,fms,fms) /opt/adobe/fms/webroot/vod/readme.htm
%attr(755,fms,fms) /opt/adobe/fms/webroot/index.html
%attr(755,fms,fms) /opt/adobe/fms/webroot/resources/AC_RunActiveContent_new.js
%attr(755,fms,fms) /opt/adobe/fms/webroot/resources/AC_RunActiveContent.js
%attr(755,fms,fms) /opt/adobe/fms/webroot/resources/AC_OETags.js
%attr(755,fms,fms) /opt/adobe/fms/webroot/readme.htm
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/screenshots_samples.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/section_border.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/flmis_boxshot.jpg
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/section_border_bottom.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/screenshots_21.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/dynamic_sectionbg_2b.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/gradient_top_bar.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/sidebar_10.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/icon_video_check.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/documentation_out.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/flmis_boxshot2.jpg
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/sidebar_04.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/screenshots_20.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/text_box_gradient.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/button_dynamic_up.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/button1.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/panel.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/gradient_bg2.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/screenshots_15.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/index_r2_c6.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/divider_bottom_07_07.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/sidebar_08.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/index_r2_c3.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/canvass.jpg
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/index_r9_c3.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/index_r3_c3.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/samples_thumb_highlight.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/ERROR_getFlashPlayer.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/SamplePicture.jpg
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/submit_in.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/sidebar_12.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/index_r2_c4.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/sidebar_05.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/home_out.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/title.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/divider_top.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/interactive__sectionbg.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/index_r7_c3.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/bg_testing.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/divider_side_07_05.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/video_left_03.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/box_shot.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/screenshots_25.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/adobe_logo.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/sidebar_15.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/sidebar_09.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/left_topnav_line.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/dynamic_sectionbg.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/button_interactive_up.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/screenshots_14.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/index_r2_border_c3.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/screenshots_22.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/interactive__sectionbg2.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/screenshots_08.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/index_r5_c3.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/interactive_texts_07.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/index_r6_c3.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/top_menu.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/top_menu_leftborder.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/flmrms_boxshot.jpg
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/index_r4_c3.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/index_r10_c3.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/top_bar_border.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/section_interactive.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/screenshots_dynamic.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/button_dynamic_down.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/sidebar_13.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/panel_large.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/button_interactive.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/screenshots_05.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/sidebar_01.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/flmle_boxshot.jpg
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/documentation_in.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/screenshots_04.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/section_samples.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/nasdaq.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/screenshots_11.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/box_shot_premiere.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/screenshots_12.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/button_samples_up.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/top_bar_border_bottom.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/sidebar_16.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/button_interactive_down_select.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/screenshots_07.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/text_bottomright_05.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/request_in.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/button_dynamic_down_select.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/index_r1_c2.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/top_bar_rightedge.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/sidebar_17.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/samples_thumb.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/sidebar_11.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/dynamic_sectionbg_1b.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/interactive_section.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/sidebar_06.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/screenshots_24.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/video_right_06.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/request_out.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/screenshots_03.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/icon_FL.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/pdf_icon.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/samples__sectionbg.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/section_border_upleft.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/section_border_upright.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/copyright_bar.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/screenshots_23.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/index_r5_c5.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/home_in.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/screenshots_dynamic.jpg
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/text_bottomleft_03.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/screenshots_19.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/release_out.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/spacer.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/side_canvass.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/submit_out.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/screenshots_06.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/index_r2_c2.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/screenshots_09.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/index_r1_c7.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/sidebar_02.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/button2.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/text_upperright_05.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/screenshots_01.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/cs4_boxshot.jpg
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/button_samples_down.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/screenshots_18.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/section_dynamic.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/screenshots_13.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/button_interactive_down.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/menu.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/index_r8_c3.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/flmss_boxshot.jpg
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/text_middleleft_07.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/icon_FL_check.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/divider_side_07.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/button_interactive2.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/sidebar_03.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/text_upperleft_03.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/spacer2.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/screenshots_17.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/button_samples_down_select.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/sidebar_07.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/screenshots_02.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/screenshots_10.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/screenshots_16.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/release_in.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/sidebar_14.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/top_bar_leftedge.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/text_middleright_08.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/Thumbs.db
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/button_video.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/screenshots_interactive.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/flmes_boxshot.jpg
%attr(755,fms,fms) /opt/adobe/fms/webroot/images/index_r1_c1.gif
%attr(755,fms,fms) /opt/adobe/fms/webroot/fms_adminConsole.htm
%attr(755,fms,fms) /opt/adobe/fms/webroot/live_recorded/readme.htm
%attr(755,fms,fms) /opt/adobe/fms/webroot/dynamicStream.smil
%attr(755,fms,fms) /opt/adobe/fms/webroot/swfs/LiveSample.swf
%attr(755,fms,fms) /opt/adobe/fms/webroot/swfs/videoPlayer.swf
%attr(755,fms,fms) /opt/adobe/fms/webroot/swfs/playerProductInstall.swf
%attr(755,fms,fms) /opt/adobe/fms/webroot/swfs/fms_adminConsole.swf
%attr(755,fms,fms) /opt/adobe/fms/fmsadmin
%attr(755,fms,fms) /opt/adobe/fms/fmsmgr
%attr(755,fms,fms) /opt/adobe/fms/applications/vod/allowedSWFdomains.txt
%attr(755,fms,fms) /opt/adobe/fms/applications/vod/allowedHTMLdomains.txt
%attr(755,fms,fms) /opt/adobe/fms/applications/vod/readme.txt
%attr(755,fms,fms) /opt/adobe/fms/applications/live/main.far
%attr(755,fms,fms) /opt/adobe/fms/applications/live/allowedSWFdomains.txt
%attr(755,fms,fms) /opt/adobe/fms/applications/live/allowedHTMLdomains.txt
%attr(755,fms,fms) /opt/adobe/fms/applications/live/readme.txt
%attr(755,fms,fms) /opt/adobe/fms/applications/vod/main.far
%attr(755,fms,fms) /opt/adobe/fms/modules/streams/libraw.so
%dir %attr(755,root,root) /opt/adobe
%dir %attr(755,fms,fms) /opt/adobe/fms
%dir %attr(755,fms,fms) /opt/adobe/fms/logs
%dir %attr(755,fms,fms) /opt/adobe/fms/modules
%dir %attr(755,fms,fms) /opt/adobe/fms/modules/codecs
%dir %attr(755,fms,fms) /opt/adobe/fms/modules/streams
%dir %attr(755,fms,fms) /opt/adobe/fms/scriptlib
%dir %attr(755,fms,fms) /opt/adobe/fms/scriptlib/components
%dir %attr(755,fms,fms) /opt/adobe/fms/scriptlib/webservices
%dir %attr(755,fms,fms) /opt/adobe/fms/tools
%dir %attr(755,fms,fms) /opt/adobe/fms/licenses
%dir %attr(755,fms,fms) /opt/adobe/fms/webroot
%dir %attr(755,fms,fms) /opt/adobe/fms/webroot/vod
%dir %attr(755,fms,fms) /opt/adobe/fms/webroot/resources
%dir %attr(755,fms,fms) /opt/adobe/fms/webroot/images
%dir %attr(755,fms,fms) /opt/adobe/fms/webroot/live_recorded
%dir %attr(755,fms,fms) /opt/adobe/fms/webroot/swfs
%dir %attr(751,fms,fms) /opt/adobe/fms/conf
%dir %attr(755,fms,fms) /opt/adobe/fms/conf/_defaultRoot_
%dir %attr(755,fms,fms) /opt/adobe/fms/conf/_defaultRoot_/_defaultVHost_
%dir %attr(755,fms,fms) /opt/adobe/fms/applications
%dir %attr(755,fms,fms) /opt/adobe/fms/applications/vod
%dir %attr(755,fms,fms) /opt/adobe/fms/applications/vod/media
%dir %attr(755,fms,fms) /opt/adobe/fms/applications/live
%changelog

* Mon Sep  6 2010 Elia Pinto <yersinia.spiros@gmail.com> - 3.5.4-1
- upgrade to new release ( http://www.adobe.com/support/documentation/en/flashmediaserver/354/FMS_3_5_4_Release_Notes.pdf )
* Mon Mar 22 2010 Elia Pinto <yersinia.spiros@gmail.com> - 3.5.3-3
- modified status function in fms-3.5.3-status.patch
* Fri Feb 19 2010 Elia Pinto <yersinia.spiros@gmail.com> - 3.5.3-2
- added fms.conf in /etc/ld.so.conf.d
* Fri Oct 23 2009 Elia Pinto <yersinia.spiros@gmail.com> - 3.5.1
- upgrade new release
* Fri Feb 16 2007 Elia Pinto <yersinia.spiros@gmail.com> - 3.0.2.217-1
- First Build
