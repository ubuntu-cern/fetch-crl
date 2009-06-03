Version: 2.7.0
Summary: Tool for periodic retrieval of Certificate Revocation Lists
Name: fetch-crl
Release: 1
Copyright: EU DataGrid License
Group: Utilities/System
Source: http://www.eugridpma.org/distribution/util/fetch-crl/%{name}-%{version}.tar.gz
Vendor: EUgridPMA (Fabio Hernandez)
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot
Packager: David Groep <davidg@nikhef.nl>
BuildArch: noarch
Requires: openssl wget
Prefix: /usr

%description
This tool and associated cron entry ensure that Certificate Revocation 
Lists (CRLs) are periodically retrieved from the web sites of the respective 
Certification Authorities.
It assumes that the installed CA files follow the hash.crl_url convention.

%prep

%setup

%build

%clean

%install
make install PREFIX=%{buildroot}/usr ETC=%{buildroot}/etc


%files
%defattr(-,root,root)
%attr(0755,root,root) /usr/sbin/fetch-crl
%doc %attr(0644,root,root) /usr/share/man/man8/fetch-crl.8.gz
%doc %attr(0644,root,root) /usr/share/doc/%{name}-%{version}
%config(noreplace) /etc/sysconfig/fetch-crl


%changelog
* Sun Jan 25 2009 David Groep <davidg@nikhef.nl>
Version 2.7.0 with new policies, download resiliancy, PATH support, etc
* Thu Oct 27 2005 David Groep <davidg@nikhef.nl>
Wget https downloads recognise our own trusted CA directory (by RomainW)
* Mon Feb 28 2005 David Groep <davidg@nikhef.nl>
Made into a relocatable RPM without the cronjob pre-installed
* Mon Dec  6 2004 David Groep <davidg@nikhef.nl>
Copied to EUGridPMA site
* Wed Jan 15 2003 Steve Traylen <s.m.traylen@rl.ac.uk>
Initial Build
