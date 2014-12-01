lang en_US.UTF-8
keyboard us
timezone America/New_York
auth --useshadow --enablemd5
selinux --disabled
firewall --disabled
rootpw --iscrypted $1$zva3nR9O$xdHSmelk7Nl2AFY7Luwmz0
services --enabled sshd
url                   --url=http://ftp.scientificlinux.org/linux/scientific/6.4/x86_64/os/
repo --name=base      --baseurl=http://ftp.scientificlinux.org/linux/scientific/6.4/x86_64/os/
repo --name=epel      --baseurl=http://mirrors.rit.edu/epel/6/x86_64/
repo --name=fastbugs  --baseurl=http://ftp.scientificlinux.org/linux/scientific/6.4/x86_64/updates/fastbugs/
repo --name=security  --baseurl=http://ftp.scientificlinux.org/linux/scientific/6.4/x86_64/updates/security/
repo --name=local     --baseurl=http://localhost/repo/

%packages
# we want to target a more modern ruby environment
ruby
#genesis_scripts 
#rubygem-curb
#rubygem-genesis_bootloader
#rubygem-genesis_promptcli
#rubygem-genesis_retryingfetcher 
#rubygem-ruby-termios
#rubygem-nokogiri
#rubygem-mini_portile

# curl-devel is required for genesis_retryingfetcher
curl
libcurl
libcurl-devel
libxml2 
libxml2-devel
libxslt
libxslt-devel

acl
attr
authconfig
basesystem
bash
chkconfig
coreutils
cpio
device-mapper
device-mapper-event
dhclient
e2fsprogs
filesystem
glibc
initscripts
iproute
iptables-ipv6
iptables
iputils
kernel
ncurses
openssh-server
openssh-clients
passwd
policycoreutils
procps
rootfiles
rpm
rsyslog
screen
setup
shadow-utils
sudo
system-config-firewall-base 
tmux
util-linux-ng
vim-minimal
yum

# for building ruby
readline
libyaml
libyaml-devel
readline-devel
ncurses
ncurses-devel
gdbm
gdbm-devel
glibc-devel
tcl-devel
gcc
unzip
openssl-devel
db4-devel
byacc
make
libffi-devel
%end

%post
repo_base_url="http://ftp.scientificlinux.org/linux/scientific/6.4/x86_64"
# Apply Genesis Live OS customizations
echo '*****************************************'
echo '*** Genesis Live OS Image Customizr ***'


echo '---> updating fstab'
cat >> /etc/fstab <<EOL
tmpfs			/tmp		tmpfs	mode=1777	0 0
tmpfs			/var/tmp	tmpfs	mode=1777	0 0
EOL


echo '---> setting hostname'
sed -i -e 's/HOSTNAME=.*/HOSTNAME=genesis/' /etc/sysconfig/network


echo '---> rewriting /etc/motd'
cat > /etc/motd <<"__EOF__"

                    o             ___         ( ( (        _     _         !!!      
     '*`         ` /_\ '         /_\ `*     '. ___ .'    o' \,=./ `o    `  _ _  '   
    (o o)       - (o o) -       (o o)      '  (> <) '       (o o)      -  (OXO)  -  
ooO--(_)--Ooo-ooO--(_)--Ooo-ooO--(_)--Ooo-ooO--(_)--Ooo-ooO--(_)--Ooo-ooO--(_)--Ooo-

      ,----..                                                                    
     /   /   \                                               ,--,                
    |   :     :                ,---,                       ,--.'|                
    .   |  ;. /            ,-+-. /  |            .--.--.   |  |,      .--.--.    
    .   ; /--`     ,---.  ,--.'|'   |   ,---.   /  /    '  `--'_     /  /    '   
    ;   | ;  __   /     \|   |  ,"' |  /     \ |  :  /`./  ,' ,'|   |  :  /`./   
    |   : |.' .' /    /  |   | /  | | /    /  ||  :  ;_    '  | |   |  :  ;_     
    .   | '_.' :.    ' / |   | |  | |.    ' / | \  \    `. |  | :    \  \    `.  
    '   ; : \  |'   ;   /|   | |  |/ '   ;   /|  `----.   \'  : |__   `----.   \ 
    '   | '/  .''   |  / |   | |--'  '   |  / | /  /`--'  /|  | '.'| /  /`--'  / 
    |   :    /  |   :    |   |/      |   :    |'--'.     / ;  :    ;'--'.     /  
     \   \ .'    \   \  /'---'        \   \  /   `--'---'  |  ,   /   `--'---'   
      `---`       `----'               `----'               ---`-'               

__EOF__


echo '---> rewriting /etc/issue'
cat > /etc/issue <<EOF
Genesis OS v0.1
Kernel \r

EOF

echo '---> configuring rsyslog'
cat >> /etc/rsyslog.conf <<EOL

# genesis 
local0.*                                                /var/log/genesis.log
local0.*                                                /dev/tty7
EOL

echo '---> disabling selinux'
#http://serverfault.com/questions/340679/centos-6-kickstart-ignoring-selinux-disabled
# for some reason, /etc/sysconfig/selinux isnt a symlink to /etc/selinux/config
rm -f /etc/sysconfig/selinux
ln -sf /etc/selinux/config /etc/sysconfig/selinux
sed -i -e "s/^SELINUX=.*/SELINUX=disabled/g" /etc/selinux/config

# build latest stable ruby
mkdir /tmp/ruby
cd /tmp/ruby
curl -k https://ftp.ruby-lang.org/pub/ruby/stable-snapshot.tar.gz | tar -xzf -
cd stable-snapshot
./configure
make
make install

# genesis booloader support
cat >> /etc/gemrc <<EOF
install: --no-ri --no-rdoc
update: --no-ri --no-rdoc
EOF

gem install bundler

cat > /root/Gemfile  <<EOF
--no-rdoc  --no-ri
source 'http://rubygems.ewr01.tumblr.net:8808'
source 'https://rubygems.org'
gem 'ruby-termios'
gem 'genesis_promptcli'
gem 'curb'
gem 'genesis_retryingfetcher'
gem 'genesis_bootloader'
gem 'genesis_scripts'
gem 'json'
EOF
#gem 'mini_portile'
#gem 'nokogiri'

bundle install --system --gemfile /root/Gemfile

# cleanup now unneeds RPMs to make image smaller
yum erase -y readline libyaml libyaml-devel readline-devel ncurses ncurses-devel gdbm gdbm-devel glibc-devel tcl-devel gcc unzip openssl-devel db4-devel byacc make libffi-devel

# delete stuff we don't need
echo "---> Removing bloat from /usr/share"
rm -rf /usr/share/doc
rm -rf /usr/share/icons

echo '---> all done'
echo '*****************************************'
%end
