import { bytesToUtf8, utf8ToBytes } from '../node_modules/@waku/utils/dist/bytes/index.js'

export const protocols =  ["lightpush", "relay"]

export async function execute(node, encoder) {
    const len = parseInt(process.env.MESSAGE_LENGTH)
    const rate = parseFloat(process.env.MESSAGE_RATE)
    console.log(`Will generate messages of ${len}B with rate ${rate}/s`)
    let i = 0;
    while (true) {

        let text = genMessage(len)
        const msg = text
        //console.log("Message: " + msg)
        console.log("Sending message " + i)
        try {
        const payload = utf8ToBytes(msg);
          await node.relay.send(encoder, { payload });
        } catch (e) {
            console.log("Failed to send msg: " + e)
        } finally {
            await delay(1000/rate);
            i++;
        }
    }
}

const genMessage = (length) => {
    let result = '';
    const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    const charactersLength = characters.length;
    let counter = 0;
    while (counter < length) {
        result += characters.charAt(Math.floor(Math.random() * charactersLength));
        counter += 1;
    }
    return result;
}

function delay(time) {
    return new Promise(resolve => setTimeout(resolve, time));
}
