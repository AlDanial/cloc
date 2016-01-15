# pod2man.mk -- Makefile portion to convert *.pod files to manual pages
#
#   Copyright information
#
#	Copyright (C) 2008-2012 Jari Aalto
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
#
#   Description
#
#	Convert *.pod files to manual pages. Add this to Makefile:
#
#	    PACKAGE = package
#
#	    man:
#		    make -f pod2man.mk PACKAGE=$(PACKAGE) makeman
#
#	    build: man

ifneq (,)
    This makefile requires GNU Make.
endif

# This variable *must* be set when called
PACKAGE		?= package

# Optional variables to set
MANSECT		?= 1
PODCENTER	?= User Commands
PODDATE		?= $$(date "+%Y-%m-%d")

# Directories
MANSRC		?=
MANDEST		?= $(MANSRC)

MANPOD		?= $(MANSRC)$(PACKAGE).$(MANSECT).pod
MANPAGE		?= $(MANDEST)$(PACKAGE).$(MANSECT)

POD2MAN		?= pod2man
POD2MAN_FLAGS	?= --utf8

makeman: $(MANPAGE)

$(MANPAGE): $(MANPOD)
	# make target - create manual page from a *.pod page
	podchecker $(MANPOD)
	LC_ALL= LANG=C $(POD2MAN) $(POD2MAN_FLAGS) \
		--center="$(PODCENTER)" \
		--date="$(PODDATE)" \
		--name="$(PACKAGE)" \
		--section="$(MANSECT)" \
		$(MANPOD) \
	| sed 's,[Pp]erl v[0-9.]\+,$(PACKAGE),' \
	  > $(MANPAGE) && \
	rm -f pod*.tmp

# End of of Makefile part
