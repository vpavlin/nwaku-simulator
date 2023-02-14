# nwaku-simulator

Requires:
* docker
* docker-compose

Without changing anything:

```
git clone https://github.com/alrevuelta/nwaku-simulator.git
cd nwaku-simulator
```

Don't change the `BOOTSTRAP_ENR` and set the `NWAKU_IMAGE` you want.

```
export BOOTSTRAP_ENR=enr:-JK4QHFki86UtnTNDC_MBpgMb5aqz5YjbjUY1emBBYFMYqtLMSRcqfQFxSrT5FVYCceWnSJKrI9GowK7jmvGw7y85W0BgmlkgnY0gmlwhKwUAP6Jc2VjcDI1NmsxoQM3Tqpf5eFn4Jztm4gB0Y0JVSJyxyZsW8QR-QU5DZb-PYN0Y3CC6mCDdWRwgiMohXdha3UyAQ
export NWAKU_IMAGE=statusteam/nim-waku:edce01cd
```

Now run everything.
```
docker-compose up -d
```

And 100 nodes are spined up that can be monitored on here:
http://localhost:3000/d/yns_4vFVk/nwaku-monitoring?orgId=1