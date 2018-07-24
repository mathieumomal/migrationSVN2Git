#!/bin/bash    
#title       : migrationScript.sh
#description : Script migrating svn repository to git repository
#author      : Mathieu MOMAL
#date        : 13/09/2017
#version     : 0.1
#usage       : ./migrationScript.sh [author] [clone] [commit]
#notes       : authorize this file in execution (chmod +x migrationScript.sh)
#==============================================================================

if [[ "$@" =~ "-h" ]]; then
  echo "Usage: bash $SCRIPTNAME
			author => generate author file
			clone  => clone svn to git and go to repo
			commit => rename commit after cloning"
	exit 0
fi

#==============================================================================
# Generate a author file 
#
# You will have to edit it manually in order to map existing user of svn with their email 
# Usage : ./migrationScript.sh author svn-repo git-repo-name
#==============================================================================
if [[ "$1" =~ "author" ]]; then
	if [ $# -lt 2 ]
	then
		echo "Usage: $0 $1 svn git-repo-name"
		exit 1
	fi
	echo "generating $3";
	svn log --quiet --xml -q  $2 | sed -n -e "s/<\/\?author>//g" -e "/[<>]/!p" | sort | sed "$!N; /^\(.*\)\n\1$/!P; D" > $3
		if [ $? == 0 ]; then
			echo "$3 GENERATED";
		fi
	exit 0
fi

#==============================================================================
# Clone svn to git
#
# Clone svn repository in a local git repository 
# Usage : ./migrationScript.sh clone  author-file trunk branches tags svn-project-url git-repo-name
# Note 1 : branches and tags can be ignore with ""
# Note 2 : standard format are trunk/ branches/ tags/
# Note 3 : svn path must not contain space chars. 
#==============================================================================
if [[ "$1" =~ "clone" ]]; then
	if [ $# -lt 7 ]
	then
		echo "Usage: $0 $1 author-file trunk branches tags svn-project-url git-repo-name"
		exit 1
	fi
	
	echo "SVN CLONE : IN PROGRESS";
	echo "git svn clone  --prefix=origin/ --authors-file=$2 --trunk="$3" --branches="$4" --tags="$5" --no-minimize-url ""$6"" $7"
	git svn clone  --prefix=origin/ --authors-file=$2 --trunk="$3" --branches="$4" --tags="$5" --no-minimize-url "$6" $7
	
	if [ $? == 0 ]; then
		echo "SVN CLONE : OK";
	fi
	
	cd $repo
	if [ $? == 0 ]; then
		echo "Go to $repo : OK";
		exit 0
	fi
	
	exit $?
fi

#==============================================================================
# Rename commit after cloning
#
# Delete git-svn-id in commit message.
#==============================================================================
if [[ "$1" =~ "commit" ]]; then
	if [ $# -lt 2 ]
	then
		echo "Usage: $0 $1 repo-directory"
		exit 1
	fi
	
	cd $2
	
	if [ $? == 0 ]; then
		echo "Going to $2 : OK";
	fi
	
	git filter-branch --msg-filter 'sed -e "/git-svn-id:/d"'
	
	if [ $? == 0 ]; then
		echo "Commit rename : OK";
		exit 0
	fi
	
	exit $?
fi

#==============================================================================
# Migration Tags
# branches prefixes by origin/tags are transform in tag :
# - Create a tag in git repository
# - Delete old branch (origin/tags)
#==============================================================================
if [[ "$1" =~ "tags" ]]; then

	if [ $# -lt 2 ]
	then
		echo "Usage: $0 $1 repo-directory"
		exit 1
	fi
	
	cd $2
	if [ $? == 0 ]; then
		echo "Going to $2 : OK";
	fi

	echo "Delete ALL the old tags"
	for t in `git tag` ; do git tag -d $t > /dev/null ; done

	for branch in `git branch -r | grep 'origin/tags/'` ; do
	  t=`echo $branch | sed s_origin\/tags/__`

	  commit=`git log -1 --pretty="%H" $branch | cat`
	  message=`git log -1 --pretty="%s" $branch | cat`
	  previous_commit=`git log -1 --pretty="%H" $commit^ | cat`

	  echo "create tag $t"
	  git tag $t -a -f -m "$message" $previous_commit > /dev/null
	  echo "delete old $branch"
	  git branch -d -r $branch
	done
	exit 0
fi

#==============================================================================
# Migration of branches
#
# create git branch in local git repository
#==============================================================================
if [[ "$1" =~ "branches" ]]; then

	if [ $# -lt 2 ]
	then
		echo "Usage: $0 $1 repo-directory"
		exit 1
	fi
	
	cd $2
	if [ $? == 0 ]; then
		echo "Going to $2 : OK";
	fi

	for branch in `git branch -r | grep 'origin/'` ; do
		branchName=`echo $branch | sed s_origin/__`
			if [ $? == 0 ]; then
				echo "create $branchName locally"
				git branch $branchName $branch > /dev/null
			fi 
	done
	exit 0
fi
