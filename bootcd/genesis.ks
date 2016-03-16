bootloader --location=mbr --append="toram"
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
-iptables-ipv6
-iptables
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
# needed for rvm
which

genesis_scripts

# for gem install
gcc
glibc-headers

%end

%post
set -e
repo_base_url="http://ftp.scientificlinux.org/linux/scientific/6x/x86_64"
# Apply Genesis Live OS customizations
echo '*****************************************'
echo '*** Genesis Live OS Image Customizr ***'

# See: http://www.espenbraastad.no/post/el6-rootfs-on-tmpfs/?p=160
# This is to swap our rootfs from an overlay to tmpfs so we dont blow
# out the 512m overlay FS when downloading gems and such on a running image
echo '>>>> updating dracut-live-root to support tmpfs'
# FYI this is just base64 of the already-patched dracut-live-root file
cat >/root/dracut-live-root-tmpfs.base64 <<"_EOF_"
IyEvYmluL3NoCiAKLiAvbGliL2RyYWN1dC1saWIuc2gKWyAtZiAvdG1wL3Jvb3QuaW5mbyBdICYmIC4gL3RtcC9yb290LmluZm8KIApQQVRIPSRQQVRIOi9zYmluOi91c3Ivc2JpbgogCmlmIGdldGFyZyByZGxpdmVkZWJ1ZzsgdGhlbgogICAgZXhlYyA+IC90bXAvbGl2ZXJvb3QuJCQub3V0CiAgICBleGVjIDI+PiAvdG1wL2xpdmVyb290LiQkLm91dAogICAgc2V0IC14CmZpCiAKWyAteiAiJDEiIF0gJiYgZXhpdCAxCmxpdmVkZXY9IiQxIgogCiMgcGFyc2UgdmFyaW91cyBsaXZlIGltYWdlIHNwZWNpZmljIG9wdGlvbnMgdGhhdCBtYWtlIHNlbnNlIHRvIGJlCiMgc3BlY2lmaWVkIGFzIHRoZWlyIG93biB0aGluZ3MKbGl2ZV9kaXI9JChnZXRhcmcgbGl2ZV9kaXIpClsgLXogIiRsaXZlX2RpciIgXSAmJiBsaXZlX2Rpcj0iTGl2ZU9TIgpnZXRhcmcgbGl2ZV9yYW0gJiYgbGl2ZV9yYW09InllcyIKZ2V0YXJnIG5vX2VqZWN0ICYmIG5vX2VqZWN0PSJ5ZXMiCmdldGFyZyByZXNldF9vdmVybGF5ICYmIHJlc2V0X292ZXJsYXk9InllcyIKZ2V0YXJnIHJlYWRvbmx5X292ZXJsYXkgJiYgcmVhZG9ubHlfb3ZlcmxheT0iLS1yZWFkb25seSIgfHwgcmVhZG9ubHlfb3ZlcmxheT0iIgpvdmVybGF5PSQoZ2V0YXJnIG92ZXJsYXkpCiAKZ2V0YXJnIHRvcmFtICYmIHRvcmFtPSJ5ZXMiCiAKIyBGSVhNRTogd2UgbmVlZCB0byBiZSBhYmxlIHRvIGhpZGUgdGhlIHBseW1vdXRoIHNwbGFzaCBmb3IgdGhlIGNoZWNrIHJlYWxseQpbIC1lICRsaXZlZGV2IF0gJiBmcz0kKGJsa2lkIC1zIFRZUEUgLW8gdmFsdWUgJGxpdmVkZXYpCmlmIFsgIiRmcyIgPSAiaXNvOTY2MCIgLW8gIiRmcyIgPSAidWRmIiBdOyB0aGVuCiAgICBjaGVjaz0ieWVzIgpmaQpnZXRhcmcgY2hlY2sgfHwgY2hlY2s9IiIKaWYgWyAtbiAiJGNoZWNrIiBdOyB0aGVuCiAgICBjaGVja2lzb21kNSAtLXZlcmJvc2UgJGxpdmVkZXYgfHwgOgogICAgaWYgWyAkPyAtbmUgMCBdOyB0aGVuCiAgZGllICJDRCBjaGVjayBmYWlsZWQhIgogIGV4aXQgMQogICAgZmkKZmkKIApnZXRhcmcgcm8gJiYgbGl2ZXJ3PXJvCmdldGFyZyBydyAmJiBsaXZlcnc9cncKWyAteiAiJGxpdmVydyIgXSAmJiBsaXZlcnc9cm8KIyBtb3VudCB0aGUgYmFja2luZyBvZiB0aGUgbGl2ZSBpbWFnZSBmaXJzdApta2RpciAtcCAvZGV2Ly5pbml0cmFtZnMvbGl2ZQptb3VudCAtbiAtdCAkZnN0eXBlIC1vICRsaXZlcncgJGxpdmVkZXYgL2Rldi8uaW5pdHJhbWZzL2xpdmUKUkVTPSQ/CmlmIFsgIiRSRVMiICE9ICIwIiBdOyB0aGVuCiAgICBkaWUgIkZhaWxlZCB0byBtb3VudCBibG9jayBkZXZpY2Ugb2YgbGl2ZSBpbWFnZSIKICAgIGV4aXQgMQpmaQogCiMgb3ZlcmxheSBzZXR1cCBoZWxwZXIgZnVuY3Rpb24KZG9fbGl2ZV9vdmVybGF5KCkgewogICAgIyBjcmVhdGUgYSBzcGFyc2UgZmlsZSBmb3IgdGhlIG92ZXJsYXkKICAgICMgb3ZlcmxheTogaWYgbm9uLXJhbSBvdmVybGF5IHNlYXJjaGluZyBpcyBkZXNpcmVkLCBkbyBpdCwKICAgICMgICAgICAgICAgICAgIG90aGVyd2lzZSwgY3JlYXRlIHRyYWRpdGlvbmFsIG92ZXJsYXkgaW4gcmFtCiAgICBPVkVSTEFZX0xPT1BERVY9JCggbG9zZXR1cCAtZiApCiAKICAgIGw9JChibGtpZCAtcyBMQUJFTCAtbyB2YWx1ZSAkbGl2ZWRldikgfHwgbD0iIgogICAgdT0kKGJsa2lkIC1zIFVVSUQgLW8gdmFsdWUgJGxpdmVkZXYpIHx8IHU9IiIKIAogICAgaWYgWyAteiAiJG92ZXJsYXkiIF07IHRoZW4KICAgICAgICBwYXRoc3BlYz0iLyR7bGl2ZV9kaXJ9L292ZXJsYXktJGwtJHUiCiAgICBlbGlmICggZWNobyAkb3ZlcmxheSB8IGdyZXAgLXEgIjoiICk7IHRoZW4KICAgICAgICAjIHBhdGhzcGVjIHNwZWNpZmllZCwgZXh0cmFjdAogICAgICAgIHBhdGhzcGVjPSQoIGVjaG8gJG92ZXJsYXkgfCBzZWQgLWUgJ3MvXi4qOi8vJyApCiAgICBmaQogCiAgICBpZiBbIC16ICIkcGF0aHNwZWMiIC1vICIkcGF0aHNwZWMiID0gImF1dG8iIF07IHRoZW4KICAgICAgICBwYXRoc3BlYz0iLyR7bGl2ZV9kaXJ9L292ZXJsYXktJGwtJHUiCiAgICBmaQogICAgZGV2c3BlYz0kKCBlY2hvICRvdmVybGF5IHwgc2VkIC1lICdzLzouKiQvLycgKQogCiAgICAjIG5lZWQgdG8ga25vdyB3aGVyZSB0byBsb29rIGZvciB0aGUgb3ZlcmxheQogICAgc2V0dXA9IiIKICAgIGlmIFsgLW4gIiRkZXZzcGVjIiAtYSAtbiAiJHBhdGhzcGVjIiAtYSAtbiAiJG92ZXJsYXkiIF07IHRoZW4KICAgICAgICBta2RpciAvb3ZlcmxheWZzCiAgICAgICAgbW91bnQgLW4gLXQgYXV0byAkZGV2c3BlYyAvb3ZlcmxheWZzIHx8IDoKICAgICAgICBpZiBbIC1mIC9vdmVybGF5ZnMkcGF0aHNwZWMgLWEgLXcgL292ZXJsYXlmcyRwYXRoc3BlYyBdOyB0aGVuCiAgICAgICAgICAgIGxvc2V0dXAgJE9WRVJMQVlfTE9PUERFViAvb3ZlcmxheWZzJHBhdGhzcGVjCiAgICAgICAgICAgIGlmIFsgLW4gIiRyZXNldF9vdmVybGF5IiBdOyB0aGVuCiAgICAgICAgICAgICAgIGRkIGlmPS9kZXYvemVybyBvZj0kT1ZFUkxBWV9MT09QREVWIGJzPTY0ayBjb3VudD0xIDI+L2Rldi9udWxsCiAgICAgICAgICAgIGZpCiAgICAgICAgICAgIHNldHVwPSJ5ZXMiCiAgICAgICAgZmkKICAgICAgICB1bW91bnQgLWwgL292ZXJsYXlmcyB8fCA6CiAgICBmaQogCiAgICBpZiBbIC16ICIkc2V0dXAiIF07IHRoZW4KICAgICAgICBpZiBbIC1uICIkZGV2c3BlYyIgLWEgLW4gIiRwYXRoc3BlYyIgXTsgdGhlbgogICAgICAgICAgIHdhcm4gIlVuYWJsZSB0byBmaW5kIHBlcnNpc3RlbnQgb3ZlcmxheTsgdXNpbmcgdGVtcG9yYXJ5IgogICAgICAgICAgIHNsZWVwIDUKICAgICAgICBmaQogCiAgICAgICAgZGQgaWY9L2Rldi9udWxsIG9mPS9vdmVybGF5IGJzPTEwMjQgY291bnQ9MSBzZWVrPSQoKDUxMioxMDI0KSkgMj4gL2Rldi9udWxsCiAgICAgICAgbG9zZXR1cCAkT1ZFUkxBWV9MT09QREVWIC9vdmVybGF5CiAgICBmaQogCiAgICAjIHNldCB1cCB0aGUgc25hcHNob3QKICAgIGVjaG8gMCBgYmxvY2tkZXYgLS1nZXRzeiAkQkFTRV9MT09QREVWYCBzbmFwc2hvdCAkQkFTRV9MT09QREVWICRPVkVSTEFZX0xPT1BERVYgcCA4IHwgZG1zZXR1cCBjcmVhdGUgJHJlYWRvbmx5X292ZXJsYXkgbGl2ZS1ydwp9CiAKIyBsaXZlIGNkIGhlbHBlciBmdW5jdGlvbgpkb19saXZlX2Zyb21fYmFzZV9sb29wKCkgewogICAgZG9fbGl2ZV9vdmVybGF5Cn0KIAojIHdlIG1pZ2h0IGhhdmUgYSBnZW5NaW5JbnN0RGVsdGEgZGVsdGEgZmlsZSBmb3IgYW5hY29uZGEgdG8gdGFrZSBhZHZhbnRhZ2Ugb2YKaWYgWyAtZSAvZGV2Ly5pbml0cmFtZnMvbGl2ZS8ke2xpdmVfZGlyfS9vc21pbi5pbWcgXTsgdGhlbgogICAgT1NNSU5TUUZTPS9kZXYvLmluaXRyYW1mcy9saXZlLyR7bGl2ZV9kaXJ9L29zbWluLmltZwpmaQogCmlmIFsgLW4gIiRPU01JTlNRRlMiIF07IHRoZW4KICAgICMgZGVjb21wcmVzcyB0aGUgZGVsdGEgZGF0YQogICAgZGQgaWY9JE9TTUlOU1FGUyBvZj0vb3NtaW4uaW1nIDI+IC9kZXYvbnVsbAogICAgT1NNSU5fU1FVQVNIRURfTE9PUERFVj0kKCBsb3NldHVwIC1mICkKICAgIGxvc2V0dXAgLXIgJE9TTUlOX1NRVUFTSEVEX0xPT1BERVYgL29zbWluLmltZwogICAgbWtkaXIgLXAgL3NxdWFzaGZzLm9zbWluCiAgICBtb3VudCAtbiAtdCBzcXVhc2hmcyAtbyBybyAkT1NNSU5fU1FVQVNIRURfTE9PUERFViAvc3F1YXNoZnMub3NtaW4KICAgIE9TTUlOX0xPT1BERVY9JCggbG9zZXR1cCAtZiApCiAgICBsb3NldHVwIC1yICRPU01JTl9MT09QREVWIC9zcXVhc2hmcy5vc21pbi9vc21pbgogICAgdW1vdW50IC1sIC9zcXVhc2hmcy5vc21pbgpmaQogCiMgd2UgbWlnaHQgaGF2ZSBqdXN0IGFuIGVtYmVkZGVkIGV4dDMgdG8gdXNlIGFzIHJvb3RmcyAodW5jb21wcmVzc2VkIGxpdmUpCmlmIFsgLWUgL2Rldi8uaW5pdHJhbWZzL2xpdmUvJHtsaXZlX2Rpcn0vZXh0M2ZzLmltZyBdOyB0aGVuCiAgRVhUM0ZTPSIvZGV2Ly5pbml0cmFtZnMvbGl2ZS8ke2xpdmVfZGlyfS9leHQzZnMuaW1nIgpmaQogCmlmIFsgLW4gIiRFWFQzRlMiIF0gOyB0aGVuCiAgICBCQVNFX0xPT1BERVY9JCggbG9zZXR1cCAtZiApCiAgICBsb3NldHVwIC1yICRCQVNFX0xPT1BERVYgJEVYVDNGUwogCiAgICAjIENyZWF0ZSBvdmVybGF5IG9ubHkgaWYgdG9yYW0gaXMgbm90IHNldAogICAgaWYgWyAteiAiJHRvcmFtIiBdIDsgdGhlbgogICAgICAgIGRvX2xpdmVfZnJvbV9iYXNlX2xvb3AKICAgIGZpCmZpCiAKIyB3ZSBtaWdodCBoYXZlIGFuIGVtYmVkZGVkIGV4dDMgb24gc3F1YXNoZnMgdG8gdXNlIGFzIHJvb3RmcyAoY29tcHJlc3NlZCBsaXZlKQppZiBbIC1lIC9kZXYvLmluaXRyYW1mcy9saXZlLyR7bGl2ZV9kaXJ9L3NxdWFzaGZzLmltZyBdOyB0aGVuCiAgU1FVQVNIRUQ9Ii9kZXYvLmluaXRyYW1mcy9saXZlLyR7bGl2ZV9kaXJ9L3NxdWFzaGZzLmltZyIKZmkKIAppZiBbIC1lICIkU1FVQVNIRUQiIF0gOyB0aGVuCiAgICBpZiBbIC1uICIkbGl2ZV9yYW0iIF0gOyB0aGVuCiAgICAgICAgZWNobyAiQ29weWluZyBsaXZlIGltYWdlIHRvIFJBTS4uLiIKICAgICAgICBlY2hvICIodGhpcyBtYXkgdGFrZSBhIGZldyBtaW51dGVzKSIKICAgICAgICBkZCBpZj0kU1FVQVNIRUQgb2Y9L3NxdWFzaGVkLmltZyBicz01MTIgMj4gL2Rldi9udWxsCiAgICAgICAgdW1vdW50IC1uIC9kZXYvLmluaXRyYW1mcy9saXZlCiAgICAgICAgZWNobyAiRG9uZSBjb3B5aW5nIGxpdmUgaW1hZ2UgdG8gUkFNLiIKICAgICAgICBpZiBbICEgLW4gIiRub19lamVjdCIgXTsgdGhlbgogICAgICAgICAgICBlamVjdCAtcCAkbGl2ZWRldiB8fCA6CiAgICAgICAgZmkKICAgICAgICBTUVVBU0hFRD0iL3NxdWFzaGVkLmltZyIKICAgIGZpCiAKICAgIFNRVUFTSEVEX0xPT1BERVY9JCggbG9zZXR1cCAtZiApCiAgICBsb3NldHVwIC1yICRTUVVBU0hFRF9MT09QREVWICRTUVVBU0hFRAogICAgbWtkaXIgLXAgL3NxdWFzaGZzCiAgICBtb3VudCAtbiAtdCBzcXVhc2hmcyAtbyBybyAkU1FVQVNIRURfTE9PUERFViAvc3F1YXNoZnMKIAogICAgQkFTRV9MT09QREVWPSQoIGxvc2V0dXAgLWYgKQogICAgbG9zZXR1cCAtciAkQkFTRV9MT09QREVWIC9zcXVhc2hmcy9MaXZlT1MvZXh0M2ZzLmltZwogCiAgICB1bW91bnQgLWwgL3NxdWFzaGZzCiAKICAgICMgQ3JlYXRlIG92ZXJsYXkgb25seSBpZiB0b3JhbSBpcyBub3Qgc2V0CiAgICBpZiBbIC16ICIkdG9yYW0iIF0gOyB0aGVuCiAgICAgICAgZG9fbGl2ZV9mcm9tX2Jhc2VfbG9vcAogICAgZmkKZmkKIAojIElmIHRoZSBrZXJuZWwgcGFyYW1ldGVyIHRvcmFtIGlzIHNldCwgY3JlYXRlIGEgdG1wZnMgZGV2aWNlIGFuZCBjb3B5IHRoZSAKIyBmaWxlc3lzdGVtIHRvIGl0LiBDb250aW51ZSB0aGUgYm9vdCBwcm9jZXNzIHdpdGggdGhpcyB0bXBmcyBkZXZpY2UgYXMKIyBhIHdyaXRhYmxlIHJvb3QgZGV2aWNlLgppZiBbIC1uICIkdG9yYW0iIF0gOyB0aGVuCiAgICBibG9ja3M9JCggYmxvY2tkZXYgLS1nZXRzeiAkQkFTRV9MT09QREVWICkKIAogICAgZWNobyAiQ3JlYXRlIHRtcGZzICgkYmxvY2tzIGJsb2NrcykgZm9yIHRoZSByb290IGZpbGVzeXN0ZW0uLi4iCiAgICBta2RpciAtcCAvaW1hZ2UKICAgIG1vdW50IC1uIC10IHRtcGZzIC1vIG5yX2Jsb2Nrcz0kYmxvY2tzIHRtcGZzIC9pbWFnZQogCiAgICBlY2hvICJDb3B5IGZpbGVzeXN0ZW0gaW1hZ2UgdG8gdG1wZnMuLi4gKHRoaXMgbWF5IHRha2UgYSBmZXcgbWludXRlcykiCiAgICBkZCBpZj0kQkFTRV9MT09QREVWIG9mPS9pbWFnZS9yb290ZnMuaW1nCiAKICAgIFJPT1RGU19MT09QREVWPSQoIGxvc2V0dXAgLWYgKQogICAgZWNobyAiQ3JlYXRlIGxvb3AgZGV2aWNlIGZvciB0aGUgcm9vdCBmaWxlc3lzdGVtOiAkUk9PVEZTX0xPT1BERVYiCiAgICBsb3NldHVwICRST09URlNfTE9PUERFViAvaW1hZ2Uvcm9vdGZzLmltZwogCiAgICBlY2hvICJJdCdzIHRpbWUgdG8gY2xlYW4gdXAuLiAiCiAKICAgIGVjaG8gIiA+IFVtb3VudGluZyBpbWFnZXMiCiAgICB1bW91bnQgLWwgL2ltYWdlCiAgICB1bW91bnQgLWwgL2Rldi8uaW5pdHJhbWZzL2xpdmUKIAogICAgZWNobyAiID4gRGV0YWNoICRPU01JTl9MT09QREVWIgogICAgbG9zZXR1cCAtZCAkT1NNSU5fTE9PUERFVgogCiAgICBlY2hvICIgPiBEZXRhY2ggJE9TTUlOX1NRVUFTSEVEX0xPT1BERVYiCiAgICBsb3NldHVwIC1kICRPU01JTl9TUVVBU0hFRF9MT09QREVWCiAgICAKICAgIGVjaG8gIiA+IERldGFjaCAkQkFTRV9MT09QREVWIgogICAgbG9zZXR1cCAtZCAkQkFTRV9MT09QREVWCiAgICAKICAgIGVjaG8gIiA+IERldGFjaCAkU1FVQVNIRURfTE9PUERFViIKICAgIGxvc2V0dXAgLWQgJFNRVUFTSEVEX0xPT1BERVYKICAgIAogICAgZWNobyAiID4gRGV0YWNoIC9kZXYvbG9vcDAiCiAgICBsb3NldHVwIC1kIC9kZXYvbG9vcDAKIAogICAgbG9zZXR1cCAtYQogCiAgICBlY2hvICJSb290IGZpbGVzeXN0ZW0gaXMgbm93IG9uICRST09URlNfTE9PUERFVi4iCiAgICBlY2hvCiAKICAgIGxuIC1zICRST09URlNfTE9PUERFViAvZGV2L3Jvb3QKICAgIHByaW50ZiAnL2Jpbi9tb3VudCAtbyBydyAlcyAlc1xuJyAiJFJPT1RGU19MT09QREVWIiAiJE5FV1JPT1QiID4gL21vdW50LzAxLSQkLWxpdmUuc2gKICAgIGV4aXQgMApmaQogCmlmIFsgLWIgIiRPU01JTl9MT09QREVWIiBdOyB0aGVuCiAgICAjIHNldCB1cCB0aGUgZGV2aWNlbWFwcGVyIHNuYXBzaG90IGRldmljZSwgd2hpY2ggd2lsbCBtZXJnZQogICAgIyB0aGUgbm9ybWFsIGxpdmUgZnMgaW1hZ2UsIGFuZCB0aGUgZGVsdGEsIGludG8gYSBtaW5pbXppZWQgZnMgaW1hZ2UKICAgIGlmIFsgLXogIiR0b3JhbSIgXSA7IHRoZW4KICAgICAgICBlY2hvICIwICQoIGJsb2NrZGV2IC0tZ2V0c3ogJEJBU0VfTE9PUERFViApIHNuYXBzaG90ICRCQVNFX0xPT1BERVYgJE9TTUlOX0xPT1BERVYgcCA4IiB8IGRtc2V0dXAgY3JlYXRlIC0tcmVhZG9ubHkgbGl2ZS1vc2ltZy1taW4KICAgIGZpCmZpCiAKUk9PVEZMQUdTPSIkKGdldGFyZyByb290ZmxhZ3MpIgppZiBbIC1uICIkUk9PVEZMQUdTIiBdOyB0aGVuCiAgICBST09URkxBR1M9Ii1vICRST09URkxBR1MiCmZpCiAKbG4gLWZzIC9kZXYvbWFwcGVyL2xpdmUtcncgL2Rldi9yb290CnByaW50ZiAnL2Jpbi9tb3VudCAlcyAvZGV2L21hcHBlci9saXZlLXJ3ICVzXG4nICIkUk9PVEZMQUdTIiAiJE5FV1JPT1QiID4gL21vdW50LzAxLSQkLWxpdmUuc2gKIApleGl0IDAK
_EOF_
cat /root/dracut-live-root-tmpfs.base64|base64 -d >/usr/share/dracut/modules.d/90dmsquash-live/dmsquash-live-root

ls /lib/modules | while read kernel; do
  echo ">>>> updating initramfs for kernel ${kernel}"
  /sbin/dracut -f "/boot/initramfs-${kernel}.img" "$kernel"
done

# iptables packages are pulled in no matter what %packages says
echo '>>>> disabling iptables and ip6tables services'
rm -f /etc/rc*.d/*ip{,6}tables

echo '>>>> updating fstab'
cat > /etc/fstab <<_EOF_
tmpfs     /               tmpfs   defaults         0 0
devpts    /dev/pts        devpts  gid=5,mode=620   0 0
tmpfs     /dev/shm        tmpfs   defaults         0 0
proc      /proc           proc    defaults         0 0
sysfs     /sys            sysfs   defaults         0 0
tmpfs     /tmp            tmpfs   mode=1777         0
tmpfs     /var/tmp        tmpfs   mode=1777         0
tmpfs     /var/cache/yum  tmpfs   mode=1777         0
_EOF_


echo '>>>> setting hostname'
sed -i -e 's/HOSTNAME=.*/HOSTNAME=genesis/' /etc/sysconfig/network

echo '>>>> setting /etc/resolv.conf to point to public resolvers'
# this is necessary to resolve get.rvm.io and friends in %post
cat >/etc/resolv.conf <<"__EOF__"
# you probably want to override this file with your own resolvers
nameserver 8.8.8.8
nameserver 8.8.4.4
__EOF__

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


