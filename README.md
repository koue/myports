# myports

My collection of FreeBSD ports

```
$ git clone https://github.com/koue/myports && cd myports
$ ./myports.sh init
$ ./myports.sh build
```

Modify options
```
$ cd ports/mail/cclient
$ make config
$ cp -rv /var/db/ports/mail_cclient options/
```

Enable pkg repository
```
$ cp etc/chaosophia.conf /usr/local/etc/pkg/repos/
```
