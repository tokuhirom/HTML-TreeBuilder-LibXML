use inc::Module::Install;
name 'HTML-TreeBuilder-LibXML';
all_from 'lib/HTML/TreeBuilder/LibXML.pm';

requires 'XML::LibXML' => 1.69;

tests 't/*.t';
author_tests 'xt';

build_requires 'Test::More';
use_test_base;
auto_include;
WriteAll;
