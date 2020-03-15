#!/bin/bash

a=($(iw dev wlan0 station dump))
#f=($(iw wlan0 mpath dump))

c=${#a[@]}
echo "size of an array is $c"
#echo "${f[@]}"
#echo "${f[12]} and ${f[22]}" | nc -c 192.168.10.1 3000
#sleep 1s
#echo "${c[22]}" | nc -c 192.168.10.1 3000
#echo "finished"
#v=($(nc -lp 3000))
#echo " ${v[2]} is the signal of ${v[0]}"



i=0
while [ $i -lt $c ]
do
	echo ${a[i]}
	echo $i
	i=$(($i+1))

done
