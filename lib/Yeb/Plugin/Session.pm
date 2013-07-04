package Yeb::Plugin::Session;
BEGIN {
  $Yeb::Plugin::Session::AUTHORITY = 'cpan:GETTY';
}
{
  $Yeb::Plugin::Session::VERSION = '0.001';
}

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
		return $self->app->current_context->env->{'psgix.session'} unless defined $key;
		return $self->app->current_context->env->{'psgix.session'}->{$key};
	});
}

1;
__END__
=pod

=head1 NAME

Yeb::Plugin::Session

=head1 VERSION

version 0.001

=head1 AUTHOR

Torsten Raudssus <torsten@raudss.us>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Torsten Raudssus.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

