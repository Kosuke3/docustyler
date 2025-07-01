#!/usr/bin/env perl

use strict;
use warnings;
use utf8;
use open IO => ':encoding(UTF-8)';
binmode STDERR, ':encoding(UTF-8)';

my ($infile, $outfile) = @ARGV;
die "エラー：入・出力ファイル未設定\n" unless $infile && $outfile;
open my $in, '<:encoding(UTF-8)', $infile or die "読み込み失敗：$!\n";
open my $out, '>:encoding(UTF-8)', $outfile or die "書き込み失敗：$!\n";

while (my $line = <$in>) {
 # ---ステップ１：数字中の既存のカンマだけを除去---
 $line =~ s/(?<=\d),(?=\d)//g;
 
 # ---ステップ２：記号のうちドット「．（0x2E）」とカンマ「，（\x2C）」を除くものを全角に変換---
 $line =~ s/([\x21-\x2B\x2D\x2F\x3A-\x40\x5B-\x60\x7B-\x7E])/chr(0xFF00 + ord($1) - 0x20)/ge;
 
 # ---ステップ３：数字の桁区切りをつける。ただし、数字の後ろが「年」の場合は除外---
 $line =~ s/(\d{4,})(?!年)/add_commas($1)/ge;
 
 sub add_commas {
 	my $num = shift;
 	$num = reverse $num;
 	$num =~ s/(\d{3})(?=\d)/$1,/g;
 	return scalar reverse $num;
 }
 
 print $out $line;
}

close $in;
close $out;
