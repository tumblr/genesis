# well known facts/values
$genesis_ipaddress = '192.168.33.10' # must match Vagrantfile
$collins_url     = "https://collins.example.com"                 # FIXME
$genesis_service = "${genesis_ipaddress}:8000"
$genesis_user    = ''
$genesis_passw   = ''
# we're using Google and Level 3 resolvers here to get you started since we need
# to reach rubygems. this should be your internal nameservers.
$dhcp_dns_servers = '8.8.8.8, 4.4.2.2'                           # FIXME
$nexusserver     = 'nexus.example.com'                           # FIXME
$file_service    = "${nexusserver}:8888"
$gem_service     = "${nexusserver}:8808"
$image_service   = "${file_service}"
$ntp_server      = "ntp.example.com"                             # FIXME
$rpm_server      = 'repo.example.com'                            # FIXME
$rpm_base_url    = "http://${rpm_server}/mrepo/RPMS.epel"        # FIXME

# where static test configuration files are kept
$testenv         = 'testenv'

# info that phil would supply
$ipxe_config_url   = "http://${genesis_ipaddress}:8888/${testenv}/config.yaml"
$ipxe_menu_url     = "http://${genesis_ipaddress}:8888/${testenv}/menu.ipxe"
# to test non-published boot images switch kernel_source lines
$kernel_source     = "http://${genesis_ipaddress}:8888/ipxe-images"
#$kernel_source     = "http://${file_service}/genesis/ipxe-images"
$ipxe_initrd       = "${kernel_source}/genesis-initrd.img"
$ipxe_kernel       = "${kernel_source}/genesis-vmlinuz"
$ipxe_kernel_flags = 'rootflags=loop root=live:/genesis.iso rootfstype=auto ro liveimg vga=791 rd_NO_LUKS rd_NO_MD rd_NO_DM console=tty0 console=ttyS1,115200'

node default {
    include yumrepo
    include tftp::server
    include dhcp::server
    include bind::server
    include ipxe
    include iptables
    include genesis
    include gemserver
    include selinux::permissive
}
