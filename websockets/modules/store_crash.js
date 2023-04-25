import { createDecoder } from '@waku/core';

export const protocols =  ["store", "lightpush"]

export async function execute(node, encoder) {
    const sleep = Math.floor(Math.random() * 5000)
    console.log(`Sleeping for ${sleep}`)
    await delay(sleep)
    for (let i = 0;i < 5; i++) {
        try {
            await node.store.queryOrderedCallback(
                [createDecoder("/relay-ping/1/ping/null")],
                callback,
                { pageDirection: "backward" }
              );
        } catch (e) {
            console.log("Failed to send store query: " + e)
        } finally {
            await delay(1000);
        }
    }

    process.exit(1)
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