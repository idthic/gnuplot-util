# gnuplot library -*- mode: sh -*-

set encoding utf8
strmath_font_mathrm = 'Times'
strmath_font_mathit = 'Times:Italic'
strmath_font_mathbm = 'Times:Italic:Bold'
strmath_font_mathtt = 'monospace'

strmath_font_setup_times = " \
  strmath_font_mathrm = 'Times'; \
  strmath_font_mathit = 'Times:Italic'; \
  strmath_font_mathbm = 'Times:Italic:Bold' "

strmath_font_setup_sans = " \
  strmath_font_mathrm = 'sans-serif'; \
  strmath_font_mathit = 'sans-serif:Italic'; \
  strmath_font_mathbm = 'sans-serif:Bold' "

strmath_font_setup_aghtex = " \
  strmath_font_mathrm = 'aghtex_mathrm'; \
  strmath_font_mathit = 'aghtex_mathit'; \
  strmath_font_mathbm = 'aghtex_mathbm' "

strmath_font_setup_cmu = " \
  strmath_font_mathrm = 'CMU-Serif'; \
  strmath_font_mathit = 'CMU-Serif:Italic'; \
  strmath_font_mathbm = 'CMU-Serif:BoldItalic' "

strmath_font_setup_cmu_sans = " \
  strmath_font_mathrm = 'CMU-Sans-Serif'; \
  strmath_font_mathit = 'CMU-Sans-Serif:Italic'; \
  strmath_font_mathbm = 'CMU-Sans-Serif:Bold' "

# Note: gnuplot 5.2.4 では strstrt が文字数ではなくバイト数を返す為に '〉' が空
#   文字列に置換されてしまう。5.4 のマニュアルには strstrt("αβ", "β") の例が
#   載っているが 5.2 には載っていない。"gnuplot-5.(奇数)" は開発版の様で、5.3
#   のマニュアルは見つけられなかった。

mwg_min(x, y) = y < x ? y : x;
mwg_max(x, y) = y > x ? y : x;
mwg_strspn_generic(str, str_len, chars, yes) = \
  str_len <= 0 || !strstrt(chars, substr(str, 1, 1)) == yes ? 0 : \
  1 + mwg_strspn_generic(substr(str, 2, str_len), str_len - 1, chars, yes);
mwg_strspn_n(str, str_len, chars) = mwg_strspn_generic(str, str_len, chars, 1);
mwg_strcspn_n(str, str_len, chars) = mwg_strspn_generic(str, str_len, chars, 0);

# @fn mwg_index (現在未使用)
# strstrt は UTF-8 に対応していないので自前で二分探索
mwg_index(str, needle) = \
  mwg_index_1(str, strlen(str), needle, strlen(needle), strstrt(str, needle));
mwg_index_1(str, str_len, needle, needle_len, index) = \
  index == 0 ? index : mwg_index_2(str, str_len, needle, needle_len);
mwg_index_2(str, str_len, needle, needle_len) = \
  str_len == needle_len ? 1 : \
  mwg_index_3(str, str_len, needle, needle_len, (str_len - needle_len + 1) / 2);
mwg_index_3(str, str_len, needle, needle_len, split) = \
  mwg_index_4(str, str_len, needle, needle_len, split, substr(str, 1, split + needle_len - 1), split + needle_len - 1);
mwg_index_4(str, str_len, needle, needle_len, split, left, left_len) = \
  strstrt(left, needle) != 0 ? \
  mwg_index_2(left, left_len, needle, needle_len) : \
  split + mwg_index_2(substr(str, split + 1, str_len), str_len - split, needle, needle_len);

#------------------------------------------------------------------------------
# strmath_tok

strmath_symbol_minus = '−'
strmath_symbol_langle = '⟨'
strmath_symbol_rangle = '⟩'
strmath_symbol_quad = '&{m}'
strmath_symbol_qquad = '&{mm}'
strmath_chars_blank = " \t\n"

strmath_tok__LOWER = "abcdefghijklmnopqrstuvwxyz";
strmath_tok__UPPER = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
strmath_tok__LOWERGREEK = "αβγδεζηθικλμνξοπρστυφχψωϕ";
strmath_tok__ALPHA = strmath_tok__LOWER . strmath_tok__UPPER;
strmath_tok__ITALIC = strmath_tok__ALPHA . strmath_tok__LOWERGREEK;
strmath_tok__TEXTDELIM = '$';
strmath_tok__MATHDELIM = '$-〈〉';
strmath_tok__MATHDELIM_SYMBOL = '$−⟨⟩';

strmath_tok_find_cmd(tail, tail_len) = tail_len < 2 || substr(tail, 1, 1) ne '\' ? 0 : \
  1 + mwg_max(1, mwg_strspn_n(substr(tail, 2, tail_len), tail_len - 1, strmath_tok__ALPHA));
