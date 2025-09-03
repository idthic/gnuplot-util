# Gnuplot notes and libraries

## Initialization for PDF for papers/slides

```gnuplot
set encoding utf8
set minussign
set terminal pdfcairo size 3.5,3.5/sqrt(2)
set output 'a.pdf'
```

## Settings for error bands

```gnuplot
ToDo
```

## Dashtypes

```gnuplot
ToDo
```

## libstrmath.gp

Functions:

- `strtext(tex_source)`, `strtex(tex_source)`
- `strmath(tex_source)`

Variables:

- `strmath_font_math{rm,it,bm}` ... These variables can be set to font names to
  configure respective fonts in mathematical expressions.
- `strmath_font_setup_{times,sans,aghtex,cmu,cmu_sans}` ... These variables can
  be evaluated to set up the font variables with a preset configuration.

Example:

```gnuplot
load 'libstrmath.gp'

# font settings
strmath_font_mathrm = 'Times'
strmath_font_mathit = 'Times:Italic'
strmath_font_mathbm = 'Times:Italic:Bold'
# The above settings are equivalent to the following line:
#eval strmath_font_setup_times

set xlabel strtext('Transverse momentum $p_T$ GeV/$c$')
set ylabel strtext('$v_2\{2\}$')
```

If your system does not have good fonts, the following list shows typical
fonts.

```console
Typical faces similar to "Helvetica, Times, Courier, etc."

$ sudo pacman -Sy gnu-free-fonts

Unicode fonts for CJK

$ sudo pacman -Sy noto-fonts-cjk

Latin Modern and CMU (Math fonts)

$ sudo pacman -Sy texlive-fonts{recommended,extra}
$ mkdir -p ~/.local/share/fonts
$ ln -s /usr/share/texmf-dist/fonts/opentype/public/{lm,cm-unicode} ~/.local/share/fonts/
$ fc-cache -fv
```

# Tips

線の両端点が範囲外の時に線が描画されない問題は以下の設定で回避できる

```gp
set clip two
```

三次元プロットで `set view 0,0` としていたが、`set pm3d map` でも同様にできる?

```gp
set pm3d map
```

ファイルなしで `using` の中を全部式で指定したい場合は `'+'` というファイル名を
使う。二次元グリッドを生成するには `'++'` を使えるらしい。

```gp
plot ..., [t=-3:25:1] '+' using (t):(f(t))
```

- [special-filenames](http://www.gnuplot.info/docs/loc8853.html)

`with yerrorlines` を使う時は白い円盤が他のデータ点を隠してしまうので以下を設定する

```gp
set pointintervalbox 0
```

三次元プロット `splot` の x-y 平面が変な所に表示される問題。これは以下を設定する。

```gp
set ticslevel 0
```

gnuplot 6.0 には対数目盛にバグがある。目盛りが $10^{n}$ ($n\ge 2$) の時、変な場
所に目盛りが表示される。正しく表示する為には、目盛りの位置をすべて手動で指定す
るしかない。例えば以下の様にする。3番目の数字 `1` は短い目盛り (minor tics) で
ある事を示す。

```gp
set ytics ( \                                                                  |
  1e-10, 1e-8, 1e-6, 1e-4, 1e-2, 1.0, \                                        |
  "" 1e-9 1, "" 2e-9 1, "" 3e-9 1, "" 4e-9 1, "" 5e-9 1, "" 6e-9 1, "" 7e-9 1, "" 8e-9 1, "" 9e-9 1, \
  "" 1e-7 1, "" 2e-7 1, "" 3e-7 1, "" 4e-7 1, "" 5e-7 1, "" 6e-7 1, "" 7e-7 1, "" 8e-7 1, "" 9e-7 1, \
  "" 1e-5 1, "" 2e-5 1, "" 3e-5 1, "" 4e-5 1, "" 5e-5 1, "" 6e-5 1, "" 7e-5 1, "" 8e-5 1, "" 9e-5 1, \
  "" 1e-3 1, "" 2e-3 1, "" 3e-3 1, "" 4e-3 1, "" 5e-3 1, "" 6e-3 1, "" 7e-3 1, "" 8e-3 1, "" 9e-3 1, \
  "" 1e-1 1, "" 2e-1 1, "" 3e-1 1, "" 4e-1 1, "" 5e-1 1, "" 6e-1 1, "" 7e-1 1, "" 8e-1 1, "" 9e-1 1 )
```

## `pm3d` で部分的にラスターで出力

`pm3d` で表示する時、メッシュが細かいと生成される PDF が巨大になってしまう。PNG
で出力すれば良いかもしれないがそうすると、論文で文字列もラスターになってしまう
し選択できない。`pm3d` の部分だけ画像埋め込みにできれば良いがその様な機能は提供
されていない。代わりに `.png` で生成した画像を `with rgbimage` で PDF に埋め込
むことを考える (gnuplot 4.4 以降で可能)。

先ずは `pm3d` の画像部分だけを生成する。

```gp
# xrange, yrange, cbrange や set log などは目的のプロットと同じにする。自動調整
# だと一致させられないので全部手動で指定する。
set pm3d map
set xrange [...]
set yrange [...]
set cbrange [...]

set terminal pngcairo size IMAGE_WIDTH,IMAGE_HEIGHT
set output 'tmp.png'

# 余計な物は全部消す
set lmargin at screen 0.0
set rmargin at screen 1.0
set bmargin at screen 0.0
set tmargin at screen 1.0
unset key
unset xtics
unset ytics
unset ztics
unset border

plot ...
```

その後で multiplot で重ねてプロットする。

```gnuplot
set pm3d map
set multiplot

# [...配置コマンド]

set xrange [0:IMAGE_WIDTH-1]
set yrange [0:IMAGE_HEIGHT-1]
unset key
unset xtics
unset ytics
unset border
splot 'tmp.png' binary filetype=png with rgbimage

# [...配置コマンド]

set border ...
set xtics ...
set ytics ...
set key ...
set xrange [...]
set yrange [...]
set cbrange [...]
set zrange [0:1.0]
splot -1.0 # 枠および他の物を表示する為にダミーでプロット

unset multiplot
```

- http://www.gnuplot.info/docs/loc5469.html
- https://sk.kuee.kyoto-u.ac.jp/person/yonezawa/contents/program/gnuplot/embed_png.html

## ファイルの存在判定

そういう関数は存在しない。なので `system(...)` でシェルを呼び出す。

```gp
file_exists(file) = system("[ -f '".file."' ] && echo '1' || echo '0'") + 0
```

## 既定の設定

```gp
set xtics auto
set ytics auto
set key default
```

`set format` に関しては既定に戻す設定はない。既定の設定と同じ設定を手で指定する
必要がある。古いマニュアルだと `% g` になっているが、新しいマニュアルだと `% h`
または LaTeX 系の出力では `$%h$` ということになっている。

```gp
set format x '% h'
set format y '% h'
```

- https://stackoverflow.com/a/40652077/4908404
- http://www.gnuplot.info/docs_5.4/gnuplot-ja.pdf

対数目盛りのラベルは例えば以下の様に設定する

```gp
# Note: 本当は "%t e%+T" だが、対数軸の時は基本的に %t = 1.0 で固定なので
set format y '10^{%T}'

# Note: もしちゃんと小数部も表示したければ例えば以下の様にする
set format y '%.1t×10^{%T}'

```

## ラベルを表に

既定ではラベルはグラフのプロットよりも裏に表示されるので 3d plot などだと見えな
くなってしまう。表に表示するには `front` を指定する。

```gp
set label 1 ... front
```
