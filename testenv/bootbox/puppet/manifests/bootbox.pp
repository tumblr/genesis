
node default {
    include yumrepo
    include tftp::server 
    include dhcp::server
    include bind::server
    include nginx
    include ipxe
    include iptables
    include genesis
}
