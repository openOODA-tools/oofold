Name:           oofold
Version:        0.2.0
Release:        1%{?dist}
Summary:        Sovereign fixed-width line folder and terminal wrapping utility in pure openOODA.
License:        Apache-2.0
URL:            https://github.com/openOODA-tools/oofold
Source0:        oofold-linux-x86_64
Source1:        uninstall.sh
BuildArch:      x86_64
Requires:       glibc

%description
oofold is a sovereign, capability-bounded fixed-width line folder and terminal text
wrapping coordinator written in 100% pure native openOODA with zero ambient authority,
ANSI escape preservation, space break heuristics, and streaming Model Context Protocol (MCP) support.

%install
mkdir -p %{buildroot}/usr/bin
install -m 0755 %{SOURCE0} %{buildroot}/usr/bin/oofold
install -m 0755 %{SOURCE1} %{buildroot}/usr/bin/oofold-uninstall

%files
/usr/bin/oofold
/usr/bin/oofold-uninstall

%changelog
* Wed Oct 07 2026 openOODA-tools <ops@openooda.org> - 0.2.0-1
- Sovereign fixed-width line folder with streaming MCP and tri-distribution packaging
