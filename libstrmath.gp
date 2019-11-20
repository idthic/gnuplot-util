# gnuplot library -*- mode: sh -*-

mwg_min(x, y) = y < x ? y : x;
mwg_max(x, y) = y > x ? y : x;
mwg_strcspn_n(str, str_len, chars) = \
  str_len <= 0 || strstrt(chars, substr(str, 1, 1)) == 0 ? 0 : \
  1 + mwg_strcspn_n(substr(str, 2, str_len), str_len - 1, chars);
strmath_symbol_minus = '−'
strmath_symbol_langle = '⟨'
strmath_symbol_rangle = '⟩'
strmath_chars_blank = " \t\n"
strmath_chars_lower = "abcdefghijklmnopqrstuvwxyz";
strmath_chars_upper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
strmath_chars_lower_greek = "αβγδεζηθικλμνξοπρστυφχψω";
strmath_chars_alpha = strmath_chars_lower . strmath_chars_upper;
strmath_chars_italic_target = strmath_chars_alpha . strmath_chars_lower_greek;

strmath_arg_find(tail, tail_len) = strmath_arg_find_1(tail, tail_len, mwg_strcspn_n(tail, tail_len, strmath_chars_blank));
strmath_arg_find_1(tail, tail_len, skip) = \
  tail_len <= skip ? 0 : \
  skip + 2 <= tail_len && substr(tail, skip + 1, skip + 1) eq '\' ? skip + strmath_cmd_find(substr(tail, skip + 1, tail_len), tail_len - skip) : \
  skip + mwg_max(1, strmath_brace_find(substr(tail, skip + 1, tail_len), tail_len - skip, '{', '}'));
strmath_brace_find(str, str_len, open, clos) = \
  str_len < 1 || substr(str, 1, 1) ne open ? 0 : \
  strmath_brace_find_1(str, str_len, open, clos, 2, 1);
strmath_brace_find_1(str, str_len, open, clos, index, depth) = \
  str_len < index ? -depth : \
  strmath_brace_find_2(str, str_len, open, clos, index, depth, substr(str, index, index));
strmath_brace_find_2(str, str_len, open, clos, index, depth, ch) = \
  ch eq clos ? ( \
    depth <= 1 ? index : \
    strmath_brace_find_1(str, str_len, open, clos, index + 1, depth - 1)) : \
  ch eq open ? ( \
    strmath_brace_find_1(str, str_len, open, clos, index + 1, depth + 1)) : \
  strmath_brace_find_1(str, str_len, open, clos, index + 1, depth);

strmath_TTFONTSIZE='=10'
strmath_cmd1_process(cmdname, tail, tail_len) = \
  strmath_cmd1_process_1(cmdname, tail, tail_len, strmath_arg_find(tail, tail_len));
strmath_cmd1_process_1(cmdname, tail, tail_len, arg_len) = \
  strmath_cmd1_process_2(cmdname, substr(tail, 1 + mwg_strcspn_n(tail, tail_len, strmath_chars_blank), arg_len), substr(tail, arg_len + 1, tail_len), tail_len - arg_len);
strmath_cmd1_process_2(cmdname, arg, tail2, tail2_len) = ( \
  cmdname eq '\rm' ? arg : \
  cmdname eq '\tt' ? '{/monospace'.strmath_TTFONTSIZE.' ' . arg . '}' : \
  strmath(arg)) . strmath_1(tail2, tail2_len);

strmath_cmd_find(tail, tail_len) = tail_len < 2 || substr(tail, 1, 1) ne '\' ? 0 : \
  1 + mwg_max(1, mwg_strcspn_n(substr(tail, 2, tail_len), tail_len - 1, strmath_chars_alpha));
strmath_cmd_process(value, tail, tail_len) = \
  value eq '\langle' ? strmath_symbol_langle . strmath_1(tail, tail_len): \
  value eq '\rangle' ? strmath_symbol_rangle . strmath_1(tail, tail_len): \
  value eq '\rm' || value eq '\tt' ? strmath_cmd1_process(value, tail, tail_len) : \
  value . strmath_1(tail, tail_len);
strmath_cmd_mathrm(tail, tail_len, arg_len) = \
  substr(tail, 1 + mwg_strcspn_n(tail, tail_len, strmath_chars_blank), arg_len) . strmath_1(substr(tail, arg_len + 1, tail_len), tail_len - arg_len);

strmath_italic_find(tail, tail_len) = mwg_strcspn_n(tail, tail_len, strmath_chars_italic_target);
strmath_italic_process(value) = '{/Times:Italic ' . value . '}';

strmath_letter_process(value) = \
  value eq '-' ? strmath_symbol_minus : \
  value eq '〈' ? strmath_symbol_langle : \
  value eq '〉' ? strmath_symbol_rangle : \
  value;

strmath(str) = strmath_1(str, strlen(str));
strmath_1(str, str_len) = str_len <= 0 ? str : strmath_2(str, str_len, strmath_cmd_find(str, str_len), strmath_italic_find(str, str_len));
strmath_2(str, str_len, cmd_len, italic_len) = \
  cmd_len != 0 ? strmath_cmd_process(substr(str, 1, cmd_len), substr(str, cmd_len + 1, str_len), str_len - cmd_len) : \
  italic_len != 0 ? strmath_italic_process(substr(str, 1, italic_len)) . strmath_1(substr(str, italic_len + 1, str_len), str_len - italic_len) : \
  strmath_letter_process(substr(str, 1, 1)) . strmath_1(substr(str, 2, str_len), str_len - 1);

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
