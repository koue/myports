#! /bin/sh

# MAINTAINER: portmgr@FreeBSD.org
# $FreeBSD: head/Mk/Scripts/ports_env.sh 554893 2020-11-11 13:29:52Z mat $

set -o pipefail

if [ -z "${SCRIPTSDIR}" ]; then
	echo "Must set SCRIPTSDIR" >&2
	exit 1
fi

. ${SCRIPTSDIR}/functions.sh

export_ports_env
