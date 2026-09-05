#!/usr/bin/env python
"""gbdraw linear with a settable canvas width.

Two config values gbdraw 0.13 exposes no CLI flag for:

  GBDRAW_WIDTH         linear canvas width, hardcoded at 2000 px, which squeezes
                       a 14-row figure into a tall narrow strip.
  GBDRAW_LABEL_STROKE  label leader-line width. Defaults to 0.5 canvas units for
                       genomes >= 50 kb, which prints below Nature's 0.25 pt
                       minimum line weight and drops out of the figure.

This shim patches the loaded config in memory; the installed package is untouched.

Usage: GBDRAW_WIDTH=2600 gbdraw-wide.py <all normal `gbdraw linear` args>
"""
import os
import sys

import gbdraw.linear as L

_load = L.load_config_toml


def _wide(*args, **kwargs):
    cfg = _load(*args, **kwargs)
    cfg["canvas"]["linear"]["width"] = float(os.environ.get("GBDRAW_WIDTH", 2000))
    stroke = os.environ.get("GBDRAW_LABEL_STROKE")
    if stroke:
        cfg["labels"]["stroke_width"]["short"] = float(stroke)
        cfg["labels"]["stroke_width"]["long"] = float(stroke)
    return cfg


L.load_config_toml = _wide
L.linear_main(sys.argv[1:])
