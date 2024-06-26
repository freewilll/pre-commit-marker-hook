#!/bin/bash

# Adapted from Jake McCrary's
# https://jakemccrary.com/blog/2015/05/31/use-git-pre-commit-hooks-to-stop-unwanted-commits/

# If you use a GUI for controlling git, you might want to comment out the `tput` commands.
# Some users have had problems with those commands and whatever GUI they are using.

if git rev-parse --verify HEAD >/dev/null 2>&1
then
    against=HEAD
else
    # Initial commit: diff against an empty tree object
    against=$(git hash-object -t tree /dev/null)
fi

patch_filename=$(mktemp -t commit_hook_changes.XXXXXXX)
git diff --exit-code --binary --ignore-submodules --no-color > "$patch_filename"
has_unstaged_changes=$?

if [ $has_unstaged_changes -ne 0 ]; then
    # Unstaged changes have been found
    if [ ! -f "$patch_filename" ]; then
        echo "Failed to create a patch file"
        exit 1
    else
        echo "Stashing unstaged changes in $patch_filename."
        git checkout -- .
    fi
fi

quit() {
    if [ $has_unstaged_changes -ne 0 ]; then
        git apply "$patch_filename"
        if [ $? -ne 0 ]; then
            git checkout -- .
            git apply --whitespace=nowarm --ignore-whitespace "$patch_filename"
        fi
    fi

    exit $1
}


# Redirect output to stderr.
exec 1>&2

MARKER=__marker__
files_with_marker=$(git diff --cached --name-only --diff-filter=ACM $against | xargs -I{} grep -i "$MARKER" -l {} | tr '\n' ' ')

if [ "x${files_with_marker}x" != "xx" ]; then
    tput setaf 1
    echo "File being committed with '$MARKER' in it:"
    IFS=$'\n'
    for f in $(git diff --cached --name-only --diff-filter=ACM $against | xargs -I{} grep -i "$MARKER" -l {}); do
        echo $f
    done
    tput sgr0
    quit 1
fi

quit 0
