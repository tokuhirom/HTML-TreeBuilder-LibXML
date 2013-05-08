use strict;
use warnings;
use Test::More;
use Test::Exception;
use HTML::TreeBuilder::LibXML;
use Data::Dumper;

my $tree = HTML::TreeBuilder::LibXML->new_from_content('<div>foo</div>');
my ($div) = $tree->guts;


# get parent
isa_ok $div->parent, 'HTML::TreeBuilder::LibXML::Node', 'parent()';
is $div->parent->as_HTML, '<body><div>foo</div></body>', 'parent()->as_HTML';

# unset parent
$div->parent(undef);
is $div->parent, undef;

# set parent
dies_ok { $div->parent($div) } "can't set itself as parent";
 








done_testing;
