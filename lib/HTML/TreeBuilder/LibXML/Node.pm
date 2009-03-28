package HTML::TreeBuilder::LibXML::Node;
use strict;
use warnings;
use Carp();

=head1 TODO

    parent

=cut


sub new {
    my ($class, $node) = @_;
    Carp::croak 'missing node' unless $node;
    bless {node => $node}, $class;
}

sub attr {
    my ($self, $key) = @_;
    $self->{node}->getAttribute(lc $key);
}

sub isTextNode {
    my ($self, ) = @_;
    $self->{node}->isa('XML::LibXML::Text');
}

sub string_value {
    $_[0]->{node}->textContent;
}

sub as_text {
    $_[0]->{node}->textContent;
}

sub as_XML {
    $_[0]->{node}->toString;
}

sub as_HTML {
    $_[0]->{node}->toString;
}

sub tag {
    $_[0]->{node}->localname
}

sub id {
    if (@_==2) {
        # setter
        if (defined $_[1]) {
            $_[0]->{node}->setAttribute('id', $_[1]);
        } else {
            $_[0]->{node}->removeAttribute('id');
        }
    } else {
        $_[0]->{node}->getAttribute('id');
    }
}

# hack for Web::Scraper
sub isa {
    my ($self, $klass) = @_;
    $klass eq 'HTML::Element' ? 1 : UNIVERSAL::isa($self, $klass);
}

sub findnodes {
    my ($self, $xpath) = @_;

    $self->_eof_or_die unless $self->{node};
    my @nodes = $self->{node}->findnodes( $xpath );
    @nodes = map { HTML::TreeBuilder::LibXML::Node->new($_) } @nodes;
    wantarray ? @nodes : \@nodes;
}
sub findvalue {
    my ($self, $xpath) = @_;

    $self->_eof_or_die unless $self->{node};
    $self->{node}->findvalue( $xpath );
}

sub clone {
    my ($self, ) = @_;

    my $orignode = $self->{node};
    my $origdoc = $orignode->ownerDocument;

    my $node = $orignode->cloneNode(1);
    my $doc = XML::LibXML::Document->new($origdoc->version, $origdoc->encoding);
    $doc->setDocumentElement($node);
    my $cloned = __PACKAGE__->new($node);
    return $cloned;
}

sub delete {
    my $self = shift;
    $self->{node}->unbindNode();
}

sub getFirstChild {
    my $self = shift;
    __PACKAGE__->new($self->{node}->getFirstChild);
}

sub look_down {
    my $self = shift;
    my @args = @_;

    $self->_eof_or_die unless $self->{node};

    my @filter;
    my $xpath = "//*"; # default
    while (@args) {
        if (ref $args[0] eq 'CODE') {
            my $code = shift @args;
            push @filter, $code;
        } elsif (@args >= 2 && $args[0] eq '_tag') {
            my($tag, $want_tag) = splice(@args, 0, 2);
            $xpath = "//$want_tag";
        } elsif (@args >= 2) {
            my($attr, $stuff) = splice(@args, 0, 2);
            if (ref $stuff eq 'Regexp') {
                push @filter, sub { no warnings 'uninitialized'; $_[0]->attr($attr) =~ $stuff };
            } else {
                push @filter, sub { no warnings 'uninitialized'; $_[0]->attr($attr) eq $stuff };
            }
        } else {
            Carp::carp("Don't know what to do with @args");
            shift @args;
        }
    }

    my @nodes = $self->findnodes($xpath);
    my @wants = grep {
        my $node = $_;
        my $ok = 1;
        for my $filter (@filter) {
            $filter->($_) or $ok = 0;
        }
        $ok ? $node : ();
    } @nodes;

    wantarray ? @wants : $wants[0];
}

sub _eof_or_die {
    my $self = shift;
    if (defined($self->{_content})) {
        $self->eof;
    } else {
        Carp::croak "\$self is not loaded: $self"
    }
}

1;
