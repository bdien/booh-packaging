#!/bin/sh

git log > ChangeLog
version=`cat VERSION`
file="/tmp/booh-$version.tar.bz2"
tar --transform="s||booh-$version/|" --exclude=www -jcvf $file *
echo
echo "Built $file"
