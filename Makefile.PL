use inc::Module::Install;
name 'HTML-TreeBuilder-LibXML';
all_from 'lib/HTML/TreeBuilder/LibXML.pm';

requires 'HTML::TreeBuilder::XPath' => 0.11;
requires 'XML::LibXML' => 1.70;

tests 't/*.t';
author_tests 'xt';

build_requires 'Test::More';
WriteAll;
