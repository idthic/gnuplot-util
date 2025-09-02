#!/usr/bin/gnuplot

# This gnuplot library can be used to save "pm3d" in a .png file.  When the
# data has (W+1)x(H+1) columns and lines, gnuplot produces WxH squares for the
# "pm3d" plot.  We want to save the map into a .png file of size WxH in such a
# case.
#
# We use the terminal "pngcairo" to perform this.  A problem is that the
# boundaries of ranges specified by xrange and yrange seem to be mapped into
# the "centers" of the outermost pixels.  This means that the half of the
# outermost cells are outside the plotting range, so the outermost cells cannot
# be used to save the map.  For this reason, we add 1px margins around the main
# content so that the generated .png file has the size of (W+2)x(H+2).  Then,
# when we specify xrange and yrange, we specified the center positions of the
# margin pixels by offsetting lengths corresponding to 0.5px.

_raster3d_set_log_x = 0
_raster3d_set_log_y = 0

_raster3d__range_min(vmin, vmax, npixel, is_log) = \
  is_log ? vmin * (vmax / vmin)**(-0.5 / npixel) : \
  vmin - 0.5 * (vmax - vmin) / npixel
_raster3d__range_max(vmin, vmax, npixel, is_log) = \
  is_log ? vmax * (vmax / vmin)**(0.5 / npixel) : \
  vmax + 0.5 * (vmax - vmin) / npixel

raster3d_set_pngcairo(width, height, xmin, xmax, ymin, ymax, filename) = " \
  set terminal pngcairo size ".sprintf('%d,%d', width + 2, height + 2)."; \
  unset border; \
  unset xtics; \
  unset ytics; \
  unset xlabel; \
  unset ylabel; \
  unset key; \
  unset colorbox; \
  set pm3d map; \
  set lmargin at screen 0.0; \
  set rmargin at screen 1.0; \
  set bmargin at screen 0.0; \
  set tmargin at screen 1.0; \
  ".(_raster3d_set_log_x ? "set log x" : "unset log x")."; \
  ".(_raster3d_set_log_y ? "set log y" : "unset log y")."; \
  set xrange [".sprintf('%g:%g', _raster3d__range_min(xmin, xmax, width , _raster3d_set_log_x), _raster3d__range_max(xmin, xmax, width , _raster3d_set_log_x))."]; \
  set yrange [".sprintf('%g:%g', _raster3d__range_min(ymin, ymax, height, _raster3d_set_log_y), _raster3d__range_max(ymin, ymax, height, _raster3d_set_log_y))."]; \
  print '".filename."...'; \
  set output '".filename."' "

raster3d_file_exists(file) = system("[ -f '".file."' ] && echo '1' || echo '0'") + 0
raster3d_splot_pngcache(filename, set_pngcairo_args, splot) = " \
  if (!raster3d_file_exists('".filename."')) { \
    eval raster3d_set_pngcairo(".set_pngcairo_args.", '".filename."'); \
    ".splot." \
  } "

raster3d_splot_png(width, height, xmin, xmax, ymin, ymax, filename) = " \
  unset border; \
  unset xtics; \
  unset ytics; \
  unset xlabel; \
  unset ylabel; \
  unset key; \
  unset colorbox; \
  set pm3d map; \
  unset log x; \
  unset log y; \
  set xrange [0.5:".sprintf('%g', width + 0.5)."]; \
  set yrange [0.5:".sprintf('%g', height + 0.5)."]; \
  set zrange [*:*]; \
  splot '".filename."' binary filetype=png with rgbimage notitle; \
  set border; \
  set xtics; \
  set ytics; \
  set key; \
  set colorbox; \
  ".(_raster3d_set_log_x ? "set log x" : "unset log x")."; \
  ".(_raster3d_set_log_y ? "set log y" : "unset log y")."; \
  set xrange ".sprintf('[%g:%g]', xmin, xmax)."; \
  set yrange ".sprintf('[%g:%g]', ymin, ymax)."; \
  set zrange [0:1.0]; "

#------------------------------------------------------------------------------
