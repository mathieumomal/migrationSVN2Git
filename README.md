# migrationSVN2Git
Script for migration from svn to git
=> Wrap existing git svn command.

Prerequisites :
Git has to be installed on your system, see https://git-scm.com/download

Options :

- author
Description :
Generate a author file
You will have to edit it manually in order to map existing user of svn with their email
Usage :
./migrationScript.sh  author svn-repo git-repo-name

- clone 
Description :
Clone svn repository in a local git repository
Usage :
./migrationScript.sh clone <author-file> <trunk> <branches> <tags> <svn-project-url> <git-repo-name>

- commit
Description :
Delete git-svn-id in commit message  
Usage :
./migrationScript.sh commit <repo-directory>
  
- tags
Description :
Branchs prefixed by origin/tags will be change for tag
creation of tag in git repository
deletion of branch origin/tags
Usage :
./migrationScript.sh tags <repo-directory>
