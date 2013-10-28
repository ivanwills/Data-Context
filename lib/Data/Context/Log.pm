package Data::Context::Log;

use Moose;

has level => ( is => 'rw', isa => 'Int', default => 3 );
sub debug {
    my ($self, @message) = @_;
    $self->_log( 'DEBUG', @message ) if $self->level <= 1;
    return;
}
sub info  {
    my ($self, @message) = @_;
    $self->_log( 'INFO' , @message ) if $self->level <= 2;
    return;
}
sub warn  {   ## no critic
    my ($self, @message) = @_;
    $self->_log( 'WARN' , @message ) if $self->level <= 3;
    return;
}
sub error {
    my ($self, @message) = @_;
    $self->_log( 'ERROR', @message ) if $self->level <= 4;
    return;
}
sub fatal {
    my ($self, @message) = @_;
    $self->_log( 'FATAL', @message ) if $self->level <= 5;
    return;
}

sub _log {
    my ($self, $level, @message) = @_;
    chomp $message[-1];
    CORE::warn( localtime() . " [$level] ", @message, "\n" );
    return;
}

1;

__END__

=head1 NAME

Data::Context::Log - Simple Log object helper

=head1 VERSION

This documentation refers to Data::Context::Log version 0.0.1

=head1 SYNOPSIS

   use Data::Context::Log;

   # Brief but working code example(s) here showing the most common usage(s)
   # This section will be as far as many users bother reading, so make it as
   # educational and exemplary as possible.


=head1 DESCRIPTION

=head1 SUBROUTINES/METHODS

=head2 new

Has one optional parameter C<level> (default is 3) which sets the cut off
level for showing log messages. Setting level to 1 shows all messages, setting
level to 5 will show only fatal error messages.

=over 4

=item debug

Requires level 1 to be displayed

=item info

Requires level 2 to be displayed

=item warn

Requires level 3 to be displayed

=item error

Requires level 4 to be displayed

=item fatal

Requires level 5 to be displayed

=back

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

Copyright (c) 2013 Ivan Wills (14 Mullion Close, Hornsby Heights, NSW Australia 2077).
All rights reserved.

This module is free software; you can redistribute it and/or modify it under
the same terms as Perl itself. See L<perlartistic>.  This program is
distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.

=cut
