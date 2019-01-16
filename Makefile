SCRIPT  = mondo
MANPAGE = $(SCRIPT).1
LINKDIR = 
PREFIX  = /usr
DESTDIR =
INSTDIR = $(DESTDIR)$(PREFIX)
INSTBIN = $(INSTDIR)/bin
INSTMAN = $(INSTDIR)/share/man/man1

install:
	test -d $(INSTDIR) || mkdir -p $(INSTDIR)
	test -d $(INSTBIN) || mkdir -p $(INSTBIN)
	test -d $(INSTMAN) || mkdir -p $(INSTMAN)

	install -m 0755 program.sh $(INSTBIN)/$(SCRIPT)
	install -m 0644 $(MANPAGE) $(INSTMAN)
.PHONY: install


uninstall:
	$(RM) $(INSTBIN)/$(SCRIPT)
	$(RM) $(INSTMAN)/$(MANPAGE)
.PHONY: uninstall
