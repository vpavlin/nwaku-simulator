#!/bin/bash

for i in `seq 10 110`;do
podman run --name=nwaku-simulator_nwaku-${i}_1\
     -d\
     --label io.podman.compose.config-hash=e27dafaa757ad3b6da1f98acd309c5dc420e69a1adcefc73104b816967816433\
     --label io.podman.compose.project=nwaku-simulator\
     --label io.podman.compose.version=1.0.6\
     --label PODMAN_SYSTEMD_UNIT=podman-compose@nwaku-simulator.service\
     --label com.docker.compose.project=nwaku-simulator\
     --label com.docker.compose.project.working_dir=/home/vpavlin/devel/github.com/alrevuelta/nwaku-simulator\
     --label com.docker.compose.project.config_files=docker-compose.yml\
     --label com.docker.compose.container-number=1\
     --label com.docker.compose.service=nwaku-$i\
     --dns 8.8.8.8\
     --net nwaku-simulator_mynetwork\
     --network-alias nwaku-${i}\
     --ip=192.155.0.${i}\
     --restart on-failure\
     statusteam/nim-waku:v0.15.0\
     --relay=true\
     --rpc-admin=true\
     --keep-alive=true\
     --max-connections=150\
     --dns-discovery=true\
     --discv5-discovery=true\
     --discv5-enr-auto-update=True\
     --log-level=INFO\
     --rpc-address=0.0.0.0\
     --metrics-server=True\
     --metrics-server-address=0.0.0.0\
     --discv5-bootstrap-node=enr:-JK4QA4sbSjLbfaYU5jdAwCj9Zz1o4U0aRR1qxMK_xp4HdnkGq9nYmB0TC7mX7uyEdTBpA01OJo-Zi-lsWLCDJTBKekBgmlkgnY0gmlwhMCbAMiJc2VjcDI1NmsxoQM3Tqpf5eFn4Jztm4gB0Y0JVSJyxyZsW8QR-QU5DZb-PYN0Y3CC6mCDdWRwgiMohXdha3UyAQ\
     --nat=extip:192.155.0.${i}
done