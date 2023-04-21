#!/bin/sh

IP=$(ip a | grep "inet " | grep -Fv 127.0.0.1 | sed 's/.*inet \([^/]*\).*/\1/')

if [ -n "${TRAFFIC_GENERATOR}" ]; then
  echo "I am the traffic generator"
  RETRIES_TRAFFIC=${RETRIES_TRAFFIC:=10}

  while [ -z "${NODE_ENR}" ] && [ ${RETRIES_TRAFFIC} -ge 0 ]; do
    # the node can be bootstrap:8545 or other
    # use other to simualte gossip, eg:
    NODE_ENR=$(wget -O - --post-data='{"jsonrpc":"2.0","method":"get_waku_v2_debug_v1_info","params":[],"id":1}' --header='Content-Type:application/json' http://nwaku-simulator_nwaku_3:8545/ 2> /dev/null | sed 's/.*"enrUri":"\([^"]*\)".*/\1/');
    echo "Bootstrap node not ready, retrying (retries left: ${RETRIES_TRAFFIC})"
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

  RETRIES=${RETRIES:=0}

  while [ -z "${BOOTSTRAP_ENR}" ] && [ ${RETRIES} -ge 0 ]; do
    BOOTSTRAP_ENR=$(wget -O - --post-data='{"jsonrpc":"2.0","method":"get_waku_v2_debug_v1_info","params":[],"id":1}' --header='Content-Type:application/json' http://bootstrap:8545/ 2> /dev/null | sed 's/.*"enrUri":"\([^"]*\)".*/\1/');
    echo "Bootstrap node not ready, retrying (retries left: ${RETRIES})"
    sleep 1
    RETRIES=$(( $RETRIES - 1 ))
  done

#  if [ -z "${BOOTSTRAP_ENR}" ]; then
#     echo "Could not get BOOTSTRAP_ENR and none provided. Failing"
#     exit 1
#  fi

  echo "Using bootstrap node: ${BOOTSTRAP_ENR}"

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
        --rln-relay-content-topic=/toy-chat/2/luzhou/proto\
        --rln-relay-dynamic=True\
        --rln-relay-eth-account-address=0000000000000000000000000000000000000000\
        --rln-relay-eth-contract-address=0x4252105670fE33D2947e8EaD304969849E64f2a6\
        --rln-relay-eth-client-address=wss://goerli.infura.io/ws/v3/6af8fe9ec359410f9d6d26cbf746b86c\
        --websocket-port=8000\
        --websocket-secure-support=true\
        --websocket-secure-key-path=/opt/waku/key.pem\
        --websocket-secure-cert-path=/opt/waku/cert.pem\
        --discv5-discovery=true\
        --discv5-udp-port=9000\
        --discv5-enr-auto-update=False\
        --nat=extip:65.21.94.244\
        --log-level=DEBUG\
        --rpc-port=8545\
        --rpc-address=0.0.0.0\
        --tcp-port=30303\
        --metrics-server=True\
        --metrics-server-address=0.0.0.0\
        --dns-discovery=true\
        --dns-discovery-url=enrtree://AOGECG2SPND25EEFMAJ5WF3KSGJNSGV356DSTL2YVLLZWIV6SAYBM@prod.nodes.status.im\
        --discv5-bootstrap-node="enr:-P-4QPLMQ1zIYRAs4-F0mYmMxMihSySRtEIuGHJ_Qd_GL8XqUE78hpVUE97rgwlXnxPkzMJHkWyiNq7DT1fdZSy3QcgBgmlkgnY0gmlwhIbRi9KKbXVsdGlhZGRyc7hgAC02KG5vZGUtMDEuZG8tYW1zMy53YWt1djIudGVzdC5zdGF0dXNpbS5uZXQGdl8ALzYobm9kZS0wMS5kby1hbXMzLndha3V2Mi50ZXN0LnN0YXR1c2ltLm5ldAYfQN4DiXNlY3AyNTZrMaEDnr03Tuo77930a7sYLikftxnuG3BbC3gCFhA4632ooDaDdGNwgnZfg3VkcIIjKIV3YWt1Mg8"\
        --websocket-port=30304

#        --nat=extip:${IP}\
#        --discv5-bootstrap-node=${BOOTSTRAP_ENR}\

#        --dns-discovery=true\
#        --dns-discovery-url=enrtree://AOGECG2SPND25EEFMAJ5WF3KSGJNSGV356DSTL2YVLLZWIV6SAYBM@test.waku.nodes.status.im\
#        --nodekey=06873027778e85482aaf152c41b4bdef6a7cbae345052ac9a986e29fffacd7b6\
#        --dns4-domain-name="node-01.ac-cn-hongkong-c.wakuv2.test.statusim.net"\



fi
