package Yeb::Context;
BEGIN {
  $Yeb::Context::AUTHORITY = 'cpan:GETTY';
}
{
  $Yeb::Context::VERSION = '0.009';
}
# ABSTRACT: Storage for context of request

use Moo;
use Plack::Request;

has env => (
	is => 'ro',
	required => 1,
);

has stash => (
	is => 'ro',
	lazy => 1,
	builder => sub {{}},
);

has export => (
	is => 'ro',
	lazy => 1,
	builder => sub {{}},
);

has header => (
	is => 'ro',
	lazy => 1,
	builder => sub {{}},
);

has request => (
	is => 'ro',
	lazy => 1,
	builder => sub { Plack::Request->new(shift->env) }
);

has status => (
	is => 'rw',
	lazy => 1,
	builder => sub { 200 },
	predicate => 1,
);

has body => (
	is => 'rw',
	lazy => 1,
	builder => sub { "Nothing todo, i am out of here" },
	predicate => 1,
);

has content_type => (
	is => 'rw',
	lazy => 1,
	builder => sub { "text/html" },
	predicate => 1,
);

sub response {
	my $self = shift;
	[
		$self->status,
		[
			content_type => $self->content_type,
			map { $_, $self->header->{_} } keys %{$self->header}
		],
		[ $self->body ]
	]
}

1;

__END__

=pod

=head1 NAME

Yeb::Context - Storage for context of request

=head1 VERSION

version 0.009

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
