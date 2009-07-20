package HTML::TreeBuilder::LibXML;
use strict;
use warnings;
our $VERSION = '0.07';
use Carp ();
use base 'HTML::TreeBuilder::LibXML::Node';
use XML::LibXML;

sub new {
    my $class = shift;
    bless {}, $class;
}

sub new_from_content {
    my $class = shift;
    my $self  = $class->new;
    for my $content (@_) {
        $self->parse($content);
    }
    $self->eof;

    return $self;
}

sub new_from_file {
    my $class = shift;
    my $self  = $class->new;
    $self->parse_file(@_);
    return $self;
}

my $PARSER;
sub _parser {
    unless ($PARSER) {
        $PARSER = XML::LibXML->new();
        $PARSER->recover(1);
        $PARSER->recover_silently(1);
        $PARSER->keep_blanks(0);
        $PARSER->expand_entities(1);
        $PARSER->no_network(1);
    }
    $PARSER;
}

sub parse {
    my ($self, $html) = @_;
    $self->{_content} .= $html;
}

sub parse_file {
    my $self = shift;
    my $doc  = $self->_parser->parse_html_file(@_);
    $self->{node} = $doc->documentElement;
}

sub eof {
    my ($self, ) = @_;
    my $doc = $self->_parser->parse_html_string($self->{_content});
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
    HTML::TreeBuilder::LibXML->replace_original(); # replace HTML::TreeBuilder::XPath->new

=head1 DESCRIPTION

HTML::TreeBuilder is bit slow for some use case.
and, XML::LibXML is very fast!
I want to use it. But, some libraries uses HTML::TreeBuilder.

HTML::TreeBuilder::LibXML is drop-in-replacement for HTML::TreeBuilder::XPath.

Currently, this module implements good enough methods for work with Web::Scraper.

=head1 TODO

    12:39  miyagawa:> tokuhirom_______: HTML::TreeBuilder::LibXML で->eofがない
    12:40  miyagawa:> ほかにもありそうだけど
    12:43  miyagawa:> あと look_down と findvalue
    12:43  miyagawa:> が Remedie/Plagger でつかわれてる。

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