# Install RVM
echo '>>>> setting up rvm'
# in kickstart post, $PATH isnt set so make sure rvm doesnt freak out
export PATH=/usr/bin:/bin:$PATH
\curl -sSL https://get.rvm.io | bash
echo '>>>> building ruby'
bash -c "source /etc/profile.d/rvm.sh && rvm install --default 2.2 && rvm cleanup sources"
bash -c "source /etc/profile.d/rvm.sh && rvm list"
bash -c "source /etc/profile.d/rvm.sh && ruby --version"

echo '>>>> creating /etc/gemrc'
cat >> /etc/gemrc <<EOF
install: --no-ri --no-rdoc
update: --no-ri --no-rdoc
EOF
#gem:  --no-document

echo '>>>> installing bundler gem'
su - -c 'source /etc/profile.d/rvm.sh && gem install bundler'

echo '>>>> creating /root/Gemfile'
# gem versions match Gemfiles in src/<GEM>/Gemfile
cat > /root/Gemfile  <<EOF
source 'https://rubygems.org'

gem 'ruby-termios', '~> 0.9.4'
gem 'httparty'
gem 'json'
EOF

echo '>>>> loading gems'
su - -c 'source /etc/profile.d/rvm.sh && bundle install --system --gemfile /root/Gemfile'

# TODO get these into the Gemfile
echo '>>>> installing basic genesis framework gems'
bash -c "source /etc/profile.d/rvm.sh && gem install genesis_retryingfetcher"
bash -c "source /etc/profile.d/rvm.sh && gem install genesis_promptcli"
bash -c "source /etc/profile.d/rvm.sh && gem install genesis_framework"
bash -c "source /etc/profile.d/rvm.sh && gem list"

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

%post --nochroot
echo "Copy initramfs outside the chroot:"
ls $INSTALL_ROOT/lib/modules | while read kernel; do
  src="$INSTALL_ROOT/boot/initramfs-${kernel}.img"
  dst="$LIVE_ROOT/isolinux/initrd0.img"
  echo " > $src -> $dst"
  cp -f $src $dst
done
%end
