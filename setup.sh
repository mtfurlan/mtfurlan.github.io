#!/usr/bin/env bash
# script to assist setting up new computers

# curl -s https://technicallycompetent.com/setup.sh | bash

echo "hi!"
exit 0
git clone https://github.com/mtfurlan/dotfiles.git ~/.dotfiles
cd ~/.dotfiles || (echo >&2 "failed to clione?"; exit 1)
./setup.sh -n
