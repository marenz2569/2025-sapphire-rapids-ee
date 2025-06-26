#!/usr/bin/env bash

sudo elab reboot Ubuntu-6.8.0-60-generic -a "isolcpus=1,2,3,57,58 nohz_full=1,2,3,57,58"
