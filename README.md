# migrationSVN2Git
Script for migration from svn to git
=> Wrap existing git svn command.

Options :

- author
Generate a author file
You will have to edit it manually in order to map existing user of svn with their email
./migrationScript.sh  author svn-repo git-repo-name

- clone 
Clone svn repository in a local git repository
./migrationScript.sh clone <author-file> <trunk> <branches> <tags> <svn-project-url> <git-repo-name>

- commit
usage :
./migrationScript.sh commit <repo-directory>
Delete git-svn-id  
  
- tags
./migrationScript.sh tags <repo-directory>
