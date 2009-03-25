package HTML::TreeBuilder::LibXML;
use strict;
use warnings;
our $VERSION = '0.03';
use Carp ();
use base 'HTML::TreeBuilder::LibXML::Node';
use XML::LibXML;

sub new {
    my $class = shift;
    bless {}, $class;
}

sub parse {
    my ($self, $html) = @_;
    my $parser = XML::LibXML->new();
    $parser->recover(1);
    $parser->recover_silently(1);
    $parser->keep_blanks(0);
    $parser->expand_entities(1);
    $parser->no_network(1);
    my $doc = $parser->parse_html_string($html);
    $self->{node} = $doc->documentElement;
}

sub replace_original {
    require HTML::TreeBuilder::XPath;

    my $orig = HTML::TreeBuilder::XPath->can('new');

    no warnings 'redefine';
    *HTML::TreeBuilder::XPath::new = sub {
        HTML::TreeBuilder::LibXML->new();
    };

    if (defined wantarray) {
        return HTML::TreeBuilder::LibXML::Destructor->new(
            sub { *HTML::TreeBuilder::XPath::new = $orig } );
    }
    return;
}

package # hide from cpan
    HTML::TreeBuilder::LibXML::Destructor;

sub new {
    my ( $class, $callback ) = @_;
    bless { cb => $callback }, $class;
}

sub DESTROY {
    my $self = shift;
    $self->{cb}->();
}

1;
__END__

=head1 NAME

HTML::TreeBuilder::LibXML - HTML::TreeBuilder::XPath compatible interface with libxml

=head1 SYNOPSIS

    use HTML::TreeBuilder::LibXML;
    HTML::TreeBuilder::LibXML->replace_original(); # replace HTML::TreeBuilder::LibXML->new

=head1 DESCRIPTION

HTML::TreeBuilder is bit slow for some use case.
and, XML::LibXML is very fast!
I want to use it. But, some libraries uses HTML::TreeBuilder.

HTML::TreeBuilder::LibXML is drop-in-replacement for HTML::TreeBuilder::XPath.

Currently, this module implements good enough methods for work with Web::Scraper.


=head1 BENCHMARK

This is a benchmark result by tools/benchmark.pl

        Web::Scraper: 0.26
        HTML::TreeBuilder::XPath: 0.09
        HTML::TreeBuilder::LibXML: 0.01_01

                     Rate  no_libxml use_libxml
        no_libxml  5.45/s         --       -94%
        use_libxml 94.3/s      1632%         --

=head1 AUTHOR

Tokuhiro Matsuno E<lt>tokuhirom  slkjfd gmail.comE<gt>

=head1 THANKS TO

woremacx++
http://d.hatena.ne.jp/woremacx/20080202/1201927162

Tatsuhiko Miyagawa

id:dailyflower

=head1 SEE ALSO

L<HTML::TreeBuilder>, L<HTML::TreeBuilder::XPath>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
