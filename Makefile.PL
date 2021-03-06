use 5.010001;

use strict;
use warnings;
use ExtUtils::MakeMaker;
use FindBin;
use Data::Dumper;
use lib "$FindBin::RealBin/3rd/lib/perl5";

WriteMakefile(
  NAME         => 'Net::LDAP::SPNEGO',
  VERSION_FROM => 'lib/Net/LDAP/SPNEGO.pm',
  ABSTRACT     => 'Provide NTLM authentication by forwarding requests to an upstram AD server',
  AUTHOR       => 'Tobias Oetiker <tobi@oetiker.ch>',
  LICENSE      => 'artistic_2',
  PREREQ_PM    =>  {
    'Net::LDAP' => '0.65',
    'Encoding::BER' => '1.02'
  },
  TEST_REQUIRES => {
    'Mojolicious' => '7.01',
  },
  BUILD_REQUIRES => {
    'Pod::Markdown::Github' => '0.01',
    'CPAN::Uploader' => 0,
  },
  META_MERGE   => {
    requires  => {perl => '5.010001'},
    resources => {
      license     => 'http://www.opensource.org/licenses/artistic-license-2.0',
      repository  => 'https://github.com/oetiker/net-ldap-spnego',
      bugtracker  => 'https://github.com/oetiker/net-ldap-spnego/issues'
    },
    no_index => {directory => ['t','eg']}
  },
  test => {TESTS => 't/*.t'}
);

sub MY::postamble {
   my $self = shift;
   my %r = (%{ $self->{PREREQ_PM} || {} }, %{ $self->{BUILD_REQUIRES} || {} }, %{ $self->{TEST_REQUIRES} || {} } );
   my $modules = join " ", grep !/^perl\@/, map { $r{$_} ? $_ .'@'. $r{$_} : $_ } keys %r;
   my $tpd = "$FindBin::RealBin/3rd";
   warn "** call 'make 3rd' to build missing dependencies ...\n";
   return <<"EOF";

all:: README.md README

README.md: lib/Net/LDAP/SPNEGO.pm
	\$(PERL) -I$tpd/lib/perl5 -MPod::Markdown::Github -e "binmode(STDOUT, q(:utf8));Pod::Markdown::Github->new->filter(q(lib/Net/LDAP/SPNEGO.pm))" > README.md

README: README.md
	cp README.md README

3rd: $tpd/touch
	mkdir -p $tpd

$tpd/touch: Makefile
	\$(NOECHO) \$(ECHO) "*** INSTALLING MISSING BITS FOR TESTING ***"
	curl -L http://cpanmin.us | PERL_CPANM_HOME=$tpd \$(PERL) - -q --notest --local-lib-contained $tpd $modules && touch $tpd/touch
EOF
}
