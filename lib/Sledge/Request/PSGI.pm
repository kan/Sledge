package Sledge::Request::PSGI;
use strict;
use base qw(Plack::Request);

use HTTP::Headers;
use Plack::Response;

sub new {
    my ($class, $env) = @_;

    my $self = $class->SUPER::new($env);
    $self->{_body} = '';
    $self->{_response_header} = HTTP::Headers->new;
    $self->{_response} = Plack::Response->new;
    $self->{_response}->status(200);

    return $self;
}

sub args {
    my $self = shift;

    return { map { $_ => $self->param($_) } $self->param };
}

sub header_in {
    my $self = shift;

    $self->header(@_);
}

sub header_out {
    my $self = shift;

    $self->{_response_header}->header(@_);
}

sub print {
    my $self = shift;

    $self->{_body} .= join('', @_);
}

sub response {
    my $self = shift;

    $self->{_response}->body($self->{_body});
    return $self->{_response};
}

sub send_http_header {
    my $self = shift;

    $self->{_response}->headers($self->{_response_header});
}

1;
