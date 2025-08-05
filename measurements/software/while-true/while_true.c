#include <stdlib.h>

int main() {
#pragma omp parallel
  {
    while (1)
      ;
  }

  return EXIT_SUCCESS;
}