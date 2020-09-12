#!/bin/bash

IFS=$'\n'
BRANCH_TO_FETCH=${1:-release_candidate}
REPOS=( benchprep-marketing benchprep-sso benchprep-user-manager benchprep-webapp benchprep-teachers benchprep-instructor-dashboard benchprep-assets benchprep-tenant benchprep-course-publisher tenant-dashboard benchprep-v2 )
STANDARD_BRANCHES=("release_candidate" "trunk" "master")

for repo in "${REPOS[@]}"
do
  cd $PROJECT_DIR/$repo
  echo "Getting latest of $repo"
  if [ -d ".git" ]
  then
    git fetch
    DEFAULT_BRANCH=`git remote show origin | grep "HEAD branch" | sed 's/.*: //'`

    if [ $DEFAULT_BRANCH != 'trunk' ]
    then
      DEFAULT_BRANCH=$BRANCH_TO_FETCH
    fi

    if [[ ! " ${STANDARD_BRANCHES[@]} " =~ " $DEFAULT_BRANCH " ]]; then
      git checkout --track origin/$DEFAULT_BRANCH
    fi

    echo "($DEFAULT_BRANCH)"
    git pull origin $DEFAULT_BRANCH
  else
    echo "Skipping because it doesn't look like it has a .git folder."
  fi
done

printf "\n\n"
echo "***************"
echo "GIT FETCH COMPLETE"
