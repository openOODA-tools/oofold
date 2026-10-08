# ==============================================================================
# oofold: Width-aware text line folder breaking on word boundaries and ANSI codes.
# Verification and Lifecycle Makefile
# ==============================================================================

SHELL := /bin/bash
BIN := dist/oofold
SRC := $(shell find . -name "*.oo" -o -name "*.oot" 2>/dev/null)
VERSION := $(shell cat VERSION 2>/dev/null || echo "0.2.0")
OODA_COMPILER ?= /home/ubermetroid/.openooda/bin/oodac
OODACODEX ?= /home/ubermetroid/.openooda/northstar.oot
OO_LIST_AMBIENT_QUOTA ?= 8589934592

.PHONY: all verify build test package clean check line-cap file-law academy density package-deb package-rpm package-arch

all: verify build test

$(BIN): $(SRC)
	@mkdir -p dist
	OO_LIST_AMBIENT_QUOTA=$(OO_LIST_AMBIENT_QUOTA) \
	OODACODEX=$(OODACODEX) \
	OODA_COMPILER=$(OODA_COMPILER) \
	OODA_NO_JAIL=1 \
	$(OODA_COMPILER) build main.oo -o $(BIN)
	@cp $(BIN) dist/oofold-linux-x86_64
	@cd dist && sha256sum oofold-linux-x86_64 > oofold-linux-x86_64.sha256
	@echo "built $(BIN) (and dist/oofold-linux-x86_64)"

build: $(BIN)

line-cap:
	@violations=0; \
	for f in $$(find . -name "*.oo" -o -name "*.oot" | grep -v '\.git' | grep -v 'dist/'); do \
		lines=$$(wc -l < "$$f"); \
		if grep -q '^// # ' "$$f" && [ $$lines -lt 16 ]; then \
			echo "VIOLATION: $$f has $$lines lines (< 16 floor)"; violations=$$((violations+1)); \
		fi; \
		if [ $$lines -gt 256 ]; then \
			echo "VIOLATION: $$f has $$lines lines (> 256 cap)"; violations=$$((violations+1)); \
		fi; \
	done; \
	if [ $$violations -gt 0 ]; then echo "FAIL: $$violations files violate line bounds"; exit 1; fi; \
	echo "PASS: Page Rule sizing (16-256 lines, shims exempt from floor) holds"

file-law:
	@bad=$$(find . -name "*.oo" | grep -E '(utils?|helpers?|common|misc|shared|base)\.oo$$' | grep -v 'dist/' || true); \
	if [ -n "$$bad" ]; then \
		echo "VIOLATION: Generic drawer filenames detected:"; echo "$$bad"; exit 1; \
	fi; \
	echo "PASS: file law holds"

academy:
	@missing=0; \
	for f in $$(find . -name "*.oo" -not -path "./dist/*"); do \
		hdr=$$(head -n 7 "$$f"); \
		for elem in "// # " "// Logline:" "// Setup:" "// Beats:"; do \
			if ! echo "$$hdr" | grep -qF "$$elem"; then \
				echo "VIOLATION: $$f missing '$$elem' in first 7 lines"; missing=$$((missing+1)); \
			fi; \
		done; \
	done; \
	if [ $$missing -gt 0 ]; then echo "FAIL: $$missing missing Academy header elements"; exit 1; fi; \
	echo "PASS: academy headers hold (all 4 elements present in first 7 lines)"

