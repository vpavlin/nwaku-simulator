#!/bin/bash

for i in `seq 10 110`;do
podman stop nwaku-simulator_nwaku-${i}_1
podman rm nwaku-simulator_nwaku-${i}_1
done