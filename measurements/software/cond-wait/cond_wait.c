/*
"Energy Efficiency Features of the Intel Alder Lake Architecture" Artifact
Collection Copyright (C) 2024 TU Dresden, Center for Information Services and
High Performance Computing

This file is part of the "Energy Efficiency Features of the Intel Alder Lake
Architecture" Artifact Collection.

The "Energy Efficiency Features of the Intel Alder Lake Architecture" Artifact
Collection is free software: you can redistribute it and/or modify it under the
terms of the GNU General Public License as published by the Free Software
Foundation, either version 3 of the License, or (at your option) any later
version.

The "Energy Efficiency Features of the Intel Alder Lake Architecture" Artifact
Collection is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
"Energy Efficiency Features of the Intel Alder Lake Architecture" Artifact
Collection. If not, see <https://www.gnu.org/licenses/>.
*/

#define _GNU_SOURCE

#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <sys/wait.h>
#include <unistd.h>

#include <assert.h>
#include <sched.h>

/* compile with gcc -pthread cond_wait.c */

static pthread_cond_t cv;
static pthread_mutex_t lock;

static int caller, callee, ntimes;
static long long delay;

void *thread(void *v) {
  cpu_set_t mask;
  CPU_ZERO(&mask);
  CPU_SET(callee, &mask);
  assert(0 == sched_setaffinity(0, sizeof(mask), &mask));
  int i;
  for (i = 0; i < ntimes; ++i) {
    pthread_mutex_lock(&lock);
    pthread_cond_wait(&cv, &lock);
    pthread_mutex_unlock(&lock);
  }
  return NULL;
}

void print_usage() {
  printf("./cond_wait <caller> <callee> <ntimes> <delay_in_us>\n");
}

int main(int argc, char **argv) {
  struct timeval before, after;

  if (argc != 5) {
    print_usage();
    exit(1);
  }

  caller = atoi(argv[1]);
  callee = atoi(argv[2]);
  ntimes = atoi(argv[3]);
  delay = atoll(argv[4]);

  pthread_t *t;
  pthread_mutex_init(&lock, NULL);
  pthread_cond_init(&cv, NULL);

  cpu_set_t mask;
  CPU_ZERO(&mask);
  CPU_SET(caller, &mask);
  assert(0 == sched_setaffinity(0, sizeof(mask), &mask));

  t = (pthread_t *)malloc(sizeof(pthread_t));
  pthread_create(t, NULL, thread, NULL);

  int i;
  for (i = 0; i < ntimes; ++i) {
    gettimeofday(&before, NULL);
    do {
      gettimeofday(&after, NULL);
    } while ((after.tv_sec * 1000000 + after.tv_usec -
              (before.tv_sec * 1000000 + before.tv_usec)) < delay);
    pthread_cond_signal(&cv);
  }
  return 0;
}
