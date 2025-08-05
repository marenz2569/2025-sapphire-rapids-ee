# Validating AVX Liceses Bands

The license bands that were extracted in the `avx-frequency-license-bands` are validated by running four payloads on all possible number of active cores.
The four payloads each trigger a specific license level.
To not be limited by RAPL we define core-power priority groups and measure the frequency on the core with the highest priority.
Due to Firestarter issue [#110](https://github.com/tud-zih-energy/FIRESTARTER/issues/110) we need to multiply the perf-freq reading by the number of threads.