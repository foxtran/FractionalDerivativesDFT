# Generation grid point data of features

Here, two scripts are `gen.sh` and `gen.py`.

This directory requires computed `Be.wfn`, `C6H6.wfn`, `H2.wfn`, `H2O.wfn`, `He.wfn`, `Li2.wfn`, `Xe.wfn`.
You can find them in `calc` directory.

Also, it requires compiled `gMultiwfn_noGUI`. See `Multiwfn` directory.

## `gen.sh`

Computes ingredients (or features) for all compounds in this directory.
It will generate about 18Gb of data.

## `gen.py`

This script collects data into large `whole_data.csv` which will be created at previous directory (`./../`).
