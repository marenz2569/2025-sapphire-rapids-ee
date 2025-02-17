# Avx Frequency License Bands

This folder contains the measurement and plotting scripts to infer the `P0n` turbo frequencies for different license levels.

## Initial Idea

We do this by running workloads that each trigger a different license level while being power unconstrained with a different number of cores.

On Sapphire Rapdis it is possible to read the differnt license levels from the following PCU counters:
Compare with https://github.com/intel/pcm/blob/f999ac1797ab574aa8ad20e1382e184865e860b9/src/pcm-power.cpp Lines 261 to 285

License Level | Note | PCU register
--- | --- | ---
0 | Same registers as used in ICX or SKX | `cpu/umask=0x07,event=0x28,name=LIC0`
1 | Same registers as used in ICX or SKX | `cpu/umask=0x18,event=0x28,name=LIC1`
2 | Same registers as used in ICX or SKX | `cpu/umask=0x20,event=0x28,name=LIC2`
3 | Infered register location | `cpu/umask=0x40,event=0x28,name=LIC3`

## Solution

P0n and P1 can be read from the CPU with the `intel-speed-select` tool.
