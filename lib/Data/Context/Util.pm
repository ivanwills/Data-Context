package Data::Context::Util;

# Created on: 2012-04-12 15:59:08
# Create by:  Ivan Wills
# $Id$
# $Revision$, $HeadURL$, $Date$
# $Revision$, $Source$, $Date$

use strict;
use warnings;
use version;
use Carp;
use Scalar::Util qw/blessed/;
use List::Util;
#use List::MoreUtils;
use Data::Dumper qw/Dumper/;
use English qw/ -no_match_vars /;
use base qw/Exporter/;

our $VERSION     = version->new('0.0.1');
our @EXPORT_OK   = qw/lol_path lol_iterate/;
our %EXPORT_TAGS = ();
#our @EXPORT      = qw//;

sub lol_path {
    my ($lol, $path) = @_;
    my @path = split /[.]/, $path;
    my $point = $lol;
    my $replacer;

    POINT:
    while ( $point && @path ) {

        # ignore empty path parts
        if ( ! defined $path[0] || $path[0] eq '' ) {
            shift @path;
            next POINT;
        }

        my $item = shift @path;
        my $current = $point;

        # process the point
        if ( !ref $point ) {
            return;
        }
        elsif ( ref $point eq 'HASH' ) {
            $replacer = sub { $current->{$item} = shift };
            $point = $point->{$item};
        }
        elsif ( ref $point eq 'ARRAY' ) {
            $replacer = sub {  $current->[$item] = shift };
            $point = $point->[$item];
        }
        elsif ( blessed $point && $point->can( $path[0] ) ) {
            $replacer = undef;
            $point = $point->$item();
        }
        else {
            confess "Don't know how to deal with $point";
        }

        return wantarray ? ($point, $replacer) : $point if !@path;
    }

    # nothing found
    return;
}

sub lol_iterate {
    my ($lol, $code, $path) = @_;
    my $point = $lol;

    $path = $path ? "$path." : '';

    if ( $point ) {
        if ( !ref $point ) {
            $code->( $point, $path );
        }
        elsif ( ref $point eq 'HASH' ) {
            for my $key ( keys %$point ) {
                $code->( $point->{$key}, "$path$key" );
                lol_iterate( $point->{$key}, $code, "$path$key" ) if ref $point->{$key};
            }
        }
        elsif ( ref $point eq 'ARRAY' ) {
            for my $i ( 0 .. @$point - 1 ) {
                $code->( $point->[$i], "$path$i" );
                lol_iterate( $point->[$i], $code, "$path$i" ) if ref $point->[$i];
            }
        }
    }

    return;
}

1;

__END__

=head1 NAME

Data::Context::Util - <One-line description of module's purpose>

=head1 VERSION

This documentation refers to Data::Context::Util version 0.1.

=head1 SYNOPSIS

   use Data::Context::Util;

   # Brief but working code example(s) here showing the most common usage(s)
   # This section will be as far as many users bother reading, so make it as
   # educational and exemplary as possible.


=head1 DESCRIPTION

=head1 SUBROUTINES/METHODS

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
