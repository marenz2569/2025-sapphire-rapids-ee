/*
* Low-level Latency Measurements
* Copyright (C) 2025 TU Dresden, ZIH
* 
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
* 
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
* 
* You should have received a copy of the GNU General Public License
* along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#define TIMER(time) do { \
    /* Use the system counter (CNTVCT_EL0) for high-resolution timing on ARM64. */ \
    asm volatile( \
        "isb\n\t"                  /* Instruction Synchronization Barrier: ensures all previous instructions are completed */ \
        "mrs %0, cntvct_el0\n\t"   /* Read the virtual count register (high-res timer) into output variable */ \
        : "=r"(time)); \
} while(0)

#define PING_PONG_CMP_XCHG(cache_line, other_token, token, iterations, count) do { \
    register uint64_t _tries asm("x8") = 0; \
    asm volatile( \
        "mov x9, %[other_token]\n\t"      /* Move compare_token into x9 */ \
        "mov x10, %[token]\n\t"         /* Move set_token into x10 */ \
        "mov x11, %[cache_line]\n\t"           /* Move address into x11 */ \
        "mov x12, %[iterations]\n\t"/* Move number_repetitions into x12 (loop counter) */ \
        "dmb ish\n\t"                       /* Data Memory Barrier: ensures memory operations before this are globally visible */ \
        "0:\n\t"                            /* Outer loop label (for repetitions) */ \
        "1:\n\t"                            /* Inner loop label (for CAS retries) */ \
        "add x8, x8, #1\n\t"                /* Increment tries counter (x8) */ \
        "2:\n\t" \
        "LDAXR X0, [X11]\n\t" \
        "CMP X0, X9\n\t" \
        "B.NE 1b\n\t" \
        "STLXR W0, X10, [X11]\n\t" \
        "CBNZ W0, 2b\n\t" \
        "subs x12, x12, #1\n\t"             /* Decrement repetitions counter */ \
        "b.ne 0b\n\t"                       /* If not zero, repeat outer loop */ \
        : "+r"(_tries) \
        : [cache_line]"r"(cache_line), [other_token]"r"(other_token), [token]"r"(token), [iterations]"r"(iterations) \
        : "x9", "x10", "x11", "x12", "memory"); \
    count = _tries; \
} while(0)

#define FLUSHADDRESS(cache_line, iterations) do { \
    asm volatile( \
        "mov x9, %[cache_line]\n\t"            /* Move address into x9 */ \
        "mov x10, %[iterations]\n\t"/* Move number_repetitions into x10 (loop counter) */ \
        "1:\n\t"                            /* Loop label */ \
        "dc civac, x9\n\t"                  /* Data Cache Clean and Invalidate by Virtual Address to Point of Coherency */ \
        "dsb ish\n\t"                       /* Data Synchronization Barrier: ensures completion of cache maintenance */ \
        "subs x10, x10, #1\n\t"             /* Decrement loop counter */ \
        "b.ne 1b\n\t"                       /* If not zero, repeat loop */ \
        : \
	: [cache_line]"r"(cache_line), [iterations]"r"(iterations) \
        : "x9", "x10", "memory"); \
} while(0)

