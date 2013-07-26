package Yeb::Plugin::JSON;
BEGIN {
  $Yeb::Plugin::JSON::AUTHORITY = 'cpan:GETTY';
}
{
  $Yeb::Plugin::JSON::VERSION = '0.009';
}
# ABSTRACT: Yeb Plugin for JSON response

use Moo;
use JSON;

has app => ( is => 'ro', required => 1 );

sub get_vars {
	my ( $self, $user_vars ) = @_;
	my %stash = %{$self->app->cc->stash};
	my %user = defined $user_vars ? %{$user_vars} : ();
	return $self->app->merge_hashs(
		$self->app->cc->export,
		\%user
	);
}

sub BUILD {
	my ( $self ) = @_;
	$self->app->register_function('json',sub {
		my $user_vars = shift;
		my $vars = $self->get_vars($user_vars);
		$self->app->cc->content_type('application/json');
		$self->app->cc->body(to_json($vars,@_));
		$self->app->cc->response;
	});
}

1;

__END__

=pod

=head1 NAME

Yeb::Plugin::JSON - Yeb Plugin for JSON response

=head1 VERSION

version 0.009

=head1 SYNOPSIS

  package MyYeb;

  use Yeb;

  BEGIN {
    plugin 'JSON';
  }

  r "/" => sub {
    ex key => 'value';
    json { other_key => 'value' };
  };

  1;

=encoding utf8

=head1 FRAMEWORK FUNCTIONS

=head2 json

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
