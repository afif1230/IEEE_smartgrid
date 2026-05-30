# Integrating Physics-Informed TCN Forecasting with RL for Off-Grid Microgrids

Code and data for the paper. See each numbered folder; run them in order.

## Run order
1. 01_data_and_sizing  — build aligned weather/load and PV/battery sizing
2. 02_forecaster       — TCN weights, test metrics, and the kt lookup table
3. 03_environment       — pymgrid build + RL wrapper/reward (shared)
4. 04_ppo / 05_td3      — train & evaluate, with and without the TCN forecast
5. 06_analysis          — randomized-kt test and sensitivity probe

## Reproduce map (fill in)
- Table  (TCN metrics)      -> 02_forecaster/evaluate_tcn.py
- Table  (baseline LL)       -> 04_ppo, 05_td3 (no-TCN)
- Table  (horizon sweep)     -> 04_ppo, 05_td3 (TCN)
- Table  (randomized kt)     -> 06_analysis/randomized_kt_test.py
- Table  (sensitivity)       -> 06_analysis/sensitivity_probe.py

## Data
See data/DATA.md for sources, links, and what is shipped vs. linked.

## Environment
pip install -r requirements.txt  (pymgrid version is pinned — keep it pinned).
