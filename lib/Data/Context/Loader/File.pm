package Data::Context::Loader::File;

# Created on: 2013-10-27 20:02:37
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
use Data::Context::Util qw/do_require/;

our $VERSION = version->new('0.0.5');

extends 'Data::Context::Loader';

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
has stats => (
    is         => 'rw',
    lazy_build => 1,
    builder    => '_stats',
    init_arg   => undef,
);

sub _stats {
    my ($self) = @_;
    my $stat = $self->file->stat;
    if ( !-f $self->file ) {
        my $msg = 'Cannot find the file "' . $self->file . '"';
        $self->log->error($msg);
        confess $msg;
    }

    return {
        size     => $stat->size,
        modified => $stat->mtime,
    };
}

sub changed {
    my ($self) = @_;

    # check if we already have the raw data and if so that it is current
    return -s $self->file != $self->stats->{size};
}

sub load {
    my ($self) = @_;
    my $raw;

    # get the raw data
    if ( $self->type eq 'json' ) {
        do_require('JSON');
        $raw = JSON->new->utf8->shrink->decode( scalar $self->file->slurp );
    }
    elsif ( $self->type eq 'js' ) {
        do_require('JSON');
        $raw = JSON->new->utf8->relaxed->shrink->decode( scalar $self->file->slurp );
    }
    elsif ( $self->type eq 'yaml' ) {
        do_require('YAML::XS');
        $raw = YAML::XS::Load( scalar $self->file->slurp );
    }
    elsif ( $self->type eq 'xml' ) {
        do_require('XML::Simple');
        $raw = XML::Simple::XMLin( scalar $self->file->slurp );
    }

    # Reset the file stats on load.
    $self->stats($self->_stats);

    return $raw;
}

1;

__END__

=head1 NAME

Data::Context::Loader::File - <One-line description of module's purpose>

=head1 VERSION

This documentation refers to Data::Context::Loader::File version 0.0.1


=head1 SYNOPSIS

   use Data::Context::Loader::File;

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

Copyright (c) 2013 Ivan Wills (14 Mullion Close, Hornsby Heights, NSW Australia 2077).
All rights reserved.

This module is free software; you can redistribute it and/or modify it under
the same terms as Perl itself. See L<perlartistic>.  This program is
distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.

=cut
