#!/bin/bash
# bash
git filter-branch -f --commit-filter '
        if [ "$GIT_AUTHOR_NAME" = "username" ] || [ "$GIT_AUTHOR_NAME" = "username2" ];
        then
                GIT_AUTHOR_NAME="waytoarcher";
                GIT_AUTHOR_EMAIL="waytoarcher@gmail.com";
                git commit-tree "$@";
        else
                git commit-tree "$@";
        fi' HEAD
