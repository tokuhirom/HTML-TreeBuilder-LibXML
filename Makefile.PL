use inc::Module::Install;
name 'HTML-TreeBuilder-LibXML';
all_from 'lib/HTML/TreeBuilder/LibXML.pm';

requires 'HTML::TreeBuilder::XPath' => 0.14;
requires 'XML::LibXML' => 1.70;

tests 't/*.t';
author_tests 'xt';

test_requires 'Test::More' => 0.98;
WriteAll;
