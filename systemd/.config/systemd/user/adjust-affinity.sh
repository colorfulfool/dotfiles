#!/bin/bash

match-pid() { ps -aux | grep $1 | grep -v grep | grep -v $0 | awk '{print $2}'; }

pin() { for pid in `match-pid $2`; do taskset -p -c $1 $pid; done; }

# for topology: cat /proc/cpuinfo | grep -E 'processor|core id'
first_core="0,2"
second_core="1,3"

pin $first_core nvim
pin $first_core kitty
pin $first_core zellij

pin $second_core next-server
pin $second_core "next dev"
pin $second_core "next build"
pin $second_core "node-modules/next"
pin $second_core tailwindcss
pin $second_core storybook
pin $second_core cc1
