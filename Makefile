PREFIX ?= /usr/local
BINDIR = $(PREFIX)/bin
DATADIR = $(PREFIX)/share
SYSCONFDIR ?= /etc

.PHONY: build install uninstall

build:
	cargo build --release

install:
	install -Dm755 target/release/driftwm $(DESTDIR)$(BINDIR)/driftwm
	install -Dm755 resources/driftwm-session $(DESTDIR)$(BINDIR)/driftwm-session
	install -Dm644 resources/driftwm.desktop $(DESTDIR)$(DATADIR)/wayland-sessions/driftwm.desktop
	install -Dm644 resources/driftwm-portals.conf $(DESTDIR)$(DATADIR)/xdg-desktop-portal/driftwm-portals.conf
	rm -f $(DESTDIR)$(SYSCONFDIR)/driftwm/config.toml
	install -Dm644 config.reference.toml $(DESTDIR)$(SYSCONFDIR)/driftwm/config.reference.toml
	for f in extras/wallpapers/*.glsl extras/wallpapers/*/*.glsl; do \
		[ -e "$$f" ] || continue; \
		rel=$${f#extras/wallpapers/}; \
		install -Dm644 "$$f" "$(DESTDIR)$(DATADIR)/driftwm/wallpapers/$$rel"; \
	done

uninstall:
	rm -f $(DESTDIR)$(BINDIR)/driftwm
	rm -f $(DESTDIR)$(BINDIR)/driftwm-session
	rm -f $(DESTDIR)$(DATADIR)/wayland-sessions/driftwm.desktop
	rm -f $(DESTDIR)$(DATADIR)/xdg-desktop-portal/driftwm-portals.conf
	rm -rf $(DESTDIR)$(DATADIR)/driftwm
	rm -rf $(DESTDIR)$(SYSCONFDIR)/driftwm
