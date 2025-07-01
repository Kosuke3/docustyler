#!/usr/bin/env perl

use strict;
use warnings;
use utf8;
use open IO => ':encoding(UTF-8)';
binmode STDERR, ':encoding(UTF-8)';

my ($infile, $outfile) = @ARGV;
die "エラー：入・出力ファイル未設定\n" unless $infile && $outfile;
open my $in,  '<:encoding(UTF-8)', $infile or die  "読み込み失敗： $!\n";
open my $out, '>:encoding(UTF-8)', $outfile or die "書き込み失敗： $!\n";

while (my $line = <$in>) {
 # 改行コードの異常混入を除去
 $line =~ s/[\x{85}\x{2028}\x{2029}]//g;

 # 半角英数字・記号（U+0021〜U+007E）を全角に変換
 $line =~ s/([\x21-\x7E])/chr(0xFF00 + ord($1) - 0x20)/ge;

 print $out $line;
}

close $in;
close $out;
