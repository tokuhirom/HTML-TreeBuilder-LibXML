use strict;
use warnings;
use Test::More;
use HTML::TreeBuilder::LibXML;
use Data::Dumper;

# list context
my $tree = HTML::TreeBuilder::LibXML->new_from_content('<header>foo</header><footer>bar</footer>');

my @nodes = $tree->disembowel;
is join('|', map {$_->as_HTML} @nodes), '<header>foo</header>|<footer>bar</footer>', 'disembowel - list context';

isa_ok $nodes[0]->parent->{node}, 'XML::LibXML::Document', 'node parent';



# scalar context
$tree = HTML::TreeBuilder::LibXML->new_from_content('<header>foo</header><footer>bar</footer>');

my $node = $tree->disembowel;
is $node->as_HTML, '<div><header>foo</header><footer>bar</footer></div>', 'disembowel - scalar context';

isa_ok $node->parent->{node}, 'XML::LibXML::Document', 'node parent';


 

done_testing;
