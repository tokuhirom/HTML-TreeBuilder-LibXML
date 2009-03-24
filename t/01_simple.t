use strict;
use warnings;
use HTML::TreeBuilder::LibXML;
use Test::More;

my $original_ok = eval 'use HTML::TreeBuilder::XPath; 1';

my $tests = 8;
$tests *= 2 if $original_ok;
plan tests => $tests;

main('HTML::TreeBuilder::LibXML');
main('HTML::TreeBuilder::XPath')  if $original_ok;

sub main {
    my $klass = shift;
    my $tree = $klass->new;
    $tree->parse(q{
        <html>
            <a href="http://wassr.jp/">wassr</a>
            <div>
                <a href="http://mixi.jp/">mixi</a>
            </div>
        </html>
    });
    my @nodes = $tree->findnodes('//a');

    is scalar(@nodes), 2;
    is $nodes[0]->attr('href'), 'http://wassr.jp/';
    ok !$nodes[0]->isTextNode;
    is $nodes[0]->string_value, 'wassr';
    is $nodes[0]->as_text, 'wassr';
    is strip($nodes[0]->as_XML), '<a href="http://wassr.jp/">wassr</a>';
    is $nodes[0]->tag, 'a';

    is $nodes[1]->attr('href'), 'http://mixi.jp/';

    $tree = $tree->delete;
}

sub strip {
    local $_ = shift;
    s/\n$//;
    $_;
}

