Name:           genesis_scripts
Version:        0.6
Release:        4%{?dist}
License:        Apache License, 2.0
URL:            http://tumblr.github.io/genesis
BuildArch:      noarch
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root
Source0:        src/root-bash_profile 
Source1:        src/init.d-network-prep
Source2:        src/sysconfig-init.diff 
Source3:        src/tty.conf.override
Source4:        src/genesis-bootloader
Source5:        src/login-shell
Summary:        Scripts used by Genesis in the bootcd image
Group:          System Environment/Base  
Requires:       initscripts rootfiles patch

%description
Scripts and configuration files used by Genesis in the bootcd image

%prep
# noop  

%build
# noop 

%install
# add root's bash_profile
mkdir -p $RPM_BUILD_ROOT/root
install -m 644 -T %{SOURCE0}   $RPM_BUILD_ROOT/root/.bash_profile.genesis_scripts

# add some overrides we need
mkdir -p $RPM_BUILD_ROOT/etc/sysconfig/network-scripts 
mkdir -p $RPM_BUILD_ROOT/etc/init
mkdir -p $RPM_BUILD_ROOT/etc/init.d
install -m 755 -T %{SOURCE1}   $RPM_BUILD_ROOT/etc/init.d/network-prep
install -m 644 -T %{SOURCE2}   $RPM_BUILD_ROOT/etc/sysconfig/init.diff
install -m 644 -T %{SOURCE3}   $RPM_BUILD_ROOT/etc/init/tty.conf.override

# add helper for agetty
install -m 555 -T %{SOURCE5}   $RPM_BUILD_ROOT/root/login-shell

# add the bootloader
mkdir -p $RPM_BUILD_ROOT/usr/bin/
install -m 555 -T %{SOURCE4}   $RPM_BUILD_ROOT/usr/bin/genesis-bootloader

%clean
# noop 

%files
%defattr(-, root, root)
%config /etc/init.d/network-prep
%config /etc/sysconfig/init.diff 
%config /etc/init/tty.conf.override
%config /root/.bash_profile.genesis_scripts
/usr/bin/genesis-bootloader
/root/login-shell

%post 
cat /root/.bash_profile.genesis_scripts >> /root/.bash_profile
# TODO undo this hack
cp  /etc/init/tty.conf.override /etc/init/tty.conf
/usr/bin/patch /etc/sysconfig/init < /etc/sysconfig/init.diff
chkconfig --add network-prep

%changelog
* Fri Jan 09 2015 Roy Marantz <marantz@tumblr.com> 0.5-1
- redo networking setup

* Tue Dec 16 2014 Roy Marantz <marantz@tumblr.com> 0.3-1
- add genesis-bootloader

* Mon Jul 07 2014 Jeremy Johnstone <jeremy@tumblr.com> 0.2-2
- bringing up all 4 possible nics on the host machine when doing genesis boot

* Mon Jul 07 2014 Jeremy Johnstone <jeremy@tumblr.com> 0.2-1
- Bringing up all 4 possible nics on the host machine via dhcp

* Tue May 06 2014 Jeremy Johnstone <jeremy@tumblr.com> 0.1-7
- fixing patch in %%post block (jeremy@tumblr.com)

* Tue May 06 2014 Jeremy Johnstone <jeremy@tumblr.com> 0.1-6
- fixing package to get it to install properly (jeremy@tumblr.com)

* Tue May 06 2014 Jeremy Johnstone <jeremy@tumblr.com> 0.1-5
- cleaned up spec file for proper building
* Tue May 06 2014 Jeremy Johnstone <jeremy@tumblr.com> 0.1-4
- updating spec for proper building (jeremy@tumblr.com)

* Tue May 06 2014 Jeremy Johnstone <jeremy@tumblr.com> 0.1-3
- removing stale bootloader from sources (jeremy@tumblr.com)

* Tue May 06 2014 Jeremy Johnstone <jeremy@tumblr.com> 0.1-2
- new package built with tito


