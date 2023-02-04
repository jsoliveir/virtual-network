# Peer to peer network using vxlan 
Some scripting for creating p2p virtual networks



## usage:
```bash
-up            : being the network interface up
-down          : being the network interface down
-n|--netaddr   : network address for the interface to create
-r|--remote    : remote endpoint address
-p|--port      : endpoint destination port 
-i|--interface : network interface where the vxlan is going to be linked to
```

## vxlan up
```bash
vxlan.sh -up 192.168.0.1/24 -r 85.21.78.145 
vxlan.sh -up 192.168.0.1/24 -r 85.21.78.145 -p 4789 -i eth0
```
## vxlan down
```bash
vxlan.sh -down 192.168.0.1 
vxlan.sh -down vxbr0 

```
