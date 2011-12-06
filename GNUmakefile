DOC_DIR=inst/doc/
PACKAGE=Rcompression
# philosophy.pdf
#DOC_FILES=$(DOCS:%=$(DOC_DIR)/%)

VERSION=$(shell perl -e 'while(<>) { if(m/Version: (.*)/) {print $$1,"\n";}}' DESCRIPTION)

configure: configure.in
	autoconf

build: configure $(DOC_FILES)
	(cd ..  ; R CMD build $(PACKAGE) )


ship: build
	scp ../$(PACKAGE)_$(VERSION).tar.gz www.omegahat.org:/home3/WebSites/Omega/$(PACKAGE)/


version:
	@echo "$(VERSION)"



docs: $(DOC_FILES)

check: configure
	R CMD check .

install: configure
	R CMD INSTALL .


$(DOC_DIR)/philosophy.html: $(DOC_DIR)/philosophy.xml

%.html: %.xml
	$(MAKE) -C $(@D) $(@F)

