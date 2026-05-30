"""Predict-and-store: run the TCN over 2020 and save the year-long kt lookup
table that the RL wrapper reads at runtime. Falls back to persistence on
sensor-outage hours (~40%), per the paper. Saves data/forecasts/kt_lookup_2020.npy."""
