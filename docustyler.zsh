#!/bin/zsh

# ---使用スクリプト---
# docustyler.zsh 本スクリプト
# normalize_ascii.pl
# convert_fullwidth.lp
# convert_number.pl
# convert_digit_and_symbol.pl
# convert_symbol_only.pl
# replace_terms.pl

# ---基本設定---
script_dir="${0:A:h}"
input_file="$1"
dict_file="$2"
mode="$3"

if [[ -z "$input_file" || -z "$mode" ]]; then
 echo "使い方：$0 入力ファイル ［辞書ファイル］ モード（縦|横|半）"
 exit 1
fi

 # ---ステップ0：事前クリーニング（原稿内の全角英数字とカンマを一旦半角に統一）---
 tmp_cleaned="tmp_cleaned.txt"
 
  echo -n "🧹クリーニング実行中..."
  perl "$script_dir/normalize_ascii.pl" "$input_file" "$tmp_cleaned"
   
# ---ステップ1：特定表記のゼロ埋め---
tmp1="tmp_timefix.txt"
sed -E '
 s/([0-9]{1,2}分)([0-9])秒([0-9]+)/\10\2秒\3/g;
 s/([^0-9]|^)([0-9])秒([0-9]+)/\10\2秒\3/g;
 s/([^0-9]|^)([0-9])秒台/\10\2秒台/g;
' "$tmp_cleaned" > "$tmp1"

# ---ステップ2：文字種変換---
tmp2="tmp_fullwidth.txt"
case "$mode" in
 縦) echo -n " ✏️ 縦モードで変換中..." 
     perl "$script_dir/convert_fullwidth.pl" "$tmp1" "$tmp2" ;;
 横) echo -n " ✏️ 横モードで変換中..."
    perl "$script_dir/convert_digit_and_symbol.pl" "$tmp1" "$tmp2" ;;
 半) echo -n " ✏️ 半モードで変換中..."
    perl "$script_dir/convert_symbol_only.pl" "$tmp1" "$tmp2" ;;
 *)
  echo "モード指定エラー：モードは縦/横/半のいずれかを指定"
  rm -f "$tmp1"
  exit 1
  ;;
esac

# ---ステップ3：縦モードの2桁全角数字の半角化---
tmp3="tmp_number.txt"
if [[ "$mode" == "縦" ]]; then
 perl "$script_dir/convert_number.pl" "$tmp2" "$tmp3"
else
 cp "$tmp2" "$tmp3"
fi

# ---ステップ4：出力ファイル名を決定---
output_file="${input_file:r}_comverted{$mode}.txt"

# ---ステップ5：用語統一辞書を適用---
if [[ -n "$dict_file" ]]; then
 echo " 📚 用語統一処理中..."
 perl "$script_dir/replace_terms.pl" "$tmp3" "$dict_file" "$output_file"
else
 echo "（用語統一処理なし）"
 mv "$tmp3" "$output_file"
fi

# ---後始末---
rm -f "$tmp_cleaned" "$tmp1" "$tmp2" "$tmp3"

# ---完了メッセージ---
echo "✅️処理完了： $output_file を出力しました"
