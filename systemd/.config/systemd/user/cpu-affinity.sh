#!/bin/bash

match-pid() { ps -aux | grep $1 | grep -v grep | grep -v $0 | awk '{print $2}'; }

pin() {
  for pid in `match-pid $2`; do
    current=$(taskset -p -c $pid 2>/dev/null | awk -F: '{gsub(/ /,"",$2); print $2}')
    [ "$current" = "$1" ] || taskset -p -c $1 $pid
  done
}

# for topology: cat /proc/cpuinfo | grep -E 'processor|core id'
first_core="0,4"
second_core="1,5"
third_core="2,6"
fourth_core="3,7"
third_and_fourth_cores="$third_core,$fourth_core"

# Core 1: Neovim UI (smooth typing)
pin $first_core nvim
pin $first_core kitty
pin $first_core zellij

# Core 2: Browser main thread
pin $second_core chromium

# Core 3: Compilation
pin $third_core storybook
pin $third_core cc1
pin $third_core ollama

# Core 3 + 4: Next.js compilation
pin $third_and_fourth_cores next-server
pin $third_and_fourth_cores "next dev"
pin $third_and_fourth_cores "next build"
pin $third_and_fourth_cores "node-modules/next"
pin $third_and_fourth_cores tailwindcss

# Core 4: LSP / TypeScript
pin $fourth_core tsserver
