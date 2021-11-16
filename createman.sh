#! /usr/bin/env bash
echo "gzip-ing $1 to $1.gz\n"
gzip -k $1

echo "Moving $1.gz to /usr/share/man/man$2..."

sudo cp "$1.gz" "/usr/share/man/man$2"