strmath_tok_find_del(tail, tail_len) = tail_len == 0 ? 0 : strstrt(strmath_tok__MATHDELIM, substr(tail, 1, 1));
strmath_tok_find_italic(tail, tail_len) = mwg_strspn_n(tail, tail_len, strmath_tok__ITALIC);
strmath_tok_find_raw(tail, tail_len) = mwg_strcspn_n(tail, tail_len, '\' . strmath_tok__MATHDELIM . strmath_tok__ITALIC)
strtext_tok_find_del(tail, tail_len) = tail_len == 0 ? 0 : strstrt(strmath_tok__TEXTDELIM, substr(tail, 1, 1));
strtext_tok_find_raw(tail, tail_len) = mwg_strcspn_n(tail, tail_len, '\' . strmath_tok__TEXTDELIM)

strmath_tok_del2symbol(del_idx) = \
  substr(strmath_tok__MATHDELIM_SYMBOL, del_idx, del_idx);

strmath_tok_read_arg(tail, tail_len) = strmath_tok_read_arg_1(tail, tail_len, mwg_strspn_n(tail, tail_len, strmath_chars_blank));
strmath_tok_read_arg_1(tail, tail_len, skip) = \
  tail_len <= skip ? 0 : \
  skip + 2 <= tail_len && substr(tail, skip + 1, skip + 1) eq '\' ? skip + strmath_tok_find_cmd(substr(tail, skip + 1, tail_len), tail_len - skip) : \
  skip + mwg_max(1, strmath_tok_read_brace(substr(tail, skip + 1, tail_len), tail_len - skip, '{', '}'));

strmath_tok_read_brace(str, str_len, open, clos) = \
  str_len < 1 || substr(str, 1, 1) ne open ? 0 : \
  strmath_tok_read_brace_1(str, str_len, open, clos, 2, 1);
strmath_tok_read_brace_1(str, str_len, open, clos, index, depth) = \
  str_len < index ? -depth : \
  strmath_tok_read_brace_2(str, str_len, open, clos, index, depth, substr(str, index, index));
strmath_tok_read_brace_2(str, str_len, open, clos, index, depth, ch) = \
  ch eq clos ? ( \
    depth <= 1 ? index : \
    strmath_tok_read_brace_1(str, str_len, open, clos, index + 1, depth - 1)) : \
  ch eq open ? ( \
    strmath_tok_read_brace_1(str, str_len, open, clos, index + 1, depth + 1)) : \
  strmath_tok_read_brace_1(str, str_len, open, clos, index + 1, depth);

#------------------------------------------------------------------------------

strmath_TTFONTSIZE='=10'

strmath_process_cmd_narg(cmdname, cmd_len) = \
  cmd_len == 3 && (cmdname eq '\rm' || cmdname eq '\tt' || cmdname eq '\bm') ? 1 : \
  cmd_len == 7 && (cmdname eq '\mathrm' || cmdname eq '\mathtt' || cmdname eq '\mathbm') ? 1 : \
  0;

strmath_process_cmd1(cmdname, tail, tail_len) = \
  strmath_process_cmd1_1(cmdname, tail, tail_len, strmath_tok_read_arg(tail, tail_len));
strmath_process_cmd1_1(cmdname, tail, tail_len, arg_len) = \
  strmath_process_cmd1_2(cmdname, substr(tail, 1 + mwg_strspn_n(tail, tail_len, strmath_chars_blank), arg_len), substr(tail, arg_len + 1, tail_len), tail_len - arg_len);
strmath_process_cmd1_2(cmdname, arg, tail2, tail2_len) = ( \
  cmdname eq '\rm' || cmdname eq '\mathrm' ? arg : \
  cmdname eq '\tt' || cmdname eq '\mathtt' ? '{/'.strmath_font_mathtt.' '. strmath_TTFONTSIZE . ' ' . arg . '}' : \
  cmdname eq '\bm' || cmdname eq '\mathbm' ? '{/'.strmath_font_mathbm.' ' . arg . '}' : \
  strmath(arg)) . strmath_1(tail2, tail2_len);


# &{\U+2006} ... 1/6 em  = 0.1667em
# &{\U+2009} ... 1/5 em  = 0.2000em
# &{\U+205F} ... 4/18 em = 0.2222em
# &{\U+2005} ... 1/4 em  = 0.2500em
# &{\U+2004} ... 1/3 em  = 0.3333em

strmath_process_cmd(cmdname, cmd_len, tail, tail_len) = \
  strmath_process_cmd_narg(cmdname, cmd_len) == 1 ? strmath_process_cmd1(cmdname, tail, tail_len) : \
  ( \
    cmd_len == 2 ? ( \
      cmdname eq '\\' ? "\n" : \
      cmdname eq '\,' ? "&{\U+2006}" : \
      cmdname eq '\:' ? "&{\U+205F}" : \
      cmdname eq '\;' ? "&{\U+2005}" : \
      cmdname \
    ) : \
    cmdname eq '\phi' ? '{/'.strmath_font_mathit.' ϕ}' : \
    cmdname eq '\quad' ? strmath_symbol_quad : \
    cmdname eq '\qquad' ? strmath_symbol_qquad : \
    cmdname eq '\langle' ? strmath_symbol_langle : \
    cmdname eq '\rangle' ? strmath_symbol_rangle : \
    cmdname \
  ) . strmath_1(tail, tail_len);

strmath_process_italic(value, tail, tail_len) = '{/'.strmath_font_mathit.' ' . value . '}' . strmath_1(tail, tail_len);

strmath_process_del(delname, del_idx, tail, tail_len) = \
  delname eq '$' ? '}'.strtext_1(tail, tail_len) : \
  strmath_tok_del2symbol(del_idx) . strmath_1(tail, tail_len);

strmath(str) = '{/'.strmath_font_mathrm.' '.strmath_1(str, strlen(str));
strmath_1(str, str_len) = str_len <= 0 ? '}' : \
  strmath_2(str, str_len, \
    strmath_tok_find_cmd(str, str_len), \
    strmath_tok_find_italic(str, str_len), \
    strmath_tok_find_del(str, str_len), \
    strmath_tok_find_raw(str, str_len));
strmath_2(str, str_len, cmd_len, it_len, del_idx, raw_len) = \
  cmd_len != 0 ? strmath_process_cmd(substr(str, 1, cmd_len), cmd_len, substr(str, cmd_len + 1, str_len), str_len - cmd_len) : \
  it_len  != 0 ? strmath_process_italic(substr(str, 1, it_len), substr(str, it_len + 1, str_len), str_len - it_len) : \
  del_idx != 0 ? strmath_process_del(substr(str, 1, 1), del_idx, substr(str, 2, str_len), str_len - 1) : \
  raw_len != 0 ? substr(str, 1, raw_len) . strmath_1(substr(str, raw_len + 1, str_len), str_len - raw_len) : \
  substr(str, 1, 1) . strmath_1(substr(str, 2, str_len), str_len - 1);

strtext_process_cmd1(cmdname, tail, tail_len) = \
  strtext_process_cmd1_1(cmdname, tail, tail_len, strmath_tok_read_arg(tail, tail_len));
strtext_process_cmd1_1(cmdname, tail, tail_len, arg_len) = \
  strtext_process_cmd1_2(cmdname, substr(tail, 1 + mwg_strspn_n(tail, tail_len, strmath_chars_blank), arg_len), substr(tail, arg_len + 1, tail_len), tail_len - arg_len);
strtext_process_cmd1_2(cmdname, arg, tail2, tail2_len) = ( \
  cmdname eq '\rm' || cmdname eq '\textrm' ? arg : \
  cmdname eq '\tt' || cmdname eq '\texttt' ? '{/'.strmath_font_mathtt.strmath_TTFONTSIZE.' ' . arg . '}' : \
  strtext(arg)) . strtext_1(tail2, tail2_len);

strtext_process_cmd(cmdname, tail, tail_len) = \
  cmdname eq '\\' ? "\n" . strtext_1(tail, tail_len) : \
  cmdname eq '\rm' || cmdname eq '\textrm' || cmdname eq '\tt' || cmdname eq '\texttt' ? strtext_process_cmd1(cmdname, tail, tail_len) : \
  cmdname . strtext_1(tail, tail_len);

strtext_process_del(delname, del_idx, tail, tail_len) = \
  delname eq '$' ? '{/'.strmath_font_mathrm.' '.strmath_1(tail, tail_len) : \
  delname . strtext_1(tail, tail_len);

strtext(str) = strtext_1(str, strlen(str));
strtext_1(str, str_len) = str_len == 0 ? '' : \
  strtext_2(str, str_len, \
    strmath_tok_find_cmd(str, str_len), \
    strtext_tok_find_del(str, str_len), \
    strtext_tok_find_raw(str, str_len));
strtext_2(str, str_len, cmd_len, del_idx, raw_len) = \
  cmd_len != 0 ? strtext_process_cmd(substr(str, 1, cmd_len), substr(str, cmd_len + 1, str_len), str_len - cmd_len) : \
  del_idx != 0 ? strtext_process_del(substr(str, 1, 1), del_idx, substr(str, 2, str_len), str_len - 1) : \
  raw_len != 0 ? substr(str, 1, raw_len) . strtext_1(substr(str, raw_len + 1, str_len), str_len - raw_len) : \
  substr(str, 1, 1) . strtext_1(str, 2, str_len - 1);

strtex(str) = strtext(str)

# 実験1
#
#   a = 10;
#   f1(x, y, a) = (a = 3, a*a)
#   print f1(1,2,0); print a
#
#   0
#   3
#
#   関数内での代入はグローバル変数に対する代入になる。
#   代入以外では引数の変数を参照する。
#
# print strmath('τ_{\mathrm{D}}')
# print strmath('τ_{\mathrm D}')
# print strmath('τ_{\mathrm#a}')
