#!/bin/bash

PRE_COMMIT_D="$(dirname "$0")/pre-commit.d"

for HOOK in $PRE_COMMIT_D/*; do
    bash $HOOK
    RESULT=$?
    if [ $RESULT != 0 ]; then
        echo "pre-commit.d/$HOOK returned non-zero: $RESULT, aborting commit"
        exit $RESULT
    fi
done

exit 0
