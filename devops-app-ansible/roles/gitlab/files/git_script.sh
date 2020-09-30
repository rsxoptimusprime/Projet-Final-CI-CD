#!/usr/bin/bash

# clone and push all branches

mkdir devops-app
cd devops-app
git clone --bare https://gitlab.com/RaphaeldeGail/projet-devopsapp.git .git
git config --unset core.bare
git reset --hard
git push -u http://root:test1234@10.0.2.5/gitlab/root/devops-app.git --all
cd .. && rm -rf devops-app