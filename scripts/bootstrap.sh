#!/usr/bin/env bash
set -euo pipefail

function red() {
	echo -e "\x1B[31m[!] $1 \x1B[0m"
	if [ -n "${2-}" ]; then
		echo -e "\x1B[31m[!] $($2) \x1B[0m"
	fi
}

function green() {
	echo -e "\x1B[32m[+] $1 \x1B[0m"
	if [ -n "${2-}" ]; then
		echo -e "\x1B[32m[+] $($2) \x1B[0m"
	fi
}

function blue() {
	echo -e "\x1B[34m[*] $1 \x1B[0m"
	if [ -n "${2-}" ]; then
		echo -e "\x1B[34m[*] $($2) \x1B[0m"
	fi
}

function yellow() {
	echo -e "\x1B[33m[*] $1 \x1B[0m"
	if [ -n "${2-}" ]; then
		echo -e "\x1B[33m[*] $($2) \x1B[0m"
	fi
}

host=corona
hostdir=./hosts/corona
secureboottag=secureboot-$host

blue "Generating Secureboot keys for ${host}"

mkdir -p $hostdir/secureboot/factory
for key_type in PK KEK db dbx; do
  file=$hostdir/secureboot/factory/${key_type}.esl
  if ! test -f  $file; then
    green "Copying factory $key_type for $host"
    efi-readvar -v $key_type -o $file > /dev/null
    git add $file
  else
    green "Factory $key_type exists for $host"
  fi
done

agenix generate -a -t "$secureboottag" 2>/dev/null 
