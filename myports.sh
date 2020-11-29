#!/bin/sh
set -ex

###
PORTS=/usr/ports
POUDRIERE=/usr/local/poudriere
MYNAME=myports
MYRELEASE=11.4-RELEASE
MYARCH=amd64

###
if [ ! `which poudriere` ]
then
    echo "poudriere is missing."
    exit 1
fi

if [ ! -d "${POUDRIERE}/jails/${MYNAME}" ]
then
    echo "${MYNAME} jail is missing."
    exit 1
fi

### functions
_usage() {
	echo "${0}: [init|sync|build]"
}

_init() {
    poudriere jail -c -j ${MYNAME} -v ${MYRELEASE} -a ${MYARCH}
}

_sync() {
    rm -rf ports/Mk
    cp -r ${PORTS}/Mk ports/
    # no python
    rm ports/Mk/Uses/python.mk
    rm -rf ports/Templates
    cp -r ${PORTS}/Templates ports/
    rm -rf ports/Keywords
    cp -r ${PORTS}/Keywords ports/
    cp ${PORTS}/GIDs ports/
    cp ${PORTS}/UIDs ports/
}

_build() {
    poudriere ports -d -p ${MYNAME}
    poudriere ports -c -p ${MYNAME} -F

    cp -r ports/* ${POUDRIERE}/ports/${MYNAME}/

    ###
    # cd ports/mail/cclient && make config
    # cp -rv /var/db/ports/mail_cclient options/
    ###
    rm -rf /usr/local/etc/poudriere.d/${MYNAME}-options
    mkdir -p /usr/local/etc/poudriere.d/${MYNAME}-options
    cp -r options/* /usr/local/etc/poudriere.d/${MYNAME}-options/

    ###
    find ports/[a-z]* -type d -depth 1 | cut -d '/' -f2- > BUILD
    poudriere bulk -t -f BUILD -j ${MYNAME} -p ${MYNAME}
    rm BUILD
}

### start
if [ -z "${1}" ]; then
    _usage
    exit 1
fi

case "${1}" in
    "init") _init;;
    "sync") _sync;;
    "build") _build;;
esac
