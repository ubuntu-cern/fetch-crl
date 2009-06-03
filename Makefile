# Steve Traylen , 10th June 2002 <s.m.traylen@rl.ac.uk>
# Makefile for building rpms and tar balls.
#

NAME=$(shell echo *.spec | sed 's/\.spec//')
VERSION=$(shell egrep '^Version:' ${NAME}.spec | colrm 1 9)
RELEASE=${NAME}-${VERSION}
PATCHLEVEL=$(shell egrep '^Release:' ${NAME}.spec | colrm 1 9)
RPMTOPDIR=$(shell rpm --eval '%_topdir')
PREFIX=/usr
ETC=/etc
FILES=edg-fetch-crl fetch-crl.8 fetch-crl.cron fetch-crl.sysconfig README CHANGES fetch-crl.spec Makefile

all:	configure

tar:    clean configure
	-rm -rf /var/tmp/${RELEASE}
	-rm -rf /var/tmp/${RELEASE}-buildroot
	-mkdir /var/tmp/${RELEASE}
	cp -r ${FILES} /var/tmp/${RELEASE}
	cd /var/tmp/ ; tar  cvfz ${RELEASE}.tar.gz --exclude=CVS \
                    --exclude='*~' --exclude='#*#' --exclude='20*' ${RELEASE}  
	cp /var/tmp/${RELEASE}.tar.gz .

#####################################################################
# Create substitution script
####################################################################
#
# This target reads the config file and creates a shell script which
# can substitute variables of the form @VAR@ for all config
# variables VAR. The messing around with the temporary makefile is
# to ensure that any recursive or external references in the
# variable values are evaluated by "make" in the same context as
# when the config file is included in the makefile.

config.sh: Makefile $(_test_dep) config.mk
	@cp /dev/null makefile.tmp
	@echo include config.mk >>makefile.tmp
	@echo dumpvars: >>makefile.tmp
	@cat config.mk | \
	 perl >>makefile.tmp -e ' \
	  my $$fmt = "\t\@echo \"-e \\\"s\@%s\@\$$(%s)g\\\" \\\\\"" ; \
	  while (<>) { $$v{$$1}=1 if /^([A-Za-z0-9_]+)\s*:?=.*$$/; } \
	  map { printf "$$fmt >>config.sh\n", $$_, $$_; } sort(keys(%v)); \
	  print "\n"; \
	 '
	@echo '#!/bin/sh' >config.sh
	@echo 'sed \' >>config.sh
	@$(MAKE) -f makefile.tmp dumpvars >/dev/null
	@echo ' -e "s/\@MSG\@/ ** Generated file : do not edit **/"'>>config.sh
	@chmod oug+x config.sh
	@rm makefile.tmp

####################################################################
# Configure
####################################################################

%:: %.cin config.sh
	@echo configuring $@ ...
	@rm -f $@ ; cp $< $@
	@./config.sh <$< >$@ ; chmod oug-w $@

%.$(MANSECT):: %.$(MANSECT).man.cin
	@echo creating $@ ...
	@./config.sh <$< >$@ ; chmod oug-w $@

configure: $(shell find . -name \*\.cin 2>/dev/null | sed -e 's/.cin//' || echo)

install: configure
	install -m755 -D edg-fetch-crl    $(PREFIX)/sbin/fetch-crl
	install -m755 -D fetch-crl.cron   $(PREFIX)/share/doc/$(RELEASE)/fetch-crl.cron
	install -m644 -D fetch-crl.8      $(PREFIX)/share/man/man8/fetch-crl.8
	install -m644 fetch-crl.sysconfig $(PREFIX)/share/doc/$(RELEASE)/fetch-crl.sysconfig
	install -m644 -D fetch-crl.sysconfig $(ETC)/sysconfig/fetch-crl
	install -m644 README              $(PREFIX)/share/doc/$(RELEASE)/README
	install -m644 CHANGES             $(PREFIX)/share/doc/$(RELEASE)/CHANGES


rpm: tar
	rpmbuild -ta ${RELEASE}.tar.gz
	@if [ -f ${RPMTOPDIR}/SRPMS/${NAME}-${VERSION}-${PATCHLEVEL}.src.rpm ] ; then \
	  mv ${RPMTOPDIR}/SRPMS/${NAME}*-${VERSION}-${PATCHLEVEL}.src.rpm . ;  \
	fi
	@if [ -f ${RPMTOPDIR}/RPMS/i386/${NAME}-${VERSION}-${PATCHLEVEL}.i386.rpm ] ; then \
	  mv ${RPMTOPDIR}/RPMS/i386/${NAME}*-${VERSION}-${PATCHLEVEL}.i386.rpm . ;  \
	fi
	@if [ -f ${RPMTOPDIR}/RPMS/i686/${NAME}-${VERSION}-${PATCHLEVEL}.i686.rpm ] ; then \
	  mv ${RPMTOPDIR}/RPMS/i686/${NAME}*-${VERSION}-${PATCHLEVEL}.i686.rpm . ;  \
	fi
	@if [ -f ${RPMTOPDIR}/RPMS/noarch/${NAME}-${VERSION}-${PATCHLEVEL}.noarch.rpm ] ; then \
	  mv ${RPMTOPDIR}/RPMS/noarch/${NAME}*-${VERSION}-${PATCHLEVEL}.noarch.rpm . ;  \
	fi

clean:
	-rm -rf *.tar.gz
	-rm -rf *.rpm
	-rm -f edg-fetch-crl config.sh fetch-crl.spec

