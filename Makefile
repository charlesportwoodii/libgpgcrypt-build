SHELL := /bin/bash

# Dependency Versions
VERSION?=1.7.6
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

fpm_debian:
	echo "Packaging libgcrypt for Debian"

	cd /tmp/libgcrypt-$(VERSION) && make install DESTDIR=/tmp/libgcrypt-$(VERSION)-install

	fpm -s dir \
		-t deb \
		-n libgcrypt \
		-v $(VERSION)-$(RELEASEVER)~$(shell lsb_release --codename | cut -f2) \
		-C /tmp/libgcrypt-$(VERSION)-install \
		-p libgcrypt_$(VERSION)-$(RELEASEVER)~$(shell lsb_release --codename | cut -f2)_$(shell arch).deb \
		-m "charlesportwoodii@erianna.com" \
		--license "GPLv3" \
		--url https://github.com/charlesportwoodii/libgcrypt-build \
		--description "libgcrypt" \
		--deb-systemd-restart-after-upgrade

fpm_rpm:
	echo "Packaging libgcrypt for RPM"

	cd /tmp/libgcrypt-$(VERSION) && make install DESTDIR=/tmp/libgcrypt-$(VERSION)-install

	fpm -s dir \
		-t rpm \
		-n libgcrypt \
		-v $(VERSION)_$(RELEASEVER) \
		-C /tmp/libgcrypt-$(VERSION)-install \
		-p libgcrypt_$(VERSION)-$(RELEASEVER)_$(shell arch).rpm \
		-m "charlesportwoodii@erianna.com" \
		--license "GPLv3" \
		--url https://github.com/charlesportwoodii/libgcrypt-build \
		--description "libgcrypt" \
		--vendor "Charles R. Portwood II" \
		--rpm-digest sha384 \
		--rpm-compression gzip
