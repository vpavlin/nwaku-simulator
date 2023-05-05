#!/bin/sh

IP=$(ip a | grep "inet " | grep -Fv 127.0.0.1 | sed 's/.*inet \([^/]*\).*/\1/')

if [ -n "${TRAFFIC_GENERATOR}" ]; then
  echo "I am the traffic generator"
  RETRIES_TRAFFIC=${RETRIES_TRAFFIC:=10}

  while [ -z "${NODE_ENR}" ] && [ ${RETRIES_TRAFFIC} -ge 0 ]; do
    # the node can be bootstrap:8545 or other
    # use other to simualte gossip, eg:
    NODE_ENR=$(wget -O - --post-data='{"jsonrpc":"2.0","method":"get_waku_v2_debug_v1_info","params":[],"id":1}' --header='Content-Type:application/json' http://nwaku-simulator_nwaku_3:8545/ 2> /dev/null | sed 's/.*"enrUri":"\([^"]*\)".*/\1/');
    echo "Traffic generator node not ready, retrying (retries left: ${RETRIES_TRAFFIC})"
    sleep 1
    RETRIES_TRAFFIC=$(( $RETRIES_TRAFFIC - 1 ))
  done
  exec /main\
      --pubsub-topic="my-ptopic"\
      --content-topic="my-ctopic"\
      --msg-per-second=50\
      --msg-size-kb=2\
      --bootstrap-node=${NODE_ENR}
fi

if [ -n "${BOOTSTRAP_NODE}" ]; then
  echo "I am a bootstrap node"

  exec /usr/bin/wakunode\
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
      --nodekey=30348dd51465150e04a5d9d932c72864c8967f806cce60b5d26afeca1e77eb68\
      --nat=extip:${IP}
else
  echo "I am an ordinary nwaku node"

  RETRIES=${RETRIES:=10}

  while [ -z "${BOOTSTRAP_ENR}" ] && [ ${RETRIES} -ge 0 ]; do
    BOOTSTRAP_ENR=$(wget -O - --post-data='{"jsonrpc":"2.0","method":"get_waku_v2_debug_v1_info","params":[],"id":1}' --header='Content-Type:application/json' http://bootstrap:8545/ 2> /dev/null | sed 's/.*"enrUri":"\([^"]*\)".*/\1/');
    echo "Bootstrap node not ready, retrying (retries left: ${RETRIES})"
    sleep 1
    RETRIES=$(( $RETRIES - 1 ))
  done

  if [ -z "${BOOTSTRAP_ENR}" ]; then
     echo "Could not get BOOTSTRAP_ENR and none provided. Failing"
     exit 1
  fi

  echo "Using bootstrap node: ${BOOTSTRAP_ENR}"

  if [ -n "${ENABLE_WEBSOCKETS}" ]; then
    echo "Enabling websockets"
    exec usr/bin/wakunode\
        --relay=true\
        --store=true\
        --filter=true\
        --lightpush=true\
        --rln-relay=true\
        --peer-exchange=true\
        --rpc-admin=true\
        --peer-persistence=false\
        --keep-alive=true\
        --max-connections=150\
        --topics="/waku/2/default-waku/proto /waku/2/dev-waku/proto"\
        --store-message-db-url=sqlite:///data/store.sqlite3\
        --store-message-retention-policy=time:2592000\
        --websocket-port=8000\
        --websocket-secure-support=true\
        --websocket-secure-key-path=/opt/waku/key.pem\
        --websocket-secure-cert-path=/opt/waku/cert.pem\
        --discv5-discovery=true\
        --discv5-udp-port=9000\
        --discv5-enr-auto-update=True\
        --discv5-bootstrap-node=${BOOTSTRAP_ENR}\
        --nat=extip:${IP}\
        --log-level=DEBUG\
        --rpc-port=8545\
        --rpc-address=0.0.0.0\
        --tcp-port=30303\
        --metrics-server=True\
        --metrics-server-address=0.0.0.0\
        --dns-discovery=true
  else
    exec /usr/bin/wakunode\
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
        --discv5-bootstrap-node=${BOOTSTRAP_ENR}\
        --nat=extip:${IP}
  fi
fi
