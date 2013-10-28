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

