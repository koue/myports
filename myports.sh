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
    echo "poudriere is missing. Install poudriere."
    exit 1
fi

if [ ! -d "${POUDRIERE}/jails/${MYNAME}" ]
then
    if [ -z "${1}" ] || [ "${1}" != "init" ]
    then
        echo "${MYNAME} jail is missing. Run [${0} init]."
        exit 1
    fi
fi

### functions
_usage() {
	echo "${0}: [init|sync|diff|build]"
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

_diff() {
    # show if diffs exist between myports and current ports tree
    for DIR in `find ports/ -type d -depth 2 -name "[a-z]*"`
    do
        # highly likely the following ports differ
        # skip them once changes are approved
        #case "${DIR}" in
        #    "ports/devel/libevent") continue;;
        #    "ports/www/rssroll") continue;;
        #    "ports/www/obhttpd") continue;;
        #    "ports/www/slowcgi") continue;;
        #    "ports/sysutils/graffer") continue;;
        #esac
	diff -rupN "${DIR}/" "/usr/${DIR}/"
    done
}

_build() {
    if [ "`poudriere ports -l | grep "${MYNAME}"`" ]
    then
        poudriere ports -d -p ${MYNAME}
    fi
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
    "diff") _diff;;
    "build") _build;;
esac
