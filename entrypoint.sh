#!/bin/sh

#where is that \r?
cp /usr/share/zoneinfo/$TZ /etc/localtime
echo $TZ > /etc/timezone

#create config file from environment values
touch /tmp/sdr.conf
echo "[osmosdr-source]" > /tmp/sdr.conf
echo "samplerate=${SAMPLERATE}" >> /tmp/sdr.conf
echo "center_freq=${CENTER_FREQ}" >> /tmp/sdr.conf
echo "device_args='${SDR}=${SDR_INDEX},bias=${BIAS}'" >> /tmp/sdr.conf
echo "bandwidth=${BANDWIDTH}" >> /tmp/sdr.conf
echo "gain=${GAIN}" >> /tmp/sdr.conf
echo "if_gain=${IF_GAIN}" >> /tmp/sdr.conf

iridium-extractor -D 4 /tmp/sdr.conf | grep "A:OK" > /opt/output/output.bits
