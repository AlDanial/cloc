#!/usr/bin/make -f
#
#   Copyright information
#
#	Copyright (C) 2012 Jari Aalto
#
#   License
#
#	This program is free software; you can redistribute it and/or modify
#	it under the terms of the GNU General Public License as published by
#	the Free Software Foundation; either version 2 of the License, or
#	(at your option) any later version.
#
#	This program is distributed in the hope that it will be useful,
#	but WITHOUT ANY WARRANTY; without even the implied warranty of
#	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
#	GNU General Public License for more details.
#
#	You should have received a copy of the GNU General Public License
#	along with this program. If not, see <http://www.gnu.org/licenses/>.

ifneq (,)
This makefile requires GNU Make.
endif

PACKAGE		= cloc

DESTDIR		=
prefix		= /usr
exec_prefix	= $(prefix)
man_prefix	= $(prefix)/share
mandir		= $(man_prefix)/man
bindir		= $(exec_prefix)/bin
sharedir	= $(prefix)/share

BINDIR		= $(DESTDIR)$(bindir)
DOCDIR		= $(DESTDIR)$(sharedir)/doc
LOCALEDIR	= $(DESTDIR)$(sharedir)/locale
SHAREDIR	= $(DESTDIR)$(sharedir)/$(PACKAGE)
LIBDIR		= $(DESTDIR)$(prefix)/lib/$(PACKAGE)
SBINDIR		= $(DESTDIR)$(exec_prefix)/sbin
ETCDIR		= $(DESTDIR)/etc/$(PACKAGE)

# 1 = regular, 5 = conf, 6 = games, 8 = daemons
MANDIR		= $(DESTDIR)$(mandir)
MANDIR1		= $(MANDIR)/man1
MANDIR5		= $(MANDIR)/man5
MANDIR6		= $(MANDIR)/man6
MANDIR8		= $(MANDIR)/man8

BIN		= $(PACKAGE)
PL_SCRIPT	= $(BIN)

INSTALL_OBJS_BIN = $(PL_SCRIPT)
INSTALL_OBJS_MAN = *.1

INSTALL		= /usr/bin/install
INSTALL_BIN	= $(INSTALL) -m 755
INSTALL_DATA	= $(INSTALL) -m 644

all: man
	@echo "Nothing to compile for a Perl script."
	@echo "Try 'make help' or 'make -n DESTDIR= prefix=/usr/local install'"

# Rule: help - display Makefile rules
help:
	@grep "^# Rule:" Makefile | sort

# Rule: clean - remove temporary files
clean:
	# clean
	rm -f *[#~] *.\#* *.x~~ pod*.tmp *.1
	rm -rf tmp

distclean: clean

realclean: clean

# Rule: man - Generate or update manual page
man:
	make -f pod2man.mk PACKAGE=$(PACKAGE) makeman

# Rule: doc - Generate or update all documentation
doc: man

# Rule: test-perl - Check program syntax
test-perl:
	# perl-test - Check syntax
	perl -cw $(PL_SCRIPT)

# Rule: test-pod - Check POD syntax
test-pod:
	podchecker *.pod

# Rule: test - Run tests
test: test-perl test-pod

install-man: test-pod man
	# install-man
	$(INSTALL_BIN) -d $(MANDIR1)
	$(INSTALL_DATA) $(INSTALL_OBJS_MAN) $(MANDIR1)

install-bin: test-perl
	# install-bin - Install programs
	$(INSTALL_BIN) -d $(BINDIR)
	for f in $(INSTALL_OBJS_BIN); \
	do \
		dest=$${f%.pl}; \
		$(INSTALL_BIN) $$f $(BINDIR)/$$dest; \
	done

# Rule: install - Standard install
install: install-bin install-man

# Rule: install-test - for Maintainer only
install-test:
	rm -rf tmp
	make DESTDIR=$$(pwd)/tmp prefix=/usr install
	find tmp | sort

# Rule: dist - for Maintainer only, make distribution
dist: clean
	[ -f version ] || fail-version-file-is-missing

	release=$(PACKAGE)-$$(cat version); \
	rm -rf /tmp/$$release ; \
	mkdir -vp /tmp/$$release ; \
	cp -rav . /tmp/$$release/ ; \
    find /tmp/$$release/ -type d \
      \( -name .svn -o -name .git -o -name .hg \) | xargs -r rm -r; \
	tar -C /tmp -zvcf /tmp/$$release.tar.gz $$release ; \
	echo "DONE: /tmp/$$release.tag.gz"

.PHONY: clean distclean realclean install install-bin install-man

# End of file
