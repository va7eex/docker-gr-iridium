#!/bin/sh

cp /usr/share/zoneinfo/$TZ /etc/localtime
echo $TZ > /etc/timezone

iridium-extractor -D 4 /usr/src/gr-iridium/examples/$SDR.conf | grep "A:OK" > /opt/output/output.bits
