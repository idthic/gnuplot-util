#!/usr/bin/gnuplot
# -*- mode: sh -*-

mulp_rows=2
mulp_cols=3
mulp_tmargin = 0.1
mulp_bmargin = 0.0
mulp_lmargin = 0.0
mulp_rmargin = 0.0

mulp_lm_(r,c,margin) = mulp_lmargin + (1.0 - mulp_lmargin - mulp_rmargin) * ((c + margin)/mulp_cols)
mulp_rm_(r,c,margin) = mulp_lmargin + (1.0 - mulp_lmargin - mulp_rmargin) * ((c + 1 - margin)/mulp_cols)
mulp_bm_(r,c,margin) = mulp_bmargin + (1.0 - mulp_tmargin - mulp_bmargin) * (1.0 - (r + 1 - margin)/mulp_rows)
mulp_tm_(r,c,margin) = mulp_bmargin + (1.0 - mulp_tmargin - mulp_bmargin) * (1.0 - (r + margin)/mulp_rows)

MulpInitialize(rows,cols,lm,rm,bm,tm) = \
  sprintf('mulp_rows = %d;', rows). \
  sprintf('mulp_cols = %d;', cols). \
  sprintf('mulp_lmargin = %g;', lm). \
  sprintf('mulp_rmargin = %g;', rm). \
  sprintf('mulp_bmargin = %g;', bm). \
  sprintf('mulp_tmargin = %g', tm)

MulpSetMargins(r,c,lm,rm,bm,tm) = \
  sprintf('set lmargin at screen %g;',mulp_lm_(r,c,lm)). \
  sprintf('set rmargin at screen %g;',mulp_rm_(r,c,rm)). \
  sprintf('set bmargin at screen %g;',mulp_bm_(r,c,bm)). \
  sprintf('set tmargin at screen %g', mulp_tm_(r,c,tm))

xyprofile(file,h) = sprintf("< awk '$1==%g{if($2!=x){print \"\";x=$2}print $2,$3,$4}' %s",h,file)
hxprofile(file) = sprintf("< awk '$3==0{if($1!=h){print \"\";h=$1}print $1,$2,$4}' %s",file)

PlotInitialConditionProfiles(title,filename) = "\
  a_title='".title."'; \
  a_filename='".filename."'; \
  print 'Plotting initial profile ('.a_title.')'; \
  reset; \
  set multiplot layout 2,3 title '{/=18 '.a_title.'}'; \
  eval MulpInitialize(2, 3, 0.0, 0.0, 0.0, 0.1); \
 \
  eval MulpSetMargins(0,0,0.25,0.25,0.3,0.2); \
  set title 'Transverse profile' offset character 0,1; \
  set xlabel '{/Times:Italic x} [fm]' offset character 0,-1; \
  set ylabel '{/Times:Italic y} [fm]' offset character 0,-1; \
  set view 75,340; \
  set ticslevel 0; \
  splot [-2:2] [-2:2] xyprofile(a_filename,0) u 1:2:3 w pm3d t ''; \
 \
  eval MulpSetMargins(0,1,0.25,0.25,0.3,0.2); \
  set title 'Longitudinal profile' offset character 0,1; \
  set xlabel '{/Times:Italic η}' offset character 0,-1; \
  set ylabel '{/Times:Italic x} [fm]' offset character 0,-1; \
  set view 75,340; \
  set ticslevel 0; \
  splot [-6:6] [-2:2] hxprofile(a_filename) u 1:2:3 w pm3d t ''; \
 \
  eval MulpSetMargins(0,2,0.25,0.25,0.3,0.2); \
  set title 'Longitudinal profile' offset character 0,1; \
  set xlabel '{/Times:Italic η}' offset character 0,0; \
  set ylabel '{/Times:Italic x} [fm]' offset character -4,0 rotate parallel; \
  set view 0,359.99; \
  unset ztics; \
  splot [-6:6] [-2:2] hxprofile(a_filename) u 1:2:3 w pm3d t ''; \
 \
  eval MulpSetMargins(1,0,0.25,0.25,0.3,0.2); \
  set title 'Transverse profile ({/Times:Italic η} = -2.4)' offset character 0,1; \
  set xlabel '{/Times:Italic x} [fm]' offset character 0,0; \
  set ylabel '{/Times:Italic y} [fm]' offset character -4,0 rotate parallel; \
  set view 0,359.99; \
  unset ztics; \
  splot [-2:2] [-2:2] xyprofile(a_filename,-2.4) u 1:2:3 w pm3d t ''; \
 \
  eval MulpSetMargins(1,1,0.25,0.25,0.3,0.2); \
  set title 'Transverse profile ({/Times:Italic η} = 0)' offset character 0,1; \
  set xlabel '{/Times:Italic x} [fm]' offset character 0,0; \
  set ylabel '{/Times:Italic y} [fm]' offset character -4,0 rotate parallel; \
  set view 0,359.99; \
  unset ztics; \
  splot [-2:2] [-2:2] xyprofile(a_filename,0) u 1:2:3 w pm3d t ''; \
 \
  eval MulpSetMargins(1,2,0.25,0.25,0.3,0.2); \
  set title 'Transverse profile ({/Times:Italic η} = 2.4)' offset character 0,1; \
  set xlabel '{/Times:Italic x} [fm]' offset character 0,0; \
  set ylabel '{/Times:Italic y} [fm]' offset character -4,0 rotate parallel; \
  set view 0,359.99; \
  unset ztics; \
  splot [-2:2] [-2:2] xyprofile(a_filename,2.4) u 1:2:3 w pm3d t ''; \
 \
  unset multiplot "
