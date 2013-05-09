use strict;
use warnings;
use Test::More;
use Test::Exception;
use HTML::TreeBuilder::LibXML;
use Data::Dumper;


my $tree = HTML::TreeBuilder::LibXML->new_from_content('<div class="foo"><p>bar</p></div>');
my ($div) = $tree->guts;
my ($p) = $div->findnodes('//p');

$p->replace_with('foo', scalar HTML::TreeBuilder::LibXML->new_from_content('<p>baz</p>')->guts, 'bar');
is $div->as_HTML, '<div class="foo">foo<p>baz</p>bar</div>', 'replace_with';


done_testing;
