#!/usr/bin/env perl

use strict;
use warnings;
use utf8;
binmode STDERR, ':encoding(UTF-8)';

my ($infile, $outfile) = @ARGV;
die "エラー：入・出力ファイル未設定\n" unless $infile && $outfile;
open my $in, '<:utf8', $infile or die "読み込み失敗：$!\n";
open my $out, '>:utf8', $outfile or die "書き込み失敗：$!\n";

while (my $line = <$in>) {
 $line =~ s/(?<![０-９])([０-９]{2})(?![０-９])/convert_to_hankaku($1)/ge;
 print $out $line;
 }

close $in;
close $out;

sub convert_to_hankaku {
 my $zen = shift;
 $zen =~ tr/０-９/0-9/;
 return $zen;
}