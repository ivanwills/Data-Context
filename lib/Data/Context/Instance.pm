package Data::Context::Instance;

# Created on: 2012-04-09 05:58:42
# Create by:  Ivan Wills
# $Id$
# $Revision$, $HeadURL$, $Date$
# $Revision$, $Source$, $Date$

use Moose;
use version;
use Carp;
use Scalar::Util;
use List::Util;
use Data::Dumper qw/Dumper/;
use English qw/ -no_match_vars /;
use Hash::Merge;
use Clone qw/clone/;
use Data::Context::Util qw/lol_path lol_itterate/;

our $VERSION     = version->new('0.0.1');
our @EXPORT_OK   = qw//;
our %EXPORT_TAGS = ();
#our @EXPORT      = qw//;

has path => (
    is       => 'rw',
    isa      => 'Str',
    required => 1,
);
has file => (
    is       => 'rw',
    isa      => 'Path::Class::File',
    required => 1,
);
has type => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);
has dc => (
    is       => 'rw',
    isa      => 'Data::Context',
    required => 1,
    weak_ref => 1,
);
has stats => (
    is => 'rw',
    builder => '_stats',
);
has raw => (
    is  => 'rw',
    isa => 'Any',
);
has actions => (
    is      => 'rw',
    isa     => 'HashRef[HashRef]',
    default => sub {{}},
);

sub _stats {
    my ($self) = @_;
    my $stat = $self->file->stat;
    warn $self->file if !-f $self->file;
    return {
        size     => $stat->size,
        modified => $stat->mtime,
    };
}

sub init {
    my ($self) = @_;
    my $raw;

    return $self if $self->raw;

    # get the raw data
    if ( $self->type eq 'json' ) {
        _do_require('JSON');
        $raw = JSON->new->utf8->decode( scalar $self->file->slurp );
    }
    elsif ( $self->type eq 'js' ) {
        _do_require('JSON');
        $raw = JSON->new->utf8->relaxed->decode( scalar $self->file->slurp );
    }
    elsif ( $self->type eq 'yaml' ) {
        _do_require('YAML::XS');
        $raw = YAML::XS::Load( scalar $self->file->slurp );
    }
    elsif ( $self->type eq 'xml' ) {
        _do_require('XML::Simple');
        $raw = XML::Simple::XMLin( scalar $self->file->slurp );
    }

    # merge in any inherited data
    if ( $raw->{PARENT} ) {
        my $parent = $self->dc->get_instance( $raw->{PARENT} );
        $raw = Hash::Merge->new('LEFT_PRECEDENT')->merge( $raw, $parent );
    }

    # save complete raw data
    $self->raw($raw);

    # get data actions
    my $count = 0;
    lol_itterate( $raw, sub { $self->process_data(\$count, @_) } );

    return $self;
}

sub get_data {
    my ( $self, $vars ) = @_;
    $self->init;

    my $data = clone $self->raw;

    # process the data in order
    for my $path ( sort_optional( $self->actions ) ) {
        my ($value, $replacer) = lol_path( $data, $path );
        my $module = $self->actions->{$path}{module};
        my $method = $self->actions->{$path}{method};
        my $new = $module->$method( $value, $self->dc, $path, $vars );

        $replacer->($new);
    }

    return $data;
}

sub sort_optional {
    my ($hash) = @_;

    return sort {
        return $hash->{$a}->{found} <=> $hash->{$b}->{found} if ! defined $hash->{$a}->{order} && ! defined $hash->{$b}->{order};
        return $hash->{$b}->{order} >= 0 ? 1 : -1            if !defined $hash->{$a}->{order};
        return $hash->{$a}->{order} >= 0 ? -1 : 1            if !defined $hash->{$b}->{order};
        return -1                                            if $hash->{$a}->{order} >= 0 && $hash->{$b}->{order} < 0;
        return  1                                            if $hash->{$a}->{order} < 0 && $hash->{$b}->{order} >= 0;
        return $hash->{$a}->{order} <=> $hash->{$b}->{order};
    } keys %$hash;
}

