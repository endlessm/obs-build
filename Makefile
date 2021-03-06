VERSION=0.1
SCM=$(shell if test -d .svn; then echo svn; elif test -d .git; then echo git; fi)
DATE=$(shell date +%Y%m%d%H%M)
BUILD=obs-build

INITVM_ARCH=$(shell bash -c '. common_functions ; build_host_arch; echo $$BUILD_INITVM_ARCH')

ifeq ($(SCM),svn)
SVNVER=_SVN$(shell LANG=C svnversion .)
endif

prefix=/usr
bindir=$(prefix)/bin
datadir=$(prefix)/share
libdir=$(prefix)/lib
pkglibdir=$(libdir)/$(BUILD)
mandir=$(datadir)/man
man1dir=$(mandir)/man1
sysconfdir=/etc
DESTDIR=

all:

.PHONY:	test

test:
	PERL5LIB=. prove -v

install:
	install -m755 -d \
	    $(DESTDIR)$(pkglibdir)/configs \
	    $(DESTDIR)$(pkglibdir)/baselibs_configs \
	    $(DESTDIR)$(pkglibdir)/Build \
	    $(DESTDIR)$(pkglibdir)/emulator \
	    $(DESTDIR)$(bindir) \
	    $(DESTDIR)$(man1dir)
	install -m755 \
	    build \
	    vc \
	    createdirdeps \
	    order \
	    expanddeps \
	    computeblocklists \
	    extractbuild \
	    getbinaryid \
	    getbuildids \
	    killchroot \
	    queryconfig \
	    common_functions \
	    init_buildsystem \
	    substitutedeps \
	    debtransform \
	    debtransformbz2 \
	    debtransformxz \
	    debtransformzip \
	    mkbaselibs \
	    mkdrpms \
	    listinstalled \
	    createzyppdeps \
	    createarchdeps \
	    createdebdeps \
	    createrepomddeps \
	    createyastdeps \
	    changelog2spec \
	    spec2changelog \
	    download \
	    runservices \
	    spec_add_patch \
	    spectool \
	    signdummy \
	    unrpm \
	    telnet_login_wrapper \
	    build-validate-params \
	    openstack-console \
	    startdockerd \
	    dummyhttpserver \
	    obs-docker-support \
	    $(DESTDIR)$(pkglibdir)
	install -m755 emulator/emulator.sh $(DESTDIR)$(pkglibdir)/emulator/
	install -m644 Build/*.pm $(DESTDIR)$(pkglibdir)/Build
	install -m644 qemu-reg $(DESTDIR)$(pkglibdir)
	install -m644 build-vm build-vm-* $(DESTDIR)$(pkglibdir)
	install -m644 build-recipe build-recipe-* $(DESTDIR)$(pkglibdir)
	install -m644 build-pkg build-pkg-* $(DESTDIR)$(pkglibdir)
	install -m644 *.pm lxc.conf $(DESTDIR)$(pkglibdir)
	install -m644 obs-debootstrap-script $(DESTDIR)$(pkglibdir)
	install -m644 configs/* $(DESTDIR)$(pkglibdir)/configs
	install -m644 baselibs_configs/* $(DESTDIR)$(pkglibdir)/baselibs_configs
	install -d $(DESTDIR)$(man1dir)
	install -T -m644 build.1 $(DESTDIR)$(man1dir)/obs-build.1
	install -T -m644 vc.1 $(DESTDIR)$(man1dir)/obs-buildvc.1
	install -T -m644 unrpm.1 $(DESTDIR)$(man1dir)/unrpm.1
	ln -sf $(pkglibdir)/build $(DESTDIR)$(bindir)/obs-build
	ln -sf $(pkglibdir)/vc    $(DESTDIR)$(bindir)/obs-buildvc
	ln -sf $(pkglibdir)/unrpm $(DESTDIR)$(bindir)/unrpm
	ln -s baselibs_configs/baselibs_global.conf $(DESTDIR)$(pkglibdir)/baselibs_global.conf
	ln -s baselibs_configs/baselibs_global-deb.conf $(DESTDIR)$(pkglibdir)/baselibs_global-deb.conf

# Allow initvm to be packaged seperately from the rest of build.  This
# is useful because it is distributed as a static binary package (e.g.
# build-initvm-static) whereas the build scripts package is noarch.

initvm: initvm.c
	$(CC) -o $@.$(INITVM_ARCH) -static $(CFLAGS) initvm.c

initvm-all: initvm

initvm-build: initvm

initvm-install: initvm
	install -m755 -d $(DESTDIR)$(pkglibdir)
	install -m755 initvm.$(INITVM_ARCH) $(DESTDIR)$(pkglibdir)/initvm.$(INITVM_ARCH)


dist:
ifeq ($(SCM),svn)
	rm -rf $(BUILD)-$(VERSION)$(SVNVER)
	svn export . $(BUILD)-$(VERSION)$(SVNVER)
	tar --force-local -cjf $(BUILD)-$(VERSION)$(SVNVER).tar.bz2 $(BUILD)-$(VERSION)$(SVNVER)
	rm -rf $(BUILD)-$(VERSION)$(SVNVER)
else
ifeq ($(SCM),git)
	git archive --prefix=$(BUILD)-$(VERSION)_git$(DATE)/ HEAD| bzip2 > $(BUILD)-$(VERSION)_git$(DATE).tar.bz2
endif
endif
