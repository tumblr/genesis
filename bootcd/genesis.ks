lang en_US.UTF-8
keyboard us
timezone America/New_York
auth --useshadow --enablemd5
selinux --disabled
firewall --disabled
rootpw --iscrypted $1$zva3nR9O$xdHSmelk7Nl2AFY7Luwmz0
services --enabled sshd
# latest stable SL-6 
url                   --url=http://ftp.scientificlinux.org/linux/scientific/6x/x86_64/os/
repo --name=base      --baseurl=http://ftp.scientificlinux.org/linux/scientific/6x/x86_64/os/
repo --name=epel      --baseurl=http://mirrors.rit.edu/epel/6/x86_64/
repo --name=fastbugs  --baseurl=http://ftp.scientificlinux.org/linux/scientific/6x/x86_64/updates/fastbugs/
repo --name=security  --baseurl=http://ftp.scientificlinux.org/linux/scientific/6x/x86_64/updates/security/
repo --name=local     --baseurl=http://localhost:8000/repo/

%packages
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
traceroute
util-linux-ng
vim-minimal
yum

# packages below here will be removed as part of %post to keep the image smaller
# unless they are needed for genesis code

# for building ruby
#byacc
#db4-devel
#gcc
#gdbm
#gdbm-devel
#glibc-devel
#libffi-devel
#libyaml
#libyaml-devel
#make
#ncurses-devel
#openssl-devel
#readline
#readline-devel
#tcl-devel
#unzip

genesis_scripts

# we want to target a more modern ruby environment
# which we used to build in %post
ruby
#rubygems only for old ruby versions
libyaml
#rubygem-curb
#rubygem-genesis_bootloader
#rubygem-genesis_promptcli
#rubygem-genesis_retryingfetcher 
#rubygem-ruby-termios
#rubygem-nokogiri
#rubygem-mini_portile


# for gem install
gcc
#glibc-devel
glibc-headers
#kernel-headers
#curl
#libcurl
#libcurl-devel
#autoconf
#automake
#libidn-devel
#libxml2 
#libxml2-devel
#libxslt
#libxslt-devel
%end

%post
repo_base_url="http://ftp.scientificlinux.org/linux/scientific/6x/x86_64"
# Apply Genesis Live OS customizations
echo '*****************************************'
echo '*** Genesis Live OS Image Customizr ***'


echo '>>>> updating fstab'
cat >> /etc/fstab <<EOL
tmpfs			/tmp		tmpfs	mode=1777	0 0
tmpfs			/var/tmp	tmpfs	mode=1777	0 0
tmpfs			/var/cache/yum	tmpfs	mode=1777	0 0
EOL


echo '>>>> setting hostname'
sed -i -e 's/HOSTNAME=.*/HOSTNAME=genesis/' /etc/sysconfig/network


echo '>>>> rewriting /etc/motd'
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


echo '>>>> rewriting /etc/issue'
cat <<EOF > /etc/issue
Genesis OS v0.1
Kernel \r
BuildDate: $(date)

EOF

echo '>>>> configuring rsyslog'
cat >> /etc/rsyslog.conf <<EOL

# genesis 
local0.*                                                /var/log/genesis.log
local0.*                                                /dev/tty7
EOL

##echo '>>>> disabling selinux'
#http://serverfault.com/questions/340679/centos-6-kickstart-ignoring-selinux-disabled
##ls -ld /etc/selinux/config /etc/sysconfig/selinux
##sed -i -e 's/^SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config
# for some reason, /etc/sysconfig/selinux isnt a symlink to /etc/selinux/config
##rm -f /etc/sysconfig/selinux
##ln -s ../selinux/config /etc/sysconfig/selinux


# ruby now installed above
# build latest stable ruby
#mkdir /tmp/ruby
#cd /tmp/ruby
#curl -k https://ftp.ruby-lang.org/pub/ruby/stable-snapshot.tar.gz | tar -xzf -
#cd stable-snapshot
#./configure
#make
#make install

echo '>>>> creating /etc/gemrc'
cat >> /etc/gemrc <<EOF
install: --no-ri --no-rdoc
update: --no-ri --no-rdoc
EOF
#gem:  --no-document

echo '>>>> installing bundler gem'
su - -c 'gem install bundler'

echo '>>>> downloading genesis_{promptcli,retryingfetcher}.gem'
mkdir -p /root/repo/gems
curl 'http://localhost:8888/gem/genesis_promptcli' > /root/repo/gems/genesis_promptcli.gem
curl 'http://localhost:8888/gem/genesis_retryingfetcher' > /root/repo/gems/genesis_retryingfetcher.gem
## TODO support local gems for the Gemfile
##echo '>>>> makeing a local gem repo of those gems'
##su - -c 'gem install builder'
##su - -c 'cd /root/repo; gem generate_index'
ls -l -r /root/repo

echo '>>>> creating /root/Gemfile'
# gem versions match Gemfiles in src/<GEM>/Gemfile
cat > /root/Gemfile  <<EOF
source 'https://rubygems.org'

gem 'ruby-termios', '~> 0.9.4'
##gem 'genesis_promptcli', :source => 'file:///root/repo'
gem 'httparty'
##gem 'genesis_retryingfetcher', :source => 'file:///root/repo'
gem 'json'
EOF
#gem 'genesis_scripts'
#gem 'genesis_bootloader'
#gem 'mini_portile'
#gem 'nokogiri'

echo '>>>> loading gems'
su - -c 'bundle install --system --gemfile /root/Gemfile'

# TODO get these into the Gemfile
echo '>>>> loading basic genesis framework gems'
su - -c 'gem install /root/repo/gems/genesis_promptcli.gem'
su - -c 'gem install /root/repo/gems/genesis_retryingfetcher.gem'

echo '>>>> cleanup now unneeds gem repo to make image smaller'
rm -rf /root/repo
bundle clean

#echo '>>>> cleanup now unneeds RPMs to make image smaller'
# yum erase -y readline libyaml  ncurses gdbm make
# yum erase -y libcurl-devel autoconf automake libidn-devel
# yum erase -y glibc-devel glibc-headers kernel-headers gcc cloog-ppl cpp libgomp mpfr ppl
#yum erase -y readline libyaml libyaml-devel readline-devel ncurses ncurses-devel gdbm gdbm-devel glibc-devel tcl-devel gcc unzip openssl-devel db4-devel byacc make libffi-devel
yum clean all

# delete stuff we don't need
echo ">>>>> Removing bloat from /usr/share"
rm -rf /usr/share/doc
rm -rf /usr/share/icons

echo '>>>>> all done with %post'
echo '*****************************************'
%end
