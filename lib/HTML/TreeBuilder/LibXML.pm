package HTML::TreeBuilder::LibXML;
use strict;
use warnings;
our $VERSION = '0.01';
use Carp ();
use XML::LibXML;
use HTML::TreeBuilder::LibXML::Node;

sub new {
    my $class = shift;
    bless {}, $class;
}

sub parse {
    my ($self, $html) = @_;
    my $parser = XML::LibXML->new();
    $self->{doc} = $parser->parse_html_string($html);
}

sub delete {
    my $self = shift;
    delete $self->{$_} for keys %$self;
}

sub findnodes {
    my ($self, $xpath) = @_;

    my @nodes = $self->{doc}->findnodes( $xpath );
    return map { HTML::TreeBuilder::LibXML::Node->new($_) } @nodes;
}

sub replace_original {
    require HTML::TreeBuilder::XPath;
    no warnings 'redefine';
    *HTML::TreeBuilder::XPath::new = sub {
        HTML::TreeBuilder::LibXML->new(@_);
    };
}

1;
__END__

=head1 NAME

HTML::TreeBuilder::LibXML -

=head1 SYNOPSIS

  use HTML::TreeBuilder::LibXML;

=head1 DESCRIPTION

HTML::TreeBuilder::LibXML is drop-in-replacement version for HTML::TreeBuilder::XPath.

Currently, this module implements good enough methods for work with Web::Scraper.

=head1 AUTHOR

Tokuhiro Matsuno E<lt>tokuhirom  slkjfd gmail.comE<gt>

=head1 SEE ALSO

L<HTML::TreeBuilder>, L<HTML::TreeBuilder::XPath>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
