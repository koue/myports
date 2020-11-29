#! /bin/sh

# MAINTAINER: portmgr@FreeBSD.org
# $FreeBSD: head/Mk/Scripts/ports_env.sh 554142 2020-11-05 16:51:30Z mat $

if [ -z "${SCRIPTSDIR}" ]; then
	echo "Must set SCRIPTSDIR" >&2
	exit 1
fi

. ${SCRIPTSDIR}/functions.sh

export_ports_env
