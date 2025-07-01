#!/usr/bin/env perl

use strict;
use warnings;
use utf8;
use open IO => ':encoding(UTF-8)';
binmode STDERR, ':encoding(UTF-8)';

# ---引数チェック---
my ($infile, $dictfile, $outfile) = @ARGV;
die "使い方：$0 input.txt dic_file.txt output.txt\n" unless $infile && $dictfile && $outfile;

# ---置換用リスト---
my (@protect, @general, @restore);

# ---辞書ファイル読み込み---
open my $dict_fh, '<', $dictfile or die "辞書ファイルを開けません：$!\n";
while (my $line = <$dict_fh>) {
 chomp $line;
 next if $line =~ /^\s*$/;   # 空行スキップ
 next if $line =~ /^\s*#/;   # コメントスキップ
 
 my @cols = split /\t/, $line;
 
 # ---引数チェック---
 if (@cols == 3) {
 	my ($label, $from, $to) = @cols;
 	if ($label eq 'P') {
 		push @protect, [$from, $to];
 	} elsif ($label eq 'R') {
 		push @restore, [$from, $to];
 	} elsif ($label eq '') {
 		push @general, [$from, $to];
 	} else {
 		warn "規定外のラベル：$label\n";
 	}
 } elsif (@cols == 2) {
 	my ($from, $to) = @cols;
 	push @general, [$from, $to];
 } else {
 	warn "無効な行形式：$line\n";
 } 
}
close $dict_fh;

# ---入出力ファイルの処理---
open my $in_fh, '<', $infile or die "読み込み失敗：$!\n";
open my $out_fh, '>', $outfile or die "書き込み失敗：$!\n";

while (my $line = <$in_fh>) {
 # ---protect：保護するフレーズを仮コードに変換---
 for my $pair (@protect) {
 	my ($from, $to) = @$pair;
 	$line =~ s/\Q$from\E/$to/g;
 }
 
 # ---general：通常の用語変換---
 for my $pair (@general) {
 	my ($from, $to) = @$pair;
 	$line =~ s/\Q$from\E/$to/g;
 }
 
 # ---restore：仮コードに変換した保護するフレーズを展開---
 for my $pair (@restore) {
 	my ($from, $to) = @$pair;
 	$line =~ s/\Q$from\E/$to/g;
 }
 
 print $out_fh $line;
}

close $in_fh;
close $out_fh;
