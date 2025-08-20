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
    /* Macro to get the current time using rdtsc with lfence for serialization. */ \
    __asm__ __volatile__( \
        "mfence;"                  /* Serialize memory operations before timing */ \
        "rdtsc;"                   /* Read Time-Stamp Counter into EDX:EAX */ \
        "shl $32, %%rdx;"          /* Shift high 32 bits in EDX to upper half of RAX */ \
        "or %%rdx, %%rax;"         /* Combine EDX and EAX into RAX (full 64-bit TSC) */ \
        : "=a"(time)               /* Output: time in RAX */ \
        :                          /* No input */ \
        : "%rdx");                 /* Clobbers: RDX */ \
} while(0)

#define PING_PONG_CMP_XCHG(address, compare_token, set_token, number_repetitions_rcx, tries_counter) do { \
    register uint64_t _tries asm("r8") = 0; \
    register uint64_t _copy asm("r9") = 0; \
    __asm__ __volatile__( \
        "movq %%rax, %%r9\n\t"         /* Save compare_token (in RAX) to R9 for later reuse */ \
        "1:\n\t"                       /* Loop label for retries and repetitions */ \
        "incq %%r8\n\t"                /* Increment tries counter (R8) */ \
        "movq %%r9, %%rax\n\t"         /* Restore compare_token to RAX before cmpxchg */ \
        "lock cmpxchg %%rbx, (%%rdi)\n\t" /* Atomically compare RAX with *(RDI); if equal, set *(RDI) = RBX; else, RAX = *(RDI) */ \
        "jnz 1b\n\t"                   /* If not zero (cmpxchg failed), retry inner loop */ \
        "loop 1b\n\t"                  /* Decrement RCX (number_repetitions_rcx); if not zero, repeat outer loop */ \
        : "+r"(_tries), "+r"(_copy)    /* Output: updated tries and copy registers */ \
        : "c"(number_repetitions_rcx), /* Input: RCX = number of repetitions */ \
          "D"(address),                /* Input: RDI = address */ \
          "b"(set_token),              /* Input: RBX = set_token */ \
          "a"(compare_token)           /* Input: RAX = compare_token */ \
        : "memory");                   /* Clobbers: memory */ \
    tries_counter = _tries; \
} while(0)

#define FLUSHADDRESS(address,number_repetitions_rcx) do { \
    /* Flush the address from the cache using clflush instruction, do a clflush in a loop with rcx as a counter and a loop instruction. */ \
    __asm__ __volatile__( \
        "1:\n\t"                       /* Loop label */ \
        "clflush (%%rdi)\n\t"          /* Flush cache line at address in RDI */ \
        "loop 1b\n\t"                  /* Decrement RCX; if not zero, repeat loop */ \
        : \
        : "D"(address), "c"(number_repetitions_rcx) \
        : "memory"); \
} while(0)
