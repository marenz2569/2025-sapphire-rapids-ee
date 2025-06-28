#!/usr/bin/env bash

# cores 0-8 isolated
elab reboot Ubuntu-6.8.0-60-generic -a "isolcpus=0-8 nohz_full=0-8"
