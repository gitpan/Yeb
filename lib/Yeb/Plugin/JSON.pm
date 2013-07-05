package Yeb::Plugin::JSON;
BEGIN {
  $Yeb::Plugin::JSON::AUTHORITY = 'cpan:GETTY';
}
{
  $Yeb::Plugin::JSON::VERSION = '0.003';
}
# ABSTRACT: Yeb Plugin for JSON response

use Moo;
use JSON;

has app => ( is => 'ro', required => 1 );

sub BUILD {
	my ( $self ) = @_;
	$self->app->register_function('json',sub {
		my $data = shift;
		$data = $self->app->current_context->stash->{x} unless defined $data;
		$self->app->current_context->content_type('application/json');
		$self->app->current_context->body(to_json($data,@_));
		$self->app->current_context->response;
	});
}

1;


__END__
=pod

=head1 NAME

Yeb::Plugin::JSON - Yeb Plugin for JSON response

=head1 VERSION

version 0.003

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

