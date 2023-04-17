# Plotting of Figure S2

Files in this directory was used for creating Figure S2 (`GTO-div-STO.png`).
`./compute.py` will generate table `STO-GTO.csv`.
Then, `./R.R` will read it and generate some `png`-files.
One of them is `GTO-div-STO.png`.

`compute.py` depends on `numpy` and `scipy` packages.
`R.R` requires installation of `ggplot2`, `dplyr` and `reshape2` libraries.
