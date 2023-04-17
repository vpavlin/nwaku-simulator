#!/bin/sh

IP=$(ip a | grep "inet " | grep -Fv 127.0.0.1 | sed 's/.*inet \([^/]*\).*/\1/')

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
