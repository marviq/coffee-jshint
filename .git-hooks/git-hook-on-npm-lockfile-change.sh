#!/usr/bin/env bash

##  Equivalent of `set +o posix`.
##
##  [`git flow ...` does `export POSIXLY_CORRECT=1`](https://github.com/nvie/gitflow/issues/289) which will break bash
##  [process substitution](https://www.gnu.org/software/bash/manual/html_node/Process-Substitution.html).
##
unset POSIXLY_CORRECT

##  Do not `post-checkout` when checking out a single file.
##
if [[ "$( basename "${0}" )" == "post-checkout" && "${3}" == "0" ]] ; then
    exit
fi

changed_files="$(git diff-tree -r --name-only --no-commit-id HEAD@{1} HEAD)"

function changed
{
    echo "${changed_files}" | grep --quiet "${1}"
}

function dependencies-changed
{
    extract='.dependencies'

        changed "${1}"  \
    &&  ! cmp --quiet   \
            <(git show HEAD@{1}:"${1}" | jq -cS "${extract}") \
            <(git show     HEAD:"${1}" | jq -cS "${extract}")
}

if dependencies-changed package-lock.json; then
    npm run refresh
fi