density:
	@violations=0; \
	for d in $$(find . -maxdepth 3 -type d -not -path '*/.*' -not -path './dist*' -not -path './packaging*'); do \
		n=$$(ls "$$d"/*.oo "$$d"/*.oot 2>/dev/null | grep -v '\*' | wc -l); \
		if [ $$n -gt 8 ]; then \
			echo "VIOLATION: $$d holds $$n pages (exceeds 8)"; violations=$$((violations+1)); \
		fi; \
	done; \
	if [ $$violations -gt 0 ]; then echo "FAIL: $$violations directories exceed the density bound"; exit 1; fi; \
	echo "PASS: directory density (<= 8 pages per directory) holds"

check:
	@for f in $$(find . -name "*.oo" -not -path "./dist/*"); do \
		OO_LIST_AMBIENT_QUOTA=$(OO_LIST_AMBIENT_QUOTA) OODACODEX=$(OODACODEX) OODA_COMPILER=$(OODA_COMPILER) OODA_NO_JAIL=1 $(OODA_COMPILER) check "$$f" > /dev/null || exit 1; \
	done; \
	echo "PASS: oodac check holds on all .oo files"

verify: line-cap file-law academy density check

test: $(BIN)
	@echo "=== testing --help ==="
	@./$(BIN) --help | grep -q "oofold" && echo "PASS: --help"
	@echo "=== testing --version ==="
	@./$(BIN) --version | grep -q "oofold" && echo "PASS: --version"
	@echo "=== testing internal anchors ==="
	@./$(BIN) --test | grep -q "PASSED" && echo "PASS: internal anchors"
	@echo "=== testing basic fold with -w ==="
	@echo "1234567890abcdefghij" | ./$(BIN) -w 10 | grep -q "^1234567890$$" && echo "PASS: basic fold -w"
	@echo "=== testing numeric width shorthand ==="
	@echo "1234567890abcdefghij" | ./$(BIN) -10 | grep -q "^1234567890$$" && echo "PASS: numeric width shorthand -10"
	@echo "=== testing space break mode -s ==="
	@echo "quick brown fox jumps" | ./$(BIN) -s -w 12 | grep -q "quick brown" && echo "PASS: space break -s"
	@echo "=== testing byte mode -b ==="
	@echo "12345678abcdefgh" | ./$(BIN) -b -w 8 | grep -q "^12345678$$" && echo "PASS: byte mode -b"
	@echo "=== testing JSON mode -j ==="
	@echo "1234567890abcdefghij" | ./$(BIN) -j -w 10 | grep -q '"target_width": 10' && echo "PASS: JSON mode -j"
	@echo "=== testing showcase --demo -D ==="
	@./$(BIN) -D | grep -q "Showcase" && echo "PASS: --demo"
	@echo "=== testing MCP initialize ==="
	@printf '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{}}\n' | ./$(BIN) --mcp | grep -q "protocolVersion" && echo "PASS: MCP initialize"
	@echo "=== testing MCP tools/list ==="
	@printf '{"jsonrpc":"2.0","id":2,"method":"tools/list","params":{}}\n' | ./$(BIN) --mcp | grep -q "fold_wrap_text" && echo "PASS: MCP tools/list"
	@echo "=== testing MCP tools/call fold_wrap_text ==="
	@printf '{"jsonrpc":"2.0","id":3,"method":"tools/call","name":"fold_wrap_text","text":"1234567890abcdef","width":8}\n' | ./$(BIN) --mcp | grep -q "12345678" && echo "PASS: MCP fold_wrap_text"
	@echo "=== testing MCP tools/call fold_stream_lines ==="
	@printf '{"jsonrpc":"2.0","id":4,"method":"tools/call","name":"fold_stream_lines","text":"quick brown fox","width":10}\n' | ./$(BIN) --mcp | grep -q "folded_text" && echo "PASS: MCP fold_stream_lines"
	@echo "=== testing MCP tools/call fold_strip_ansi ==="
	@printf '{"jsonrpc":"2.0","id":5,"method":"tools/call","name":"fold_strip_ansi","text":"plain"}\n' | ./$(BIN) --mcp | grep -q "visual_width" && echo "PASS: MCP fold_strip_ansi"
	@echo "=== testing MCP tools/call fold_inspect_line_lengths ==="
	@printf '{"jsonrpc":"2.0","id":6,"method":"tools/call","name":"fold_inspect_line_lengths","text":"short","width":10}\n' | ./$(BIN) --mcp | grep -q "compliant" && echo "PASS: MCP fold_inspect_line_lengths"
	@echo "=== testing MCP tools/call fold_demo ==="
	@printf '{"jsonrpc":"2.0","id":7,"method":"tools/call","name":"fold_demo"}\n' | ./$(BIN) --mcp | grep -q "Showcase" && echo "PASS: MCP fold_demo"
	@echo "ALL TESTS PASSED"

package-deb: $(BIN)
	@mkdir -p dist/deb-root/DEBIAN dist/deb-root/usr/bin
	@sed "s/^Version:.*/Version: $(VERSION)-1/" packaging/debian/control.binary > dist/deb-root/DEBIAN/control
	@cp $(BIN) dist/deb-root/usr/bin/oofold
	@chmod 0755 dist/deb-root/usr/bin/oofold
	@cp uninstall.sh dist/deb-root/usr/bin/oofold-uninstall
	@chmod 0755 dist/deb-root/usr/bin/oofold-uninstall
	@dpkg-deb --build --root-owner-group dist/deb-root dist/oofold_$(VERSION)-1_amd64.deb
	@rm -rf dist/deb-root
	@echo "built dist/oofold_$(VERSION)-1_amd64.deb"

package-rpm: $(BIN)
	@mkdir -p ~/rpmbuild/SOURCES ~/rpmbuild/SPECS ~/rpmbuild/RPMS
	@cp $(BIN) ~/rpmbuild/SOURCES/oofold-linux-x86_64
	@cp uninstall.sh ~/rpmbuild/SOURCES/uninstall.sh
	@sed "s/^Version:.*/Version: $(VERSION)/" packaging/oofold.spec > ~/rpmbuild/SPECS/oofold.spec
	@rpmbuild -bb ~/rpmbuild/SPECS/oofold.spec
	@cp ~/rpmbuild/RPMS/x86_64/oofold-$(VERSION)*.rpm dist/
	@echo "built dist RPM package"

package-arch: $(BIN)
	@mkdir -p dist/arch-pkg/usr/bin
	@cp $(BIN) dist/arch-pkg/usr/bin/oofold
	@chmod 0755 dist/arch-pkg/usr/bin/oofold
	@cp uninstall.sh dist/arch-pkg/usr/bin/oofold-uninstall
	@chmod 0755 dist/arch-pkg/usr/bin/oofold-uninstall
	@printf "pkgname = oofold\npkgbase = oofold\npkgver = $(VERSION)-1\npkgdesc = Sovereign fixed-width line folder and terminal wrapping utility in pure openOODA.\nurl = https://github.com/openOODA-tools/oofold\nbuilddate = $$(date +%s)\npackager = openOODA-tools <ops@openooda.org>\nsize = $$(stat -c %s $(BIN))\narch = x86_64\nlicense = Apache-2.0\ndepend = glibc\nprovides = oofold\n" > dist/arch-pkg/.PKGINFO
	@tar --zstd -cf dist/oofold-$(VERSION)-1-x86_64.pkg.tar.zst -C dist/arch-pkg .PKGINFO usr
	@rm -rf dist/arch-pkg
	@bash -n packaging/arch/PKGBUILD
	@cp packaging/arch/PKGBUILD packaging/PKGBUILD
	@echo "built dist/oofold-$(VERSION)-1-x86_64.pkg.tar.zst and validated PKGBUILD"

package: package-deb package-rpm package-arch
	@cd dist && sha256sum oofold* > checksums.txt 2>/dev/null || true
	@echo "built all packages and dist/checksums.txt"

clean:
	@rm -rf dist .ooda-cache
	@echo "cleaned"
