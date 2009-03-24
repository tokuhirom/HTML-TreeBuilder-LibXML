package HTML::TreeBuilder::LibXML::Node;
use strict;
use warnings;

sub new {
    my ($class, $node) = @_;
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

sub tag {
    $_[0]->{node}->localname
}

1;
