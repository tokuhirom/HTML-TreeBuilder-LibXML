use strict;
use warnings;
use HTML::TreeBuilder::LibXML;
use Test::More;
use Data::Dumper;

my $original_ok = eval 'use HTML::TreeBuilder::XPath; 1';

my $tests = 26;
$tests *= 2 if $original_ok;
plan tests => $tests;

my $HTML = q{
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
<html>
    <head><title>test</title></head>
    <body>
    <a href="http://wassr.jp/">wassr</a>
    <div>
        <a href="http://mixi.jp/">mixi</a>
        ok.
    </div></body>
</html>
};

main('HTML::TreeBuilder::XPath')  if $original_ok;
main('HTML::TreeBuilder::LibXML');

sub main {
    my $klass = shift;
    diag $klass;
    _simple($klass);
    _no_eof($klass);
    _look_down($klass);
    _id($klass);
}

sub _simple {
    my $klass = shift;

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
    $tree->eof;
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

    my %attr = $nodes[0]->all_external_attr;
    is_deeply \%attr, { href => "http://wassr.jp/" };
    is_deeply [ $nodes[0]->all_external_attr_names ], [ 'href' ];

    is $nodes[1]->attr('href'), 'http://mixi.jp/';

    $nodes[1]->delete;
    like strip($tree->as_HTML), qr{<html><head><title>test</title></head><body><a href="http://wassr.jp/">wassr</a><div>\s+ok.\s+</div></body></html>};
    
    is $tree->findvalue('//a[@href="http://wassr.jp/"]/@href'), 'http://wassr.jp/';

    $tree = $tree->delete;

}

sub _no_eof {
    my $klass = shift;
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
    $tree = $tree->delete;
}

sub _look_down {
    my $klass = shift;

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
    $tree->eof;
    {
        my @nodes = $tree->look_down('_tag' => 'a');
        is scalar(@nodes), 2;
        is $nodes[0]->attr('href'), 'http://wassr.jp/';
    }
    {
        my @nodes = $tree->look_down(href => qr/mixi/);
        is scalar(@nodes), 1;
        is $nodes[0]->attr('href'), 'http://mixi.jp/';
    }
    {
        my @nodes = $tree->look_down('_tag' => 'a', sub { $_[0]->attr('href') =~ /mixi/ });
        is scalar(@nodes), 1;
        is $nodes[0]->attr('href'), 'http://mixi.jp/';
    }
    {
        my $none = $tree->look_down('_tag' => 'a', sub { 0 });
        ok !defined $none, "none because sub ref returns 0";
    }

    $tree = $tree->delete;
}

sub _id {
    my $klass = shift;

    my $tree = $klass->new;
    $tree->parse($HTML);
    $tree->eof;

    my ($a) = $tree->look_down('_tag' => 'a');
    is $a->id, undef;
    $a->id("OK");
    is $a->id, 'OK';
    is strip($a->as_HTML), '<a href="http://wassr.jp/" id="OK">wassr</a>';
    $a->id(undef);
    is strip($a->as_HTML), '<a href="http://wassr.jp/">wassr</a>';

    $tree = $tree->delete;
}

sub strip {
    local $_ = shift;
    s/\n$//g;
    s/>\s+</></smg;
    $_;
}

