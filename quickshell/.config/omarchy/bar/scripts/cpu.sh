#!/bin/bash
freq=$(awk '/cpu MHz/ {printf "%.1f", $4/1000}' /proc/cpuinfo | head -1)
echo "{\"text\":\"󰍛 ${freq}GHz\",\"tooltip\":\"CPU\",\"class\":\"active\"}"
