#!/bin/bash

grep GIT_ASKPASS .scripts/build_steps.sh &> /dev/null
if [ $? -ne 0 ]; then
    sed -i.bck '/export CONFIG_FILE=.*/a export GIT_ASKPASS="$(dirname "$0")/git-askpass.sh"' .scripts/build_steps.sh
fi

grep GIT_ASKPASS .scripts/run_osx_build.sh &> /dev/null
if [ $? -ne 0 ]; then
    sed -i.bck '/source run_conda_forge_build_setup/a export GIT_ASKPASS="$(dirname "$0")/git-askpass.sh"' .scripts/run_osx_build.sh
fi

