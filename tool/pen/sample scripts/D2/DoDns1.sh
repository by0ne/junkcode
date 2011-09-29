#!/bin/bash
for name in $(cat dns-names.txt);do
host $name.checkpoint.com |grep "has address"
done
