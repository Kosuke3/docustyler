#!/usr/bin/env perl

use strict;
use warnings;
use utf8;
use open IO => 'encoding(UTF-8)';
binmode STDERR, ':encoding(UTF-8)';

my ($infile, $outfile) = @ARGV;
die "エラー：入・出力ファイル未設定\n" unless $infile && $outfile;
open my $in, '<:utf8', $infile or die "読み込み失敗：$!\n";
open my $out, '>:utf8', $outfile or die "書き込み失敗：$!\n";

while (my $line = <$in>) {
 # 全角英数字とカンマ→半角（その他の記号はそのまま）
 $line =~ tr/Ａ-Ｚａ-ｚ０-９/A-Za-z0-9/;
 $line =~ tr/，/,/;

 print $out $line;
 }

close $in;
close $out;
