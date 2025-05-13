#!/bin/sh

#SBATCH --error find_event.log.err
#SBATCH --output find_event.log
#SBATCH -N 500
#SBATCH -c 208
#SBATCH --exclusive

srun -N 500 -n 500 -c 208 --exclusive ./cbo_find_event.sh
