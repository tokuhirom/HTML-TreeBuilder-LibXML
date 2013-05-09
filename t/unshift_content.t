use strict;
use warnings;
use Test::More;
use Test::Exception;
use HTML::TreeBuilder::LibXML;
use Data::Dumper;


my $tree = HTML::TreeBuilder::LibXML->new_from_content('<div class="foo">STUFF</div>');
my ($el) = $tree->guts;


$el->unshift_content('foo', scalar HTML::TreeBuilder::LibXML->new_from_content('<p>baz</p>')->guts, 'bar');
is $el->as_HTML, '<div class="foo">foo<p>baz</p>barSTUFF</div>', 'unshift_content';



done_testing;
