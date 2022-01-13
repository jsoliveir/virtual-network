#!/bin/bash

# usage:

# -n|--netaddr   : network address for the interface to create
# -r|--remote    : remote endpoint address
# -p|--port      : endpoint destination port 
# -i|--interface : network interface where the vxlan is going to be linked to

# bring vxlan up
# vxlan -up 192.168.0.1/24 -r 85.21.78.145 
# vxlan -up 192.168.0.1/24 -r 85.21.78.145 -p 4789 -i eth0

# bring vxlan down
# vxlan -down 192.168.0.1 
# vxlan -down vxbr0 

NPFX=vx
STATE=up
PORT=4789
NETADDR=10.0.0.1/24
REMOTEADDR=127.0.0.1
REMOTEADDR=127.0.0.1
INTERFACE=$(ip route | grep default | cut -d ' ' -f 5)

while [[ $# -gt 0 ]]; do
  case $1 in
    -up)
      REMOTEADDR="$2"
      shift
      ;;
    -down)
      DOWN=$2
      shift 2
      ;;
    -n|--netaddr)
      NETADDR="$2"
      shift 2
      ;;
    -p|--port)
      PORT="$2"
      shift 2
      ;;
    -i|--interface)
      INTERFACE="$2"
      shift 2
      ;;
    *)
      echo "invalid option $1"
      exit 1
      ;;
  esac
done

if [ STATE == "up" ]; then
  BRID=$( ip link show | grep "br[0-9]+:" | wc -l )
  VXLANIF="${NPFX}lan${BRID}"
  BRIDGEIF="${NPFX}br${BRID}"
  
  echo "creating new bridge interface $BRIDGEIF"
  
  # create the vxlan interface
  ip link add $VXLANIF type vxlan id $BRID remote $REMOTEADDR dstport $PORT 

  # create the bridge interface
  ip link add $BRIDGEIF type bridge

  # assign an ip address to the bridge interface
  ip addr add $NETADDR dev $BRIDGEIF

  # add the vxlan to the bridge
  ip link set dev $VXLANIF master $BRIDGEIF

  # add the main network interface to the bridge
  ip link set dev $INTERFACE master $BRIDGEIF

  # bring interfaces up 
  ip link set up $VXLANIF
  ip link set up $BRIDGEIF
  
  # show the interface details
  echo "new routes:"
  ip route show | grep "$BRIDGEIF"
  echo "new interfaces:"
  ip addr show | grep "$BRIDGEIF:"
  
else
  # find bridge interface
  INTERFACE=$(ip addr show  | grep "inet.*$DOWN" | cut -d ' ' -f9 | grep "$NPFX" | head -n1)
  BRID=$(echo $INTERFACE | egrep -o "[0-9]+")
  VXLANIF="${NPFX}lan${BRID}"
  BRIDGEIF="${NPFX}br${BRID}"
  
  echo "removing bridge interface $BRIDGEIF"
  
  # delete interfaces
  ip link set down $VXLANIF
  ip link set down $BRIDGEIF
  ip link del $VXLANIF
  ip link del $BRIDGEIF
fi
