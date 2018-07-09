#!/bin/bash    
#title       : migrationScript.sh
#description : Script pour migrer un repository svn distant en repository git.
#author		 : Mathieu MOMAL
#date        : 13/09/2017
#version     : 0.1
#usage		 : ./migrationScript.sh [author] [clone] [commit]
#notes       : autoriser ce fichier en execution (chmod +x migrationScript.sh)
#==============================================================================

if [[ "$@" =~ "-h" ]]; then
  echo "Usage: bash $SCRIPTNAME
			author => generate author file
			clone  => clone svn to git and go to repo
			commit => rename commit after cloning"
	exit 0
fi

#==============================================================================
# Generation du fichier auteur
# - Génére un fichier des auteurs
# il faut venir l'editer manuellement pour faire mapper les adresses emails inexistantes
# dans l'outils de gestion de conf. svn 
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
# Clone svn vers git
# - Récupere le code svn dans git via la commande 'git svn clone'
# - Gère les cas de 'layout' (arborescence de repository) non standard
# note : le format standard est trunk/ branches/ tags/
# note 2 : les chemins svn doivent ne pas contenir d'espace. 
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
# svn introduisant le texte 'git-svn-id' dans les messages des commits
# celui-ci est supprimé
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
# les branches prefixés par origin/tags sont transformer en tag :
# - creation du tag dans git
# - (suppression de la branche (origin/tags)
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
# Migration des branches
# creation de la branche git en local
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
