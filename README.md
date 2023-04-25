# nwaku-simulator

## Requires
* docker
* docker-compose

## How to run
Without changing anything:

```
git clone https://github.com/alrevuelta/nwaku-simulator.git
cd nwaku-simulator
```

Set the `NWAKU_IMAGE` you want.

```
export NWAKU_IMAGE=statusteam/nim-waku:v0.15.0
```

Now run everything.
```
docker-compose up -d
```

This will:
* spin up grafana/prometheus for monitoring
* spin up a bootstrap nwaku node
* spin up xx nwaku nodes (see flags)
* spin up a `waku-publisher` instance that will inject traffic into the network (see flags for rate and msg size)

And 20 nodes are spined up that can be monitored on here:
http://localhost:3000/d/yns_4vFVk/nwaku-monitoring?orgId=1


## warning

in case arp tables are overflowing:

```
sysctl net.ipv4.neigh.default.gc_thresh3=32000
```

## misc

To clean volumes and containers. Careful with this!
```
docker rm -f $(docker ps -a -q)
docker volume rm $(docker volume ls -q)
```
