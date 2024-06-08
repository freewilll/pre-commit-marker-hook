# Marker Text pre-commit hook

A git pre-commit hook preventing files from being committed that have a marker text in there. If an exiting pre-commit hook is found such as [pre-commit](https://pre-commit.com/#install), it is kept in place and will be run as well.

# Usage:
In the root of a git repository, run:
```
install.py TODO
```

# Example
```
$ echo "TODO" > example

$ git add example

$ git ci -am 'example'
File being committed with 'wwix' in it:
example
pre-commit.d/.git/hooks/pre-commit.d/wwip.sh returned non-zero: 1, aborting commit
```
