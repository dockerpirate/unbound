## Architectures

The architectures supported by this image are:

- `linux/arm64`
- `linux/arm/v7`
- `linux/arm/v6`
- `linux/amd64`
- `linux/x86`

Simply pulling `dockerpirate/unbound` should retrieve the correct image for your arch.

## Test

```bash
# run selftest on local image
docker run --rm -d --name unbound dockerpirate/unbound
docker exec unbound unbound-anchor -v
docker exec unbound drill -p 53 sigok.verteiltesysteme.net @127.0.0.1
docker exec unbound drill -p 53 sigfail.verteiltesysteme.net @127.0.0.1
docker stop unbound
```
## First start
```bash
# At first start you have to copy config files to your host folder
docker run --rm -d --name unbound -v <path>:/unbound dockerpirate/unbound
docker exec unbound cp -a /etc/unbound /
docker stop unbound
```

## Usage

NLnet Labs documentation: <https://nlnetlabs.nl/documentation/unbound/>

```bash
# print general usage
docker run --rm dockerpirate/unbound -h

# run a recursive dns server on host port 5053 (default = 53)
docker run --name unbound -p 5053:53/tcp -p 5053:53/udp dockerpirate/unbound

# run unbound server with configuration mounted from a host directory
docker run -d --name unbound \
            -p 5053:53/udp \
            -p 5053:53/tcp \
            --hostname unbound \
            -m 64m \
            --dns=127.0.0.1 \
            --restart unless-stopped \
            --cap-add=NET_ADMIN \
            -v /path/to/config:/etc/unbound \
            -v /etc/localtime:/etc/localtime:ro \
            - v /etc/timezone:/etc/timezone:ro \
            --net=<custom network> \
            --ip 172.18.0.x \
            dockerpirate/unbound

# update the root trust anchor for DNSSEC validation
# assumes your existing container is named 'unbound' as in the example above
docker exec unbound unbound-anchor -a "/etc/unbound/root.key"
```

The provided `unbound.conf` will provide recursive DNS with DNSSEC validation.
However Unbound has many features available so I recommend getting familiar with the documentation and mounting your own config directory.

- <https://nlnetlabs.nl/documentation/unbound/unbound.conf/>
- <https://nlnetlabs.nl/documentation/unbound/howto-optimise/>

Please note that `chroot` and `username` configuration fields are not supported as the service is already running as `unbound:unbound`.

### Update anchor-file and hints

```bash
docker exec unbound unbound-anchor -a /etc/unbound/root.key
```
Download on host run hints-file and put in mounted folder
```bash
wget -O <path>/root.hints https://www.internic.net/domain/named.root
```

### Example

Use Unbound as upstream DNS for [Pi-Hole](https://pi-hole.net/).

```bash
# run unbound and bind to port 5053 to avoid conflicts with pihole on port 53
docker run -d --name unbound -p 5053:5053/tcp -p 5053:5053/udp --restart=unless-stopped dockerpirate/unbound

# create new network (pihole_net), run pihole and bind to host network stack with 172.18.0.2:5053 (unbound) as DNS1/DNS2
docker run -d --name pihole \
    -p 53:53/tcp -p 53:53/udp \
    -p 80:80 \
    -p 443:443 \
    -e ServerIP=172.18.0.2 \
    -e TZ=Europe/Berlin \
    -e WEBPASSWORD=Password \
    -e DNS1=172.18.0.3#5053 \
    -e DNS2=127.0.0.1#5053 \
    -v "$(pwd)/etc-pihole/:/etc/pihole/" \
    -v "$(pwd)/etc-dnsmasq.d/:/etc/dnsmasq.d/" \
    -m 256m \
    --dns=127.0.0.1 \
    --dns=1.1.1.1 \
    --network=pihole_net \
    --hostname pihole \
    --restart=unless-stopped \
    pihole/pihole
```

If using docker-compose something like the following may suffice.

```yaml
version: '2.1'

volumes:
  pihole:
  dnsmasq:

services:
  pihole:
    image: pihole/pihole
    privileged: true
    volumes:
      - 'pihole:/etc/pihole'
      - 'dnsmasq:/etc/dnsmasq.d'
    dns:
      - '127.0.0.1'
      - '1.1.1.1'
    network_mode: host
    environment:
      - 'ServerIP=192.168.8.8'
      - 'TZ=America/Toronto'
      - 'WEBPASSWORD=secretpassword'
      - 'DNS1=127.0.0.1#5053'
      - 'DNS2=127.0.0.1#5053'
      - 'INTERFACE=eth0'
      - 'DNSMASQ_LISTENING=eth0'
  unbound:
    image: dockerpirate/unbound
    ports:
      - '5053:5053/udp'
```

## Licenses

- klutchell/unbound: [MIT License](https://gitlab.com/klutchell/unbound/blob/master/LICENSE)
- unbound: [BSD 3-Clause "New" or "Revised" License](https://github.com/NLnetLabs/unbound/blob/master/LICENSE)
