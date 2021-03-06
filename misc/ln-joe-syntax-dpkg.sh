#!/bin/bash

set -e

SRC=`pwd`
DST="/usr/share/joe/syntax"
#DEBUG="echo SH:"

if [ "$UID" -ne 0 ]; then
	echo "You should run this as root or you may not have suitable rights to modify $DST."
	echo "If this is incorrect plz modify this script. Exit."
	exit 1
fi

if [ ! -e $DST ]; then
	echo "The destination directory for JOEs syntax files does not exist: $DST"
	echo "Note that the default location is correct on Debian systems so plz modify this script for your system."
	exit 1
fi

echo "This script will replace all *.jsf files from $DST (the 'originals')"
echo "which exist in $SRC (the 'improved') too after backing them up"
echo "with symlinks pointing to $SRC/<file> if not already done so."
echo

read -p "Do you want to continue? (y/n): " answer

if [ "$answer" != "y" ]; then
	echo "You did not answer exactly with 'y', abort."
	exit 2
fi

find $SRC -name "*.jsf" | while read file_src; do
	name=`basename $file_src`
	file_dst="$DST/$name"
	echo -n "$name: "
	
	if [ -h $file_dst ]; then
		echo "is already a symlink, delete."
		rm $file_dst
	fi
	if [ -e $file_dst ]; then
		echo -n "backup to $file_dst.orig, "
		#$DEBUG mv $file_dst "$file_dst.orig"
		$DEBUG dpkg-divert --add --rename --divert "$file_dst.orig" "$file_dst"
	fi
	echo "create symlink."
	$DEBUG ln -s $file_src $file_dst
done
