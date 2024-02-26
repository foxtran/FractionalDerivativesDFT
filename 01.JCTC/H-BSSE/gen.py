#!/usr/bin/python3

import numpy as np

for basis in ["cc-pVTZ", "cc-pVQZ", "aug-cc-pVTZ", "aug-cc-pVQZ"]:
  inp = open(f"H-X.tmp.gjf.{basis}").read()

  for d in np.arange(0.1, 7.01, 0.1):
    strd = f"{d:3.1f}"
    open(f"inps.{basis}/H-X.{strd}.gjf", "w").write(inp.replace("%DIST%", strd))
