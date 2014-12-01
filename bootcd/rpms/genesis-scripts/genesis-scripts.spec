Name:           genesis_scripts
Version:        0.2
Release:        2%{?dist}
License:        BSD
URL:            http://tumblr.github.io/genesis 
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
Source0:        root-bash_profile 
Source1:        sysconfig-ifcfg-eth0 
Source2:        sysconfig-ifcfg-eth1 
Source3:        sysconfig-ifcfg-eth2 
Source4:        sysconfig-ifcfg-eth3 
Source5:        sysconfig-init.diff 
Source6:        tty.conf.override
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
install -m 644 -T %{SOURCE1}   $RPM_BUILD_ROOT/etc/sysconfig/network-scripts/ifcfg-eth0
install -m 644 -T %{SOURCE2}   $RPM_BUILD_ROOT/etc/sysconfig/network-scripts/ifcfg-eth1
install -m 644 -T %{SOURCE3}   $RPM_BUILD_ROOT/etc/sysconfig/network-scripts/ifcfg-eth2
install -m 644 -T %{SOURCE4}   $RPM_BUILD_ROOT/etc/sysconfig/network-scripts/ifcfg-eth3
install -m 644 -T %{SOURCE5}   $RPM_BUILD_ROOT/etc/sysconfig/init.diff
install -m 644 -T %{SOURCE6}   $RPM_BUILD_ROOT/etc/init/tty.conf.override

%clean
# noop 

%files
%defattr(-, root, root)
%config /etc/sysconfig/network-scripts/ifcfg-eth0 
%config /etc/sysconfig/network-scripts/ifcfg-eth1 
%config /etc/sysconfig/network-scripts/ifcfg-eth2
%config /etc/sysconfig/network-scripts/ifcfg-eth3 
%config /etc/sysconfig/init.diff 
%config /etc/init/tty.conf.override
%config /root/.bash_profile.genesis_scripts

%post 
cat /root/.bash_profile.genesis_scripts >> /root/.bash_profile
cp  /etc/init/tty.conf.override /etc/init/tty.conf
/usr/bin/patch /etc/sysconfig/init < /etc/sysconfig/init.diff

%changelog
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


