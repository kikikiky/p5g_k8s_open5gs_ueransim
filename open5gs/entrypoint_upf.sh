#!/bin/bash

set -eo pipefail


# tun iface create
#function tun_create {
    ###########################################################################
    if ! grep "ogstun" /proc/net/dev > /dev/null; then
        echo "Creating ogstun device"
        ip tuntap add name ogstun mode tun
    fi

    ip addr del $IPV4_TUN_ADDR dev ogstun 2> /dev/null || true
    ip addr add $IPV4_TUN_ADDR dev ogstun;

    sysctl -w net.ipv6.conf.all.disable_ipv6=0;         
    ip addr del $IPV6_TUN_ADDR dev ogstun 2> /dev/null || true
    ip addr add $IPV6_TUN_ADDR dev ogstun
    
    ip link set ogstun up
    sh -c "echo 1 > /proc/sys/net/ipv4/ip_forward";
    if [ "$ENABLE_NAT" = true ] ; then
      iptables -t nat -A POSTROUTING -s $IPV4_TUN_SUBNET ! -o ogstun -j MASQUERADE;
    fi
    
    #############################################################################
    if ! grep "ogstun2" /proc/net/dev > /dev/null; then
        echo "Creating ogstun2 device"
        ip tuntap add name ogstun2 mode tun
    fi

    ip addr del $IPV4_TUN_ADDR2 dev ogstun2 2> /dev/null || true
    ip addr add $IPV4_TUN_ADDR2 dev ogstun2;

    sysctl -w net.ipv6.conf.all.disable_ipv6=0;         
    ip addr del $IPV6_TUN_ADDR2 dev ogstun2 2> /dev/null || true
    ip addr add $IPV6_TUN_ADDR2 dev ogstun2
    
    ip link set ogstun2 up
    sh -c "echo 1 > /proc/sys/net/ipv4/ip_forward";
    if [ "$ENABLE_NAT" = true ] ; then
      iptables -t nat -A POSTROUTING -s $IPV4_TUN_SUBNET2 ! -o ogstun2 -j MASQUERADE;
    fi
    
    ###############################################################################
#}
 
# COMMAND=$1
#if [[ "$COMMAND"  == *"open5gs-pgwd" ]] || [[ "$COMMAND"  == *"open5gs-upfd" ]]; then
#tun_create
#fi

#tcpdump -i eth0 -s 1500 -w test.pcap &

# Temporary patch to solve the case of docker internal dns not resolving "not running" container names.
# Just wait 10 seconds to be "running" and resolvable
#if [[ "$COMMAND"  == *"open5gs-pcrfd" ]] \
#    || [[ "$COMMAND"  == *"open5gs-mmed" ]] \
#    || [[ "$COMMAND"  == *"open5gs-sgwcd" ]] \
#    || [[ "$COMMAND"  == *"open5gs-upfd" ]]; then
#sleep 30
#fi

$@

exit 1
