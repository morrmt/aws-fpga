#!/bin/bash

#
# Copyright 2016 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Amazon Software License (the "License"). You may not use
# this file except in compliance with the License. A copy of the License is
# located at
#
#    http://aws.amazon.com/asl/
#
# or in the "license" file accompanying this file. This file is distributed on
# an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, express or
# implied. See the License for the specific language governing permissions and
# limitations under the License.

LC_ALL="en_US.UTF-8"
full_script=$(readlink -f $0)
script_name=$(basename $full_script)
script_dir=$(dirname $full_script)
current_dir=$(pwd)

function usage {
  echo -e "USAGE: $script_name [-d|-debug] [-h|-help]"
}

function help {

  cat << EOF
  $script_name

  Executes an RTL logic simulation using the Xilinx xsim simulator.
  Simulation in *xsim* happens in two phases:

    1. The simulator's compiler, xelab, compiles the HDL model into a snapshot,
       which is a representation of the model in a form that the simulator can execute.
       This is the most IO-intensive phase.
    2. The simulator loads and executes (using the *xsim* command) the snapshot to
       simulate the model.  This phases is less IO-intensive and more CPU-bound.
EOF
}

# Process command line args
PARAMS=""
while (( "$#" )); do
  case "$1" in
    -s|--scratch-dir)
      SCRATCH_DIR=$2
      shift 2
      ;;
    --) # end argument parsing
      shift
      break
      ;;
    -*|--*=) # unsupported flags
      echo "Error: Unsupported flag $1" >&2
      help
      exit 1
      ;;
    *) # preserve positional arguments
      PARAMS="$PARAMS $1"
      shift
      ;;
  esac
done
# set positional arguments in their proper place
eval set -- "$PARAMS"


# Source the HDK environment
echo "Sourcing HDK env"
. /etc/profile.d/aws-f1.sh
. /etc/profile.d/default_module.sh
. /etc/profile.d/modules.sh
. /etc/profile.d/which2.sh
. ${script_dir}/../hdk_setup.sh

echo "SCRATCH_DIR = $scratch_dir"
# Move to the cl_dram_dma design and run the test_ddr test simulation
echo "Changing into scripts dir..."
cd $HDK_DIR/cl/examples/cl_dram_dma/verif/scripts
echo "Running make to start the sim..."
make TEST=test_ddr SCRATCH_DIR=$SCRATCH_DIR