sub process_data {
    my ( $self, $count, $data, $path ) = @_;

    if ( !ref $data ) {
        if ( $data =~ /^\# (.*) \#$/xms ) {
            my $data_path = $1;
            _do_require( $self->dc->action_class );
            $self->actions->{$path} = {
                module => $self->dc->action_class,
                method => 'expand_vars',
                found  => $$count++,
                path   => $data_path,
            };
        }
    }
    elsif ( ref $data eq 'HASH' && ( $data->{MODULE} || $data->{METHOD} ) ) {
        $self->actions->{$path} = {
            module => $data->{MODULE} || $self->dc->action_class,
            method => $data->{METHOD} || $self->dc->action_method,
            order  => $data->{ORDER},
            found  => $$count++,
        };
        _do_require( $self->actions->{$path}{module} );
    }

    return;
}

our %required;
sub _do_require {
    my ($module) = @_;

    return if $required{$module}++;

    $module =~ s{::}{/}g;
    $module .= '.pm';
    eval { require $module };

    confess $@ if $@;
}

1;

__END__

=head1 NAME

Data::Context::Instance - <One-line description of module's purpose>

=head1 VERSION

This documentation refers to Data::Context::Instance version 0.1.


=head1 SYNOPSIS

   use Data::Context::Instance;

   # Brief but working code example(s) here showing the most common usage(s)
   # This section will be as far as many users bother reading, so make it as
   # educational and exemplary as possible.


=head1 DESCRIPTION

A full description of the module and its features.

May include numerous subsections (i.e., =head2, =head3, etc.).


=head1 SUBROUTINES/METHODS

A separate section listing the public components of the module's interface.

These normally consist of either subroutines that may be exported, or methods
that may be called on objects belonging to the classes that the module
provides.

Name the section accordingly.

In an object-oriented module, this section should begin with a sentence (of the
form "An object of this class represents ...") to give the reader a high-level
context to help them understand the methods that are subsequently described.




=head1 DIAGNOSTICS

A list of every error and warning message that the module can generate (even
the ones that will "never happen"), with a full explanation of each problem,
one or more likely causes, and any suggested remedies.

=head1 CONFIGURATION AND ENVIRONMENT

A full explanation of any configuration system(s) used by the module, including
the names and locations of any configuration files, and the meaning of any
environment variables or properties that can be set. These descriptions must
also include details of any configuration language used.

=head1 DEPENDENCIES

A list of all of the other modules that this module relies upon, including any
restrictions on versions, and an indication of whether these required modules
are part of the standard Perl distribution, part of the module's distribution,
or must be installed separately.

=head1 INCOMPATIBILITIES

A list of any modules that this module cannot be used in conjunction with.
This may be due to name conflicts in the interface, or competition for system
or program resources, or due to internal limitations of Perl (for example, many
modules that use source code filters are mutually incompatible).

=head1 BUGS AND LIMITATIONS

A list of known problems with the module, together with some indication of
whether they are likely to be fixed in an upcoming release.

Also, a list of restrictions on the features the module does provide: data types
that cannot be handled, performance issues and the circumstances in which they
may arise, practical limitations on the size of data sets, special cases that
are not (yet) handled, etc.

The initial template usually just has:

There are no known bugs in this module.

Please report problems to Ivan Wills (ivan.wills@gmail.com).

Patches are welcome.

=head1 AUTHOR

Ivan Wills - (ivan.wills@gmail.com)
<Author name(s)>  (<contact address>)

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2012 Ivan Wills (14 Mullion Close, Hornsby Heights, NSW Australia 2077).
All rights reserved.

This module is free software; you can redistribute it and/or modify it under
the same terms as Perl itself. See L<perlartistic>.  This program is
distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.

=cut
