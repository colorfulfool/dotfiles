#!/bin/bash
used=$(free -m | awk '/Mem:/ {printf "%.1f", $3}')
echo "{\"text\":\"󰿅 ${used}GB\",\"tooltip\":\"Memory\",\"class\":\"active\"}"
