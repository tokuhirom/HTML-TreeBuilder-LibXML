package HTML::TreeBuilder::LibXML::Node;
use strict;
use warnings;
use Carp();

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

# hack for Web::Scraper
sub isa {
    my ($self, $klass) = @_;
    $klass eq 'HTML::Element' ? 1 : UNIVERSAL::isa($self, $klass);
}

sub findnodes {
    my ($self, $xpath) = @_;

    die "\$self is not loaded: $self" unless $self->{node};
    my @nodes = $self->{node}->findnodes( $xpath );
    return map { HTML::TreeBuilder::LibXML::Node->new($_) } @nodes;
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

1;
