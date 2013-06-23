package Data::Context::Instance;

# Created on: 2012-04-09 05:58:42
# Create by:  Ivan Wills
# $Id$
# $Revision$, $HeadURL$, $Date$
# $Revision$, $Source$, $Date$

use Moose;
use warnings;
use version;
use Carp;
use Scalar::Util;
use List::Util;
use Data::Dumper qw/Dumper/;
use English qw/ -no_match_vars /;
use Hash::Merge;
use Clone qw/clone/;
use Data::Context::Util qw/lol_path lol_iterate/;
use Class::Inspector;

our $VERSION     = version->new('0.0.5');
our @EXPORT_OK   = qw//;
our %EXPORT_TAGS = ();

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
    is         => 'rw',
    lazy_build => 1,
    builder    => '_stats',
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

sub init {
    my ($self) = @_;
    my $raw;

    # check if we already have the raw data and if so that it is current
    return $self if $self->raw && -s $self->file == $self->stats->{size};

    # get the raw data
    if ( $self->type eq 'json' ) {
        _do_require('JSON');
        $raw = JSON->new->utf8->shrink->decode( scalar $self->file->slurp );
    }
    elsif ( $self->type eq 'js' ) {
        _do_require('JSON');
        $raw = JSON->new->utf8->relaxed->shrink->decode( scalar $self->file->slurp );
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
        $self->raw({});
        my $parent = $self->dc->get_instance( $raw->{PARENT} )->init;
        $raw = Hash::Merge->new('LEFT_PRECEDENT')->merge( $raw, $parent->raw );
    }

    # save complete raw data
    $self->raw($raw);

    # get data actions
    my $count = 0;
    lol_iterate( $raw, sub { $self->process_data(\$count, @_) } );

    return $self;
}

sub get_data {
    my ( $self, $vars ) = @_;
    $self->init;

    my $data = clone $self->raw;
    my @events;

    # process the data in order
    for my $path ( _sort_optional( $self->actions ) ) {
        my ($value, $replacer) = lol_path( $data, $path );
        my $module = $self->actions->{$path}{module};
        my $method = $self->actions->{$path}{method};
        my $new = $module->$method( $value, $vars, $path, $self );

        if ( blessed($new) && $new->isa('AnyEvent::CondVar') ) {
            push @events, [ $replacer, $new ];
        }
        else {
            $replacer->($new);
        }
    }

    for my $event ( @events ) {
        $event->[0]->($event->[1]->recv);
    }

    return $data;
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

sub _sort_optional {
    my ($hash) = @_;

    my @sorted = sort {
        return $hash->{$a}->{found} <=> $hash->{$b}->{found} if ! defined $hash->{$a}->{order} && ! defined $hash->{$b}->{order};
        return $hash->{$b}->{order} >= 0 ? 1 : -1            if !defined $hash->{$a}->{order};
        return $hash->{$a}->{order} >= 0 ? -1 : 1            if !defined $hash->{$b}->{order};
        return -1                                            if $hash->{$a}->{order} >= 0 && $hash->{$b}->{order} < 0;
        return  1                                            if $hash->{$a}->{order} < 0 && $hash->{$b}->{order} >= 0;
        return $hash->{$a}->{order} <=> $hash->{$b}->{order};
    } keys %$hash;

    return @sorted;
}

our %required;
sub _do_require {
    my ($module) = @_;

    return if $required{$module}++;

    # check if namespace appears to be loaded
    return if Class::Inspector->loaded($module);

    # Try loading namespace
    $module =~ s{::}{/}g;
    $module .= '.pm';
    eval { require $module };

    confess $@ if $@;
}

1;

__END__

=head1 NAME

Data::Context::Instance - The in memory instance of a data context config file

=head1 VERSION

This documentation refers to Data::Context::Instance version 0.0.5.

=head1 SYNOPSIS

   use Data::Context::Instance;

   # create a new object
   my $dci = Data::Context::Instance->new(
        path => 'dir/file',
        file => Path::Class::file('path/to/dir/file.dc.js'),
        type => 'js',
        dc   => $dc,
   );

   # Initialise the object (done by get normally)
   $dci->init;

   # get the data (with the context of $vars)
   my $data = $dci->get_data($vars);

=head1 DESCRIPTION

=head1 SUBROUTINES/METHODS

=head2 C<init()>

Initialises the instance ie it reads the config file and merges in the parent if found

=head2 C<get_data ( $vars )>

Returns the data from the config file processed with the context of $vars

=head2 C<process_data( $count, $data, $path )>

This does the magic of processing the data, and in the future handling of the
data event loop.

=head1 DIAGNOSTICS

=head1 CONFIGURATION AND ENVIRONMENT

=head1 DEPENDENCIES

=head1 INCOMPATIBILITIES

=head1 BUGS AND LIMITATIONS

There are no known bugs in this module.

Please report problems to Ivan Wills (ivan.wills@gmail.com).

Patches are welcome.

=head1 AUTHOR

Ivan Wills - (ivan.wills@gmail.com)

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2012 Ivan Wills (14 Mullion Close, Hornsby Heights, NSW Australia 2077).
All rights reserved.

This module is free software; you can redistribute it and/or modify it under
the same terms as Perl itself. See L<perlartistic>.  This program is
distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.

=cut
