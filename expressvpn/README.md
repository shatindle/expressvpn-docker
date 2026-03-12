# ExpressVPN in a container

This container should be used as base layer.

Replace `polkaned/expressvpn` with `polkaned/expressvpn-wo-iptables` for usage without iptables (not recommanded due to DNS leaking).

After version 5.1, environment variable names have changed.

## Prerequisites

1. Get your activation code from ExpressVPN web site.

## Download

`docker pull polkaned/expressvpn`

## Start the container

    docker run \
      --env=ACTIVATION_CODE={% your-activation-code %} \
      --env=REGION={% region  %} \
      --env=PROTOCOL={% protocol %} \
      --cap-add=NET_ADMIN \
      --device=/dev/net/tun \
      --privileged \
      --detach=true \
      --tty=true \
      --name=expressvpn \
      polkaned/expressvpn \
      /bin/bash

## Docker Compose

Other containers can use the network of the expressvpn container by declaring the entry `network_mode: service:expressvpn`.
In this case all traffic is routed via the vpn container. To reach the other containers locally the port forwarding must be done in the vpn container (the network mode service does not allow a port configuration).
To avoid DNS leaking, you need to replace the resolv.conf on other containers.

```
services:

expressvpn:
  container_name: expressvpn
  image: polkaned/expressvpn
  environment:
    - ACTIVATION_CODE={% your-activation-code %}
    - REGION={% region %}
    - PROTOCOL={% protocol %}
  cap_add:
    - NET_ADMIN
  devices:
    - /dev/net/tun
  stdin_open: true
  tty: true
  command: /bin/bash -c "cp /etc/resolv.conf /shared_data/resolv.conf && bash"
  privileged: true
  restart: unless-stopped
  volumes:
    - shared-volume:/shared_data
  ports:
    # ports of other containers that use the vpn (to access them locally)

downloader:
  image: example/downloader
  container_name: downloader
  network_mode: service:expressvpn
  depends_on:
    - expressvpn
  command: /bin/bash -c "sleep 20 && cp /shared_data/resolv.conf /etc/resolv.conf && bash"
  volumes:
    - shared-volume:/shared_data

volumes:
shared-volume:
```

## Configuration Reference

### ACTIVATION_CODE

A mandatory string containing your ExpressVPN activation code.

`ACTIVATION_CODE=ABCD1EFGH2IJKL3MNOP4QRS`

### REGION

A optional string containing the ExpressVPN server REGION. Connect to smart region if it is not set.

`SERVER=uk-docklands`

### PROTOCOL

A optional string containing the ExpressVPN protocol. Can be auto, lightwayudp, lightwaytcp, openvpnudp, openvpntcp, wireguard. Use auto if it is not set.

`PROTOCOL=wireguard`
