#!/bin/bash
set -e

# Functions
function usage {
    echo "usage: update-submodules.sh -o owner -r repo -b branch"
}

function GITSUBCLEAN {
    git clean -xfd ;
    git submodule foreach --recursive git clean -xfd ;
    git reset --hard ;
    git submodule foreach --recursive git reset --hard ;
    git submodule update --init --recursive
}

# Main
while [ "$1" != "" ]; do
    case $1 in
        -o | --owner )          shift
                                OWNER=$1
                                ;;
        -r | --repo )           shift
                                REPO=$1
                                ;;
        -b | --branch )         shift
                                BRANCH=$1
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done

x=${OWNER:?"Must provide owner."}
x=${REPO:?"Must provide repo."}
x=${BRANCH:?"Must provide branch."}

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
WORKBASEDIR="/tmp/${OWNER}/${REPO}"
WORKDIR="${WORKBASEDIR}/${TIMESTAMP}"
GITHUB="git@github.com"

# cleanup if older than 7 days
# do not error if cleanup does not succeed
set +e
find $WORKBASEDIR/* -type d -ctime +7 | xargs rm -rf
set -e

mkdir -p "$WORKDIR"
pushd "$WORKDIR" || exit
git clone "${GITHUB}:${OWNER}/${REPO}"
pushd "$REPO" || exit

TOPIC="maint/$BRANCH/update-submodules"
git checkout $BRANCH
GITSUBCLEAN
git checkout -b $TOPIC
git submodule update --recursive --remote
git add .
git commit -m 'MAINT - Update submodule SHAs'
git push -u origin $TOPIC

echo "$TOPIC"
