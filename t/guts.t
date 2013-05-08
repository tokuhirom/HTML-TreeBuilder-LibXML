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
 

done_testing;
