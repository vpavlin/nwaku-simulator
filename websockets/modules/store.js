import { createDecoder } from '@waku/core';
import { bytesToUtf8, utf8ToBytes } from  '../node_modules/@waku/utils/dist/bytes/index.js'


export const protocols =  ["store", "lightpush"]

export async function execute(node, encoder) {
    let i = 0;
    while (true) {
        try {
            await node.store.queryOrderedCallback(
                [createDecoder("/relay-ping/1/ping/null")],
                callback,
                { pageDirection: "backward" }
              );
        } catch (e) {
            console.log("Failed to send store query: " + e)
        } finally {
            await delay(5000);
            i++;
        }
    }
}

const callback = (wakuMessage) => {
    try {
        const timestamp = wakuMessage.timestamp.toString();
        console.log(`${timestamp}`)
    } catch (e) {
        console.log(e)
    }
};

function delay(time) {
    return new Promise(resolve => setTimeout(resolve, time));
} 