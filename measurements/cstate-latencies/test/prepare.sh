#!/usr/bin/env bash

elab reboot Ubuntu-6.8.0-60-generic -a "isolcpus=1,2,3,56-111,168-223 nohz_full=1,2,3,56-111,168-223"
