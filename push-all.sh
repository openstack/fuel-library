#!/bin/bash

set -e

echo Checking for uncommitted changes in submodules
git submodule foreach -q 'if (git status -s | grep .); then echo You have uncommitted changes in $path; return 1; fi'

# Repeated to compensate for ssh connection resets :(
echo Checking if push will not conflict in submodules
git submodule foreach -q 'echo $path; git push -q --dry-run origin master || git push -q --dry-run origin master'

changed=0
subrepos=""
for subrepo in `git submodule status | grep '^+' | awk '{print $2}'`
do
    subrepos="$subrepo $subrepos"
    changed=1
    pushd $subrepo
        git push origin master
    popd
done
if [ "$changed" == "1" ]
then
    git commit -m "Updated submodules: $subrepos" $subrepos
fi
git push origin master
