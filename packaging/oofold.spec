Name:           oofold
Version:        0.1.0
Release:        1%{?dist}
Summary:        Width-aware text line folder breaking on word boundaries and ANSI escape codes.
License:        ASL 2.0
URL:            https://github.com/openOODA-tools/oofold
Source0:        oofold-linux-x86_64
Source1:        uninstall.sh
BuildArch:      x86_64
Requires:       glibc

%description
oofold is a sovereign, capability-bounded LINE WRAPPER written
in pure openOODA, featuring zero ambient authority, oote color themes,
and an MCP stdio server.

%install
mkdir -p %{buildroot}/usr/bin
install -m 0755 %{SOURCE0} %{buildroot}/usr/bin/oofold
install -m 0755 %{SOURCE1} %{buildroot}/usr/bin/oofold-uninstall

%files
/usr/bin/oofold
/usr/bin/oofold-uninstall

%changelog
* Wed Oct 07 2026 openOODA-tools <ops@openooda.org> - 0.1.0-1
- Initial sovereign blueprint scaffolding
