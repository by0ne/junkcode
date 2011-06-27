#!/bin/bash
for ip in $(seq 200 250)`;do
 ping -c 1 192.168.1.$ip | grep "bytes from" &
done
