use strict;
use warnings;
use Test::More;
use Test::Exception;
use HTML::TreeBuilder::LibXML;
use Data::Dumper;


my $tree = HTML::TreeBuilder::LibXML->new_from_content('<div class="foo"></div>');
my ($el) = $tree->guts;


$el->push_content('foo', scalar HTML::TreeBuilder::LibXML->new_from_content('<p>baz</p>')->guts, 'bar');
is $el->as_HTML, '<div class="foo">foo<p>baz</p>bar</div>', 'push_content';



done_testing;
