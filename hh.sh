#!/bin/sh

a=($(iw wlan0 station dump))
c="${a[31]}"
echo "$c"
c=$(($c*-1))
echo "$c"

