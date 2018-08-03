#!/bin/bash
# Shell script that automates creation of a branch within multiple repositories. Please check usage for more details.

if [ -z "$GIT_ROOT" ]; then
    echo -e "GIT_ROOT was not set, using default: https://github.com/"
    GIT_ROOT=https://github.com/
fi

DEVELOP_BRANCH=develop
WORKING_DIR=$(pwd)"/tmp"
SCRIPT_NAME=`basename "$0"`

GIT_REPOS=$1
TARGET_BRANCH=$2

usage()
{
	echo -e "\nUSAGE"
	echo -e "\t$SCRIPT_NAME [git_repos] [target_branch]"
	echo -e "\nDESCRIPTION"
	echo -e "\tgit_repos - comma-separated list of target repositories"
	echo -e "\ttarget-branch - the name of target branch to create"
	echo -e "\nEXAMPLE"
	echo -e "\t./$SCRIPT_NAME test-repo1,test-repo2,test-repo3 release2018-Q3-W30\n"
}

if [ -z "$GIT_REPOS" ]; then
    usage
    exit 1
fi

if [ -z "$TARGET_BRANCH" ]; then
    usage
    exit 1
fi

mkdir -p "$WORKING_DIR"
cd "$WORKING_DIR"

for GIT_REPO in $(echo $GIT_REPOS | sed "s/,/ /g")
do
	echo "***** Working with repository $GIT_REPO"
	echo "Current path: $(pwd)"
	
	rm -rf $GIT_REPO/ || true
	echo "*** Clonning $DEVELOP_BRANCH..."
	git clone -b $DEVELOP_BRANCH $GIT_ROOT$GIT_REPO $GIT_REPO || continue
	cd $GIT_REPO || continue
	
	echo "Current path: $(pwd)"
	echo "*** Fetch all and reset..."
	git fetch --all
	git reset --hard origin/$DEVELOP_BRANCH
	git pull

	echo "*** Create $TARGET_BRANCH out of $DEVELOP_BRANCH..."
	git checkout -b $TARGET_BRANCH $DEVELOP_BRANCH
	
	echo "*** Push $TARGET_BRANCH remote..."
	git push origin $TARGET_BRANCH
	echo "*** Done."
	cd -
done

echo "Cleaning up tmp folder..."
rm -rf "$WORKING_DIR"
echo "Script finished."