use strict;
use warnings;
use Test::More tests => 1;
use HTML::TreeBuilder::LibXML;

eval { HTML::TreeBuilder::LibXML->traverse() };
like $@, qr{not implemented};
