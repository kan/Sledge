package Sledge::Pages::PSGI;
# $Id: CGI.pm,v 1.1.1.1 2003/02/13 06:59:36 miyagawa Exp $
#
# Tatsuhiko Miyagawa <miyagawa@edge.co.jp>
# Livin' On The EDGE, Co., Ltd..
#

use strict;
use base qw(Sledge::Pages::Base);

use Sledge::Request::PSGI;

sub create_request {
    my($self, $env) = @_;
    return Sledge::Request::PSGI->new($env);
}

sub dispatch {
    my($self, $page) = @_;
    return if $self->finished; # already redirected?

    no warnings 'redefine';
    local *Sledge::Registrar::context = sub { $self };
    Sledge::Exception->do_trace(1) if $self->debug_level;
    eval {
        $self->init_dispatch($page);
        $self->invoke_hook('BEFORE_DISPATCH') unless $self->finished;
        if ($self->is_post_request && ! $self->finished) {
            my $postmeth = 'post_dispatch_' . $page;
            $self->$postmeth() if $self->can($postmeth);
        }
        unless ($self->finished) {
            my $method = 'dispatch_' . $page;
            $self->$method();
            $self->invoke_hook('AFTER_DISPATCH');
        }
        $self->output_content unless $self->finished;
    };
    $self->handle_exception($@) if $@;
    my $response = $self->r->response;
    $self->_destroy_me;

    return $response;
}

1;

