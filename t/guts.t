use strict;
use warnings;
use Test::More;
use HTML::TreeBuilder::LibXML;
use Data::Dumper;

my $tree = HTML::TreeBuilder::LibXML->new_from_content('<header>foo</header><footer>bar</footer>');

is join('|', map {$_->as_HTML} $tree->guts), '<header>foo</header>|<footer>bar</footer>', 'guts - list context';

my $guts = $tree->guts;

isa_ok $guts->{node}->ownerDocument, 'XML::LibXML::Document';
is $guts->as_HTML, '<div><header>foo</header><footer>bar</footer></div>', 'guts - scalar context';

# guts() must return tags from implicit <head> as well
my @nodes = HTML::TreeBuilder::LibXML->new_from_content('<title>head tag</title><div>body tag</div>')->guts;
is join('|', map {$_->as_HTML} @nodes), '<title>head tag</title>|<div>body tag</div>';


# guts must include text and comments
@nodes = HTML::TreeBuilder::LibXML->new_from_content('<title>head tag</title><!-- foo --><div>body tag</div><!-- bar --> some text')->guts;
is join('|', map {$_->as_HTML} @nodes), "<title>head tag</title>|<!-- foo -->\n|<div>body tag</div>|<!-- bar -->\n| some text";




done_testing;
