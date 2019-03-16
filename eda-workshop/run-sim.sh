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

full_script=$(readlink -f $0)
script_name=$(basename $full_script)
script_dir=$(dirname $full_script)
current_dir=$(pwd)
SCRATCH_DIR=/${SCRATCH_FS}/scratch

echo "full_script: $full_script"
echo "script_name: $script_name"
echo "script_dir: $script_dir"
echo "current_dir: $current_dir"

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
  usage
}

# Process command line args
args=( "$@" )
for (( i = 0; i < ${#args[@]}; i++ )); do
  arg=${args[$i]}
  case $arg in
    -d|-debug)
      debug=1
    ;;
    -h|-help)
      help
      return 0
    ;;
    *)
      err_msg "Invalid option: $arg\n"
      usage
      return 1
  esac
done

## Call getopt to validate the provided input.
#options=$(/usr/bin/getopt -o f: --long "test,filesystem:" -- "$@")
#
## Bad args, something went wrong with getopt
#if [ $? -ne 0 ];
#then
#  echo "1: Incorrect options provided"
#  exit 1
#fi
#
## A little magic, necessary when using getopt
#eval set -- "$options"
#
#while true; do
#    case "$1" in
#
#       -f|--filesystem)
#          shift # argument to option is $2. shift to $1
#          SCRATCH_FS=$1
#          [[ ! $SCRATCH_FS =~ efs|fsx|ec2nfs ]] && {
#           echo "filesystem must be 'efs', 'fsx', or 'ec2nfs'."
#           exit 1
#          }
#          shift
#          ;;
#       --)
#          shift
#          break
#          ;;
#    esac
#done



# Source the HDK environment
echo "Sourcing HDK env"
. /etc/profile.d/aws-f1.sh
. /etc/profile.d/default_module.sh
. /etc/profile.d/modules.sh
. /etc/profile.d/which2.sh
. ${script_dir}/../hdk_setup.sh

# Move to the cl_dram_dma design and run the test_ddr test simulation
echo "Changing into scripts dir..."
cd $HDK_DIR/cl/examples/cl_dram_dma/verif/scripts
echo "Running make to start the sim..."
make TEST=test_ddr SCRATCH_DIR=$SCRATCH_DIR

