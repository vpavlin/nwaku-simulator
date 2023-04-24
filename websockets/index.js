import { createLightNode } from '@waku/create';
import { waitForRemotePeer, createEncoder, createDecoder } from '@waku/core';
import { multiaddr } from '@multiformats/multiaddr';
import { config } from 'dotenv';

config();


let content_topic = "/js-waku-examples/1/chat/utf8";
if (process.env.CONTENT_TOPIC) content_topic = process.env.CONTENT_TOPIC
const decoder = createDecoder(content_topic);
const encoder = createEncoder({ contentTopic: content_topic });

let address = undefined
if (process.env.MULTIADDRESS) {
    address = process.env.MULTIADDRESS
}

console.log(`Using ${address} to connect to`)

const node = await createLightNode();

await node.start();

const ma = multiaddr(address);

let plugin_name = 'lightpush'
if (process.env.PLUGIN) plugin_name = process.env.PLUGIN

const plugin = await import(`./modules/${plugin_name}.js`);
console.log(plugin.protocols)

await node.dial(ma, plugin.protocols);
await waitForRemotePeer(node, plugin.protocols);

const peers = await node.libp2p.peerStore.all();

console.log(peers)

await plugin.execute(node, encoder)


await node.stop()
