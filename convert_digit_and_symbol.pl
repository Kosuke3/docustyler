#!/use/bin/env perl

use strict;
use warnings;
use utf8;
use open IO => ':encoding(UTF-8)';
binmode STDERR, ':encoding(UTF-8)';

my ($infile, $outfile) = @ARGV;
die "エラー：入・出力ファイル未設定\n" unless $infile && $outfile;
open my $in, '<:encoding(UTF-8)', $infile or die "読み込み失敗：$!\n";
open my $out, '>:encoding(UTF-8)', $outfile or die "書き込み失敗：$!\n";

my @float_buffer;
my $token_id = 0;

while (my $line = <$in>) {

 # 小数点付き数字（例: 3.5）をプレースホルダに退避
 $line =~ s/(\d+\.\d+)/do {
 	my $token = "FLOAT" . chr(65 +$token_id); # 小数点を含む数値をFLOATA, FLOATB……と置換して保護
 	$float_buffer[$token_id++] = $1;
 	$token;
 }/ge;
 
 # 1桁の数字を全角に（前後が数字でないとき）
 $line =~ s/(?<!\d)(\d)(?!\d)/chr(0xFF10 + $1)/ge;
 
 # 記号（ドット「．」とカンマ「，」を除く ASCII 記号）を全角に
 $line =~ s/([\x21-\x2B\x2D\x2F\x3A-\x40\x5B-\x60\x7B-\x7E])/chr(0xFF00 + ord($1) - 0x20)/ge;

 
 # 小数点付き数字を復元
 for my $i (0 .. $#float_buffer) {
 	my $token = "FLOAT" . chr(65 + $i);
 	$line =~ s/$token/$float_buffer[$i]/g;
 }
 
 # 英字に挟まれた全角1桁数字を半角に戻す（例：PN１→PN1）
 $line =~ s/(?<=[A-Za-z])([０-９])/convert_to_half($1)/ge;
 $line =~ s/([０-９])(?=[A-Za-z])/convert_to_half($1)/ge;
 print $out $line;
}

close $in;
close $out;

sub convert_to_half {
 my $zen = shift;
 $zen =~ tr/０-９/0-9/;
 return $zen;
 }
 