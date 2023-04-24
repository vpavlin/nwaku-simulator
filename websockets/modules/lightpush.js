import { bytesToUtf8, utf8ToBytes } from '../node_modules/@waku/utils/dist/bytes/index.js'


export const protocols =  ["lightpush"]

export async function execute(node, encoder) {
    let text = "Hello World"
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
}

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