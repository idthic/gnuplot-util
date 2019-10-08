#!/usr/bin/gnuplot
# -*- mode: sh -*-

_mulp_rows=2
_mulp_cols=3
_mulp_tmargin = 0.1
_mulp_bmargin = 0.0
_mulp_lmargin = 0.0
_mulp_rmargin = 0.0

_mulp_px2sx(r,c,x) = _mulp_lmargin + (1.0 - _mulp_lmargin - _mulp_rmargin) * ((c + x)/_mulp_cols)
_mulp_py2sy(r,c,y) = _mulp_bmargin + (1.0 - _mulp_tmargin - _mulp_bmargin) * (1.0 - (r + 1.0 - y)/_mulp_rows)
_mulp_pw2sw(r,c,w) = (1.0 - _mulp_lmargin - _mulp_rmargin) * (w / _mulp_cols)
_mulp_ph2sh(r,c,h) = (1.0 - _mulp_tmargin - _mulp_bmargin) * (h / _mulp_rows)

_mulp_lm_(r,c,margin) = _mulp_px2sx(r,c,margin)
_mulp_rm_(r,c,margin) = _mulp_px2sx(r,c,1.0-margin)
_mulp_bm_(r,c,margin) = _mulp_py2sy(r,c,margin)
_mulp_tm_(r,c,margin) = _mulp_py2sy(r,c,1.0-margin)

MulpInitialize(rows,cols,lm,rm,bm,tm) = \
  sprintf('_mulp_rows = %.1f;', rows). \
  sprintf('_mulp_cols = %.1f;', cols). \
  sprintf('_mulp_lmargin = %g;', lm). \
  sprintf('_mulp_rmargin = %g;', rm). \
  sprintf('_mulp_bmargin = %g;', bm). \
  sprintf('_mulp_tmargin = %g', tm)

MulpSetMargins(r,c,lm,rm,bm,tm) = \
  sprintf('set lmargin at screen %g;',_mulp_lm_(r,c,lm)). \
  sprintf('set rmargin at screen %g;',_mulp_rm_(r,c,rm)). \
  sprintf('set bmargin at screen %g;',_mulp_bm_(r,c,bm)). \
  sprintf('set tmargin at screen %g', _mulp_tm_(r,c,tm))

MulpSetColorbox(r,c,x,y,w,h) = \
  sprintf('set colorbox user origin %g,%g size %g,%g', \
    _mulp_px2sx(r,c,x),_mulp_py2sy(r,c,y),_mulp_pw2sw(r,c,w),_mulp_ph2sh(r,c,h))
