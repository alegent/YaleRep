#!/bin/bash
#PBS -N SimpleQueue
#PBS -q fas_devel
#PBS -l nodes=2:ppn=8,naccesspolicy=singlejob,mem=8gb,walltime=1:00:00
#PBS -o PBS_SimpleQueue_out.txt
#PBS -j oe

cd "$PBS_O_WORKDIR"
module load MPI/OpenMPI/1.4.4
export SQ_PYTHON_DIR="/home/apps/fas/Langs/Python/2.7.2"

SQDIR="/lustre/home/client/fas/sbsc/ga254/tmp/tmp/SQ_Files_${PBS_JOBID}"
mkdir "$SQDIR"
exec > "$SQDIR/PBS_script.log"
echo "$(date +'%F %T') Batch script starting in earnest (pid: $$)."
echo "$(date +'%F %T') About to execute /lustre/home/client/apps/fas/Tools/SimpleQueue/SimpleQueue3.0/SQDedDriver.py using task file: TaskList.1"
PYTHON_BIN="$SQ_PYTHON_DIR/bin"
PYTHON_LIB="$SQ_PYTHON_DIR/lib"
if [ -z "$LD_LIBRARY_PATH" ]; then
  export LD_LIBRARY_PATH="$PYTHON_LIB"
else
  export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$PYTHON_LIB"
fi
"$PYTHON_BIN/python" "/lustre/home/client/apps/fas/Tools/SimpleQueue/SimpleQueue3.0/SQDedDriver.py" \
  --logFile="$SQDIR/SQ.log" \
  --maxTasksPerNode=8 --pnwss --wrapperVerbose \
  "TaskList.1"
RETURNCODE=$?
echo "$(date +'%F %T') Writing exited file."
touch "$SQDIR/exited"
echo "$(date +'%F %T') Batch script exiting, $RETURNCODE."
