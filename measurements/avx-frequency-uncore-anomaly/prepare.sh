#!/usr/bin/env bash

# cores 1 and 2 isolated with all threads
elab reboot Ubuntu-6.8.0-60-generic -a "isolcpus=1,2,113,114 nohz_full=1,2,113,114"
