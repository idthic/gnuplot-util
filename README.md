

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

`splot` の x-y 平面が変な所に表示される問題。これは以下を設定する。

```gp
set ticslevel 0
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

## ラベルを表に

既定ではラベルはグラフのプロットよりも裏に表示されるので 3d plot などだと見えな
くなってしまう。表に表示するには `front` を指定する。

```gp
set label 1 ... front
```
