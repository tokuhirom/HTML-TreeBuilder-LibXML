use strict;
use warnings;
use HTML::TreeBuilder::LibXML;
use Test::More;
use Data::Dumper;

my $original_ok = eval 'use HTML::TreeBuilder::XPath; 1';

my $tests = 11;
$tests *= 2 if $original_ok;
plan tests => $tests;

main('HTML::TreeBuilder::XPath')  if $original_ok;
main('HTML::TreeBuilder::LibXML');

sub main {
    my $klass = shift;
    diag $klass;

    my $tree = $klass->new;
    $tree->parse(q{
        <html>
            <head><title>test</title></head>
            <body>
            <a href="http://wassr.jp/">wassr</a>
            <div>
                <a href="http://mixi.jp/">mixi</a>
                ok.
            </div></body>
        </html>
    });
    my @nodes = $tree->findnodes('//a');

    is scalar(@nodes), 2;
    is $nodes[0]->attr('href'), 'http://wassr.jp/';
    ok !$nodes[0]->isTextNode;
    is $nodes[0]->string_value, 'wassr';
    is $nodes[0]->as_text, 'wassr';
    is strip($nodes[0]->as_XML), '<a href="http://wassr.jp/">wassr</a>';
    is strip($nodes[0]->clone->as_XML), '<a href="http://wassr.jp/">wassr</a>';
    is strip($nodes[0]->as_HTML), '<a href="http://wassr.jp/">wassr</a>';
    is $nodes[0]->tag, 'a';

    is $nodes[1]->attr('href'), 'http://mixi.jp/';

    $nodes[1]->delete;
    like strip($tree->as_HTML), qr{<html><head><title>test</title></head><body><a href="http://wassr.jp/">wassr</a><div>\s+ok.\s+</div></body></html>};

    $tree = $tree->delete;
}

sub strip {
    local $_ = shift;
    s/\n$//g;
    s/>\s+</></smg;
    $_;
}

