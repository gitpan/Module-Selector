package Module::Selector;

use strict;
use warnings;
use autouse Carp => qw(croak());

our $VERSION = '0.10';

sub new($$) {
	my ($class, $packages)	= @_;

	$class = ref($class) || $class;

	croak "Module::Selector->new has to be passed an array reference"
		unless ref($packages) eq 'ARRAY';

	my $self = { 
		pkgs	=> $packages,
		pkg_c	=> scalar @$packages,
		ltry	=> 0,
		get_c	=> 0,
		vpkgs	=> []
	};

	bless($self, $class);
	
	return $self
}

{
 my %failed;
 
 sub _try($) {
	my $self	= shift;

	return if $self->{'ltry'} >= $self->{'pkg_c'};

	my ($i, $pkg, $pkgc);

	$pkgc = $self->{'pkg_c'};

	for($i=$self->{'ltry'}; $i<$pkgc; $i++) {
		$pkg	= $self->{'pkgs'}->[$i];

		next if $failed{$pkg};

		eval "require $pkg";

		if($@) {
			$failed{$pkg} = 1;
			$@ = undef
		}
		else {
			last
		}
	}

	$self->{'ltry'} = ++$i;
	
	if($pkg and not $failed{$pkg}) {
		push @{$self->{'vpkgs'}}, $pkg;

		return 1
	}
	
	return 0
 }
}

sub each($) {
	my $self	= shift;

	if($self->{'get_c'} > @{$self->{'vpkgs'}}) {
		$self->{'get_c'} = 0;
		return
	}

	$self->{'get_c'}++;
	
	unless($self->{'get_c'} <= @{$self->{'vpkgs'}} or $self->_try) {
		$self->{'get_c'} = 0;
		return
	}

	return $self->{'vpkgs'}->[($self->{'get_c'}-1)]
}

sub rewind($) {
	my $self	= shift;

	$self->{'get_c'} = 0
}

1;

__END__

=head1 NAME

B<Module::Selector> - use the first module, that works.

=head1 SYNOPSIS

	use Module::Selector;

	$mods = Module::Selector->new(['Some::Mod', 'Other::Mod', 'YAM']);

	while(defined($mod = $mods->each)) {
		$@ = undef;
		eval { $mod->do_something() };
		last unless $@
	}

	$mods->rewind;

	while(defined($mod = $mods->each)) {
		$@ = undef;
		eval { $mod->something_else() };
		last unless $@
	}

=head1 DESCRIPTION

The idea behind this module is to test for a series of modules with a common
interface, as to see either which module is able to do a specific task or
simply to see which module is installed.

This module is especially useful if you had to test the modules, which you 
wish to use, multiple times otherwise, which is a bit tricky via eval.

It will try to load the given modules one by one, loading them only if needed.

=head1 METHODS

=over 4

=item B<new>(LIST REFERENCE TO PKGS)

Creates a new object, should be given a reference to a list of module
names (like C<File::Spec>, C<MP3::Info>, ...) as sole argument.

=item B<each>

Returns the next module that was successfully imported via require, returns
undef once if no other module could be imported. After that it starts again
with the first module..

=item B<rewind>

Resets C<each()>, so that it starts again with the first module, even if there
were other modules still availabe to test. Useful if you abort loops and want
to start all over again.

=back

=head1 EXPORTS

None.

=head1 CAVEATS

B<Module::Selector> saves any errors encountered when loading modules in a
locally scoped hash (local to the the C<_try()> function, which is used by 
C<each()>). This is necessary, sorry.

=head1 AUTHOR

Copyright (c) 2006 Odin Kroeger <okroeger@cpan.org>. 

All rights reserved. This library is free software; 
you can redistribute it and/or
modify it under the same terms as Perl itself.
