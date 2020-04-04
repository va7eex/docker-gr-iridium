#!/bin/bash

cp /usr/share/zoneinfo/$TZ /etc/localtime
echo $TZ > /etc/timezone

#create config file from environment values
echo "[osmosdr-source]" > /usr/share/sdr.conf
echo "samplerate=${SAMPLERATE}" >> /usr/share/sdr.conf
echo "center_freq=${CENTER_FREQ}" >> /usr/share/sdr.conf
echo "device_args='${SDR}=${SDR_INDEX},bias=${BIAS}'" >> /usr/share/sdr.conf
echo "bandwidth=${BANDWIDTH}" >> /usr/share/sdr.conf
echo "gain=${GAIN}" >> /usr/share/sdr.conf
echo "if_gain=${IF_GAIN}" >> /usr/share/sdr.conf

iridium-extractor -D 4 /usr/share/sdr.conf | grep "A:OK" > /opt/output/output.bits
