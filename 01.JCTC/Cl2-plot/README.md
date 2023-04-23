# Plotting of Figure 2 and S1.

Files in this directory was used for creating Figure 2 (`Cl2-frac-runifw-values.png`) and Figure S1(`Cl2-basis-frac-logscaled.png`) and some additional figures.
In addition to `R-Cl2.R` and `parse-Cl2.sh`, here, `Cl2_6-31G.wfn`, `Cl2_ACCT.wfn`, `Cl2_UGBS.wfn`, `Cl2_def2TZVP.wfn`, and `gMultiwfn_noGUI` should be (now, these files are empty).
`gMultiwfn_noGUI` must be compiled with included support of fractional derivatives.
Running of `./parse-Cl2.sh` should create figures at the end (it may take a time).

`R-Cl2.R` requires installation of `tidyr`, `dplyr`, `ggplot2`, `RColorBrewer` libraries.
