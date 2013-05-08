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
    my ($self, $key, $value) = @_;
    if (@_ == 3) {
        if (defined $value) {
            $self->{node}->setAttribute (lc $key, $value);
        } else {
            $self->{node}->removeAttribute(lc $key);
        }
    } elsif (@_ == 2 and lc $key eq 'text') {
        return $self->{node}->textContent;
    }
    $self->{node}->getAttribute(lc $key);
}

sub isTextNode {
    my $self = shift;
    $self->{node}->isa('XML::LibXML::Text');
}

# The analog of HTML::TreeBuilder::XPath::getValue for comment nodes
*getValue = \&as_text;

sub string_value {
    $_[0]->{node}->textContent;
}

sub as_text {
    $_[0]->{node}->textContent;
}

sub as_trimmed_text {
    my $text = shift->as_text(@_);
    $text =~ s/[\n\r\f\t ]+$//s;
    $text =~ s/^[\n\r\f\t ]+//s;
    $text =~ s/[\n\r\f\t ]+/ /g;
    return $text;
}
sub as_text_trimmed { shift->as_trimmed_text(@_) } # alias

sub objectify_text { }
sub deobjectify_text { }

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

sub exists {
    my( $self , $xpath ) = @_;

    $self->_eof_or_die unless $self->{node};
    my @nodes = $self->{node}->findnodes( $xpath );
    return scalar( @nodes ) ? 1 : 0;
}

sub find {
    my( $self , $elem ) = @_;

    $self->_eof_or_die unless $self->{node};

    my @nodes = $self->{node}->getElementsByTagName( $elem );
    @nodes = map { HTML::TreeBuilder::LibXML::Node->new( $_ ) } @nodes;

    wantarray ? @nodes : \@nodes;
}

sub findnodes {
    my ($self, $xpath) = @_;

    $self->_eof_or_die unless $self->{node};
    my @nodes = $self->{node}->findnodes( $xpath );
    @nodes = map { HTML::TreeBuilder::LibXML::Node->new($_) } @nodes;
    wantarray ? @nodes : \@nodes;
}

*findnodes_as_string  = \&findvalue;
*findnodes_as_strings = \&findvalues;

sub findnodes_filter {
    my( $self , $xpath , $callback ) = @_;

    Carp::croak "Second argument must be coderef"
          unless $callback and ref $callback eq 'CODE';

    my @nodes = $self->findnodes( $xpath );
    @nodes = grep { $callback->($_) } @nodes;

    wantarray ? @nodes : \@nodes;
}

sub findvalue {
    my ($self, $xpath) = @_;

    $self->_eof_or_die unless $self->{node};
    $self->{node}->findvalue( $xpath );
}

sub findvalues {
    my( $self , $xpath ) = @_;

    $self->_eof_or_die unless $self->{node};
    my $nodes = $self->{node}->find( $xpath );
    my @nodes = map { $_->textContent } $nodes->get_nodelist;
    wantarray ? @nodes : \@nodes;
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

sub childNodes {
    my $self = shift;

    $self->_eof_or_die unless $self->{node};
    my @nodes = $self->{node}->childNodes;
    @nodes = map { __PACKAGE__->new($_) } @nodes;
    wantarray ? @nodes : \@nodes;
}

sub left {
    my $self = shift;

    $self->_eof_or_die unless $self->{node};
    my $prev = $self->{node}->previousNonBlankSibling;
    return $prev ? __PACKAGE__->new( $prev ) : undef;
}

sub right {
    my $self = shift;

    $self->_eof_or_die unless $self->{node};
    my $next = $self->{node}->nextNonBlankSibling;
    return $next ? __PACKAGE__->new( $next ) : undef;
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

    $xpath =~ s/~text\b/text()/g;

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

sub all_attr {
    my $self = shift;
    return map { $_->name => $_->value } $self->{node}->attributes;
}

sub all_attr_names {
    my $self = shift;
    return map $_->name, $self->{node}->attributes;
}

sub all_external_attr       { shift->all_attr(@_) }
sub all_external_attr_names { shift->all_attr_names(@_) }

sub _eof_or_die {
    my $self = shift;
    if (defined($self->{_content})) {
        $self->eof;
    } else {
        Carp::croak "\$self is not loaded: $self"
    }
}


sub matches {
    my ($self, $xpath) = @_;    
    
    foreach ($self->{node}->ownerDocument->findnodes($xpath)) {
        return 1 if $_->isEqual($self->{node});
    }    
    
    return;
}

sub parent {
    my $self = shift;
    if (@_) {    
        # set        
        if (defined $_[0]) {
            Carp::croak "an element can't be made its own parent"
                if ref $_[0]->{node}->isEqual($self->{node});    # sanity
                
            $_[0]->{node}->appendChild($self->{node});                        
        }
        else {
            # unset
            $self->{node}->unbindNode;    
        }
                
    }
    else {
        # get
        my $parent = $self->{node}->parentNode;
        return ref $parent ne 'XML::LibXML::DocumentFragment' ? ref($self)->new($parent) : undef;
    }

}

1;

__END__

=head1 NAME

HTML::TreeBuilder::LibXML::Node - HTML::Element compatible API for HTML::TreeBuilder::LibXML

=head1 SYNOPSIS

  my $value = $node->attr('name');
  my $string = $node->string_value;
  my $text   = $node->as_text;
  my $t_text = $node->as_trimmed_text;
  my $xml    = $node->as_XML;
  my $html   = $node->as_HTML;
  my $tag    = $node->tag;
  my $id     = $node->id;
  my $clone  = $node->clone;
  $node->delete;
  my $prev_sib = $node->left;
  my $next_sib = $node->right;
  $node->look_down(@args);
  my %attr     = $node->all_attr;
  my %attr     = $node->all_external_attr;
  my @names    = $node->all_attr_names;
  my @names    = $node->all_external_attr_names;
  my @elements = $node->find($elem_name);

  # HTML::TreeBuilder::XPath
  my @nodes  = $node->find($xpath)
  my @nodes  = $node->findnodes($xpath);
  my $value  = $node->findvalue($xpath);
  my @values = $node->findvalues($xpath);
  $node->isTextNode;
  my $child = $node->getFirstChild;
  my $bool  = $node->exists($xpath);

  my $value  = $node->findnodes_as_string($xpath);
  my @values = $node->findnodes_as_strings($xpath);
