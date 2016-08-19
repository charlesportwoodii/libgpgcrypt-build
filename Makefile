SHELL := /bin/bash

# Dependency Versions
VERSION?=1.7.3
RELEASEVER?=1

# Bash data
SCRIPTPATH=$(shell pwd -P)
CORES=$(shell grep -c ^processor /proc/cpuinfo)
RELEASE=$(shell lsb_release --codename | cut -f2)

major=$(shell echo $(VERSION) | cut -d. -f1)
minor=$(shell echo $(VERSION) | cut -d. -f2)
micro=$(shell echo $(VERSION) | cut -d. -f3)

build: clean libgpgcrypt

clean:
	rm -rf /tmp/libgcrypt-$(VERSION).tar.bz2
	rm -rf /libgcrypt$(VERSION)

libgpgcrypt:
	cd /tmp && \
	wget ftp://ftp.gnupg.org/gcrypt/libgcrypt/libgcrypt-$(VERSION).tar.bz2 && \
	tar -xf libgcrypt-$(VERSION).tar.bz2 && \
	cd libgcrypt-$(VERSION) && \
	mkdir -p /usr/share/man/libgcrypt-$(VERSION)  && \
	./configure \
	    --prefix=/usr/local \
	    --mandir=/usr/share/man/libgcrypt-$(VERSION) \
	    --infodir=/usr/share/info/libgcrypt-$(VERSION) \
	    --docdir=/usr/share/doc/libgcrypt-$(VERSION) && \
	make -j$(CORES) && \
	make install

package:
	cd /tmp/libgcrypt-$(VERSION) && \
	checkinstall \
	    -D \
	    --fstrans \
	    -pkgrelease "$(RELEASEVER)"-"$(RELEASE)" \
	    -pkgrelease "$(RELEASEVER)"~"$(RELEASE)" \
	    -pkgname "libgcrypt" \
	    -pkglicense GPLv3 \
	    -pkggroup GPG \
	    -maintainer charlesportwoodii@ethreal.net \
	    -provides "libgcrypt-$(VERSION)" \
	    -pakdir /tmp \
	    -y
