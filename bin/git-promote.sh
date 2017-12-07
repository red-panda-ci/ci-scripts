#!/bin/bash
# POSIX

# Credits
# - Forked from soulrebel git-promote gist https://gist.github.com/soulrebel/9c47ee936cfce9dcb725
# - Parse arguments howto http://mywiki.wooledge.org/BashFAQ/035

git_promote="$(basename "$0" | sed -e 's/-/ /')"
HELP="Usage: $git_promote [options...] [upstream] <downstream>

Promote an \"upstream\" Git branch by merging it into a \"downstream\" branch.

When omitted, the currently checked out branch is used as upstream.

Options:
  -m <message>                # merge commit message, asked otherwise
  --dry-run                   # echo git commands, do not execute them
  --nopull                    # do not pull from remote
  --nopush                    # do not push from remote
  --no-edit                   # use --no-edit in the merge
  --local                     # same as --nopull and --nopush
  --help                      # prints this

Examples:
  $git_promote quality        # promotes current branch to \"quality\"
  $git_promote quality master # promotes \"quality\" branch to \"master\"
"
# to install copy to /usr/local/bin and
# sudo chmod +x /usr/local/bin/git-promote
# to install man page so that git(no dash)promote --help works:
# mkdir -p /usr/local/man/man1
# git-promote --help | txt2man -t git-promote | gzip | sudo tee /usr/local/man/man1/git-promote.1.gz >/dev/null

git='git'
pull_upstream='y'
pull_downstream='y'
push='y'
no_edit=''
commit_message=''

while :; do
  case $1 in
    -m|--message)
      shift
      commit_message="$1"
      ;;
    --dry-run)
      git="echo git"
      ;;
    --no-edit)
      no_edit='--no-edit'
      ;;
    --nopull)
      pull_upstream='n'
      pull_downstream='n'
      ;;
    --nopush)
      push='n'
      ;;
    --local)
      pull_upstream='n'
      pull_downstream='n'
      push='n'
      ;;
    -h|\?|--help)
      echo "$HELP"
      exit 0
      ;;
    --)              # End of all options.
      shift
      break
      ;;
    -?*)
      printf 'WARN: Unknown option: %s\n' "$1" >&2
      echo "$HELP"
      exit 1
      ;;
    *)  # Default case: If no more options then break out of the loop.
      break
  esac
  shift
done

current="$(git branch | awk '/^[*]/{print $2;}')"
if [ "$current" == "(HEAD" ]
then
  current="$(git rev-parse HEAD)"
fi

case "$#" in
  1)
    upstream="$current"
    downstream="$1"
    ;;
  2)
    upstream="$1"
    downstream="$2"
    ;;
  *)
    echo "$HELP" >&2
    exit 1
    ;;
esac

if [ "$commit_message" == "" ]
then
  $commit_message="Merge from $upstream"
fi

if [ -z "$current" ]; then
  exit 1
fi

function fail {
  $git checkout "$current" 2>/dev/null || true
  exit 1
}

trap 'fail' ERR INT TERM

if [ "$upstream" != "$current" ]; then
  $git checkout "$upstream"
else
  echo "Promoting $upstream to $downstream"
fi

if [ "$pull_upstream" == 'y' ]; then
  $git pull --ff-only
fi

$git checkout "$downstream"

if [ "$pull_downstream" == 'y' ]; then
  $git pull --ff-only
fi

if [ "$git" == "echo git" ]
then
  commit_message="\"$commit_message\""
fi

$git merge --no-ff $no_edit -m "$commit_message" "$upstream"

if [ "$push" == 'y' ]; then
  $git push
fi

$git checkout "$current"

exit 0

# vim: set expandtab ts=2 sw=2