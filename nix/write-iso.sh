#!/bin/bash
sudo dd if=result/iso/nixos-25.11pre868392.e9f00bd89398-x86_64-linux.iso of=$1 bs=4M status=progress conv=fdatasync
