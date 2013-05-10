use strict;
use warnings;
use Test::More;
use Test::Exception;
use HTML::TreeBuilder::LibXML;
use Data::Dumper;


my $tree = HTML::TreeBuilder::LibXML->new_from_content('<div class="foo"><p>bar</p></div>');
my ($el) = $tree->guts;
my ($p) = $el->findnodes('./p');

my $parent = $p->detach;

is $parent->as_HTML, '<div class="foo"/>', 'detach returns old parent';
is $p->parent, undef, 'detached element has no parent anymore';
isa_ok $p->{node}->parentNode, 'XML::LibXML::DocumentFragment', 'its now in a document fragment';

done_testing;
