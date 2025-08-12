# Test for Uncore frequency changes

These scripts test measure the uncore frequeny change latencies [1,2] to test how long it takes to change uncore frequencies.

## Uncore frequency switch latencies

### Precondition

- msrtools (rdmsr, wrmsr) must be available
- the kernel module msr should be loaded

## References

[1] Schöne, R., Ilsche, T., Bielert, M., Gocht, A., & Hackenberg, D. (2019, July). Energy efficiency features of the intel skylake-sp processor and their impact on performance. In 2019 International Conference on High Performance Computing & Simulation (HPCS) (pp. 399-406). IEEE.
[2] https://github.com/tud-zih-energy/2019-HPCS-Skylake-EE/tree/master/ufs-latencies
