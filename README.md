# nwaku-simulator

Requires:
* docker
* docker-compose

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

And 20 nodes are spined up that can be monitored on here:
http://localhost:3000/d/yns_4vFVk/nwaku-monitoring?orgId=1

To clean volumes and containers. Careful with this!
```
docker rm -f $(docker ps -a -q)
docker volume rm $(docker volume ls -q)
```
