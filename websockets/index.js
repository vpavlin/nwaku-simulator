import { bytesToUtf8, utf8ToBytes } from './node_modules/@waku/utils/dist/bytes/index.js'
import { createLightNode } from '@waku/create';
import { waitForRemotePeer, createEncoder, createDecoder } from '@waku/core';
import { multiaddr } from '@multiformats/multiaddr';
import { config } from 'dotenv';

config();

const callback = (wakuMessage) => {
    try {
        const text = bytesToUtf8(wakuMessage.payload);
        const timestamp = wakuMessage.timestamp.toString();
        console.log(`${text} - ${timestamp}`)
    } catch (e) {
        console.log(e)
    }
};

function delay(time) {
    return new Promise(resolve => setTimeout(resolve, time));
} 



let content_topic = "/js-waku-examples/1/chat/utf8";
if (process.env.CONTENT_TOPIC) content_topic = process.env.CONTENT_TOPIC
const decoder = createDecoder(content_topic);
const encoder = createEncoder({ contentTopic: content_topic });

let address = undefined
if (process.env.MULTIADDRESS) {
    address = process.env.MULTIADDRESS
}

let text = "Hello World"
if (process.env.TEXT) text = process.env.TEXT

console.log(`Using ${address} to connect to`)

const node = await createLightNode();

await node.start();

const ma = multiaddr(address);

await node.dial(ma, ["lightpush"]);
await waitForRemotePeer(node, ["lightpush"]);

const peers = await node.libp2p.peerStore.all();

console.log(peers)

//const unsubscribe = await node.filter.subscribe([decoder], callback);
let i = 0;
while (true) {
    const msg = text + " " + i
    console.log("Message: " + msg)
    try {
    await node.lightPush.send(encoder, {
        payload: utf8ToBytes(msg),
    });
    } catch (e) {
        console.log("Failed to send msg: " + e)
    } finally {
        await delay(5000);
        i++;
    }
}

//await unsubscribe();


await node.stop()
