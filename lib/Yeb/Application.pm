package Yeb::Application;
BEGIN {
  $Yeb::Application::AUTHORITY = 'cpan:GETTY';
}
{
  $Yeb::Application::VERSION = '0.003';
}
# ABSTRACT: Main Meta Class for a Yeb Application

use Moo;
use Package::Stash;
use Import::Into;
use Yeb::Context;
use Yeb::Class;
use Class::Load ':all';
use Path::Tiny qw( path );
use Plack::Middleware::Debug;

use Web::Simple ();

has class => (
	is => 'ro',
	required => 1,
);

has args => (
	is => 'ro',
	predicate => 1,
);

has config => (
	is => 'ro',
	lazy => 1,
	builder => sub {{}},
);

has root => (
	is => 'ro',
	lazy => 1,
	builder => sub {
		defined $ENV{YEB_ROOT}
			? path($ENV{YEB_ROOT})
			: path(".")
	},
);

has current_dir => (
	is => 'ro',
	lazy => 1,
	builder => sub { path(".") },
);

has debug => (
	is => 'ro',
	lazy => 1,
	builder => sub { $ENV{YEB_TRACE} || $ENV{YEB_DEBUG} ? 1 : 0 },
);

has package_stash => (
	is => 'ro',
	lazy => 1,
	builder => sub { Package::Stash->new(shift->class) },
);

has yebs => (
	is => 'ro',
	lazy => 1,
	builder => sub {{}},
);
sub y {
	my ( $self, $yeb ) = @_;
	$self->yebs->{$yeb};
}
sub y_main {
	my ( $self ) = @_;
	$self->yebs->{$self->class};
}

has functions => (
	is => 'ro',
	lazy => 1,
	builder => sub {{}},
);

has plugins => (
	is => 'ro',
	lazy => 1,
	builder => sub {[]},
);

sub add_plugin {
	my ( $self, $source, $plugin, %args ) = @_;
	my $class;
	if ($plugin =~ m/^\+(.+)/) {
		$class = $1;
	} else {
		$class = 'Yeb::Plugin::'.$plugin;
	}
	load_class($class);
	my $obj = $class->new( app => $self, class => $self->y($source) , %args );
	push @{$self->plugins}, $obj;
}

sub add_middleware {
	my ( $self, $middleware ) = @_;
	$self->y_main->prepend_to_chain( "" => sub { $middleware } );
}

sub BUILD {
	my ( $self ) = @_;

	$self->root;
	$self->current_dir;

	$self->package_stash->add_symbol('$yeb',\$self);
	
	Web::Simple->import::into($self->class);
	
	$self->package_stash->add_symbol('&dispatch_request',sub {
		my ( undef, $env ) = @_;
		$self->reset_context;
		my $context = Yeb::Context->new( env => $env );
		$self->cc($context);
		return $self->y_main->chain,
			'/...' => sub { $self->cc->response };
	});

	$self->yeb_import($self->class);

	$self->package_stash->add_symbol('&import',sub {
		my ( $class, $alias ) = @_;
		my $target = caller;
		$self->yeb_import($target, $alias);
	});

	if ($self->debug) {
		$self->add_middleware(Plack::Middleware::Debug->new);
	}
}

has cc => (
	is => 'rw',
	clearer => 'reset_context',
);
sub current_context { shift->cc }

sub yeb_import {
	my ( $self, $target ) = @_;
	$self->yebs->{$target} = Yeb::Class->new(
		app => $self,
		class => $target,
	);
	for (keys %{$self->functions}) {
		$self->y($target)->add_function($_,$self->functions->{$_});
	}
}

sub register_function {
	my ( $self, $func, $coderef ) = @_;
	die "Function ".$func." already defined" if defined $self->functions->{$func};
	$self->functions->{$func} = $coderef;
	for (keys %{$self->yebs}) {
		$self->y($_)->add_function($func,$coderef);
	}
}

1;


__END__
=pod

=head1 NAME

Yeb::Application - Main Meta Class for a Yeb Application

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

