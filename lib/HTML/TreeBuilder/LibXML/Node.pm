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

# hack for Web::Scraper
sub isa {
    my ($self, $klass) = @_;
    $klass eq 'HTML::Element' ? 1 : UNIVERSAL::isa($self, $klass);
}

sub findnodes {
    my ($self, $xpath) = @_;

    my @nodes = $self->{node}->findnodes( $xpath );
    return map { HTML::TreeBuilder::LibXML::Node->new($_) } @nodes;
}

sub clone {
    my ($self, ) = @_;
    my $pkg = ref $self;

    my $orignode = $self->{node};
    my $origdoc = $orignode->ownerDocument;

    my $node = $orignode->cloneNode(1);
    my $doc = XML::LibXML::Document->new($origdoc->version, $origdoc->encoding);
    $doc->setDocumentElement($node);
    $pkg->new($node);
}

sub delete {
    my $self = shift;
    delete $self->{$_} for keys %$self;
}

1;
