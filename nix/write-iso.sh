#!/bin/bash
sudo dd if=result/iso/nixos-25.11pre878042.544961dfcce8-x86_64-linux.iso of=$1 bs=4M status=progress conv=fdatasync
