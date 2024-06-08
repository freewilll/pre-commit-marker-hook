#!/usr/bin/env python

import os
import shutil
import stat
from argparse import ArgumentParser
from pathlib import Path


def install(marker: str):
    # Install wwip pre-commit hook, taking into account hooks that may already be
    # installed.

    if not os.path.exists(".git"):
        print("Cannot find .git directory. This must be run from a git repository.")
        exit(1)

    hooks_dir = Path(".git/hooks")
    pre_commit_d_dir = hooks_dir / "pre-commit.d"

    if pre_commit_d_dir.exists():
        print("Already installed")
        exit(1)

    os.mkdir(pre_commit_d_dir)

    with (Path(__file__).parent / "check-marker.sh").open() as f:
        contents = f.read()
        contents = contents.replace("__marker__", marker)

    wwip_path = pre_commit_d_dir / "wwip.sh"
    with wwip_path.open("w") as f:
        f.write(contents)
    st = os.stat(wwip_path)
    wwip_path.chmod(st.st_mode | stat.S_IEXEC)

    # If an existing pre-commit script exists, copy it over to to pre-commit.d
    pre_commit_path = hooks_dir / "pre-commit"
    if pre_commit_path.exists():
        found_pre_commit__path = pre_commit_d_dir / "found-pre-commit.sh"
        shutil.copyfile(pre_commit_path, found_pre_commit__path)
        st = os.stat(found_pre_commit__path)
        found_pre_commit__path.chmod(st.st_mode | stat.S_IEXEC)

    # Copy pre-commit script
    shutil.copyfile(Path(__file__).parent / "pre-commit.sh", pre_commit_path)
    st = os.stat(pre_commit_path)
    pre_commit_path.chmod(st.st_mode | stat.S_IEXEC)


if __name__ == "__main__":
    parser = ArgumentParser(
        "Install an extra pre-commit git hook that prevents text from being present"
    )
    parser.add_argument("marker")
    args = parser.parse_args()
    install(args.marker)
