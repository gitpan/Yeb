package Yeb::Plugin::Session;
BEGIN {
  $Yeb::Plugin::Session::AUTHORITY = 'cpan:GETTY';
}
{
  $Yeb::Plugin::Session::VERSION = '0.004';
}
# ABSTRACT: Yeb Plugin for Plack::Middleware::Session

use Moo;
use Plack::Middleware::Session;
use Plack::Session::Store::File;

has app => ( is => 'ro', required => 1 );

sub BUILD {
	my ( $self ) = @_;
	$self->app->add_middleware(Plack::Middleware::Session->new(
		store => Plack::Session::Store::File->new
	));
	$self->app->register_function('session',sub {
		my $key = shift;
		return $self->app->cc->env->{'psgix.session'} unless defined $key;
		return $self->app->cc->env->{'psgix.session'}->{$key};
	});
}

1;


__END__
=pod

=head1 NAME

Yeb::Plugin::Session - Yeb Plugin for Plack::Middleware::Session

=head1 VERSION

version 0.004

=head1 SUPPORT

IRC

  Join #web-simple on irc.perl.org. Highlight Getty for fast reaction :).

Repository

  http://github.com/Getty/p5-yeb
  Pull request and additional contributors are welcome

Issue Tracker

  http://github.com/Getty/p5-yeb/issues

=head1 AUTHOR

Torsten Raudssus <torsten@raudss.us>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Torsten Raudssus.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

