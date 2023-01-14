# Computation of Mutual Information

There is a script `MI_parallel.py` for computing Mutual Information.
It uses data from `whole_data.csv`, which can be generated via scripts in `gen/` directory or extracted from `whole_data.csv.tar.xz` using the command `tar -xzvf whole_data.csv.tar.xz`.
`dist_parallel.csv` presents our data gotten with `MI_parallel.py`.

After running `MI_parallel.py`, `dist_parallel.csv` will be created. Data from `MIDist` column is presented in the Table 1 of Main text.
`Var1` and `Var2` columns represent computed features. Their meanings are presented in table below:

| `Var1`   | Feature |
| :------- | :------ |
| 1        | $\rho$                |
| 2        | $\nabla \rho$         |
| 3        | $\nabla^2 \rho$       |
| 7        | $\tau$                |
| 999      | $e^\text{HF}$         |
| 24_00_0  | $\xi^{0.0}$, $p = 0$  |
| 24_00_1  | $\xi^{0.0}$, $p = 1$  |
| 24_01_1  | $\xi^{0.1}$, $p = 1$  |
| 24_02_1  | $\xi^{0.2}$, $p = 1$  |
| 24_03_1  | $\xi^{0.3}$, $p = 1$  |
| 24_04_1  | $\xi^{0.4}$, $p = 1$  |
| 24_05_1  | $\xi^{0.5}$, $p = 1$  |
| 24_06_1  | $\xi^{0.6}$, $p = 1$  |
| 24_07_1  | $\xi^{0.7}$, $p = 1$  |
| 24_08_1  | $\xi^{0.8}$, $p = 1$  |
| 24_09_1  | $\xi^{0.9}$, $p = 1$  |
| 24_10_1  | $\xi^{1.0}$, $p = 1$  |
| 24_m01_0 | $\xi^{-0.1}$, $p = 0$ |
| 24_m01_1 | $\xi^{-0.1}$, $p = 1$ |
| 24_m02_0 | $\xi^{-0.2}$, $p = 0$ |
| 24_m02_1 | $\xi^{-0.2}$, $p = 1$ |
| 24_m03_0 | $\xi^{-0.3}$, $p = 0$ |
| 24_m03_1 | $\xi^{-0.3}$, $p = 1$ |
| 24_m04_0 | $\xi^{-0.4}$, $p = 0$ |
| 24_m04_1 | $\xi^{-0.4}$, $p = 1$ |
| 24_m05_0 | $\xi^{-0.5}$, $p = 0$ |
| 24_m05_1 | $\xi^{-0.5}$, $p = 1$ |
| 24_m06_0 | $\xi^{-0.6}$, $p = 0$ |
| 24_m06_1 | $\xi^{-0.6}$, $p = 1$ |
| 24_m07_0 | $\xi^{-0.7}$, $p = 0$ |
| 24_m07_1 | $\xi^{-0.7}$, $p = 1$ |
| 24_m08_0 | $\xi^{-0.8}$, $p = 0$ |
| 24_m08_1 | $\xi^{-0.8}$, $p = 1$ |
| 24_m09_0 | $\xi^{-0.9}$, $p = 0$ |
| 24_m09_1 | $\xi^{-0.9}$, $p = 1$ |
| 24_m10_0 | $\xi^{-1.0}$, $p = 0$ |
| 24_m10_1 | $\xi^{-1.0}$, $p = 1$ |
| 24_m11_0 | $\xi^{-1.1}$, $p = 0$ |
| 24_m12_0 | $\xi^{-1.2}$, $p = 0$ |
| 24_m13_0 | $\xi^{-1.3}$, $p = 0$ |
| 24_m14_0 | $\xi^{-1.4}$, $p = 0$ |
| 24_m15_0 | $\xi^{-1.5}$, $p = 0$ |
| 24_m16_0 | $\xi^{-1.6}$, $p = 0$ |
| 24_m17_0 | $\xi^{-1.7}$, $p = 0$ |
| 24_m18_0 | $\xi^{-1.8}$, $p = 0$ |
| 24_m19_0 | $\xi^{-1.9}$, $p = 0$ |
| 24_m20_0 | $\xi^{-2.0}$, $p = 0$ |
