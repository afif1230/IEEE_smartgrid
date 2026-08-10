# Physics-Informed TCN Predictive Control via Reinforcement Learning for Off-Grid Microgrid Energy Management

Code and data accompanying the paper:

> A. El Bsat and N. Daher, "Physics-Informed TCN Predictive Control via Reinforcement Learning for Off-Grid Microgrid Energy Management," submitted to *IEEE Transactions on Smart Grid*.

A physics-informed temporal convolutional network (TCN) forecasts the hourly clear-sky index $k_t$, and the forecast is appended to the observation vector of a TD3 agent dispatching a photovoltaic–battery–diesel off-grid microgrid. PPO is trained identically as an on-policy benchmark, and the paper analyzes why TD3 exploits the forecast while PPO does not.

## Repository layout

| Folder | Contents |
|---|---|
| `01_data_and_sizing/` | Notebook that builds the aligned 2020 weather/load dataset and sizes the microgrid (PV capacity, battery sweep against LPSP). Includes the hourly RL weather file, the Qaraoun load profile, and the tier-1 PV series. |
| `02_forecaster/` | TCN notebook: data cleaning and QC, physics-informed clear-sky features, training, evaluation against the persistence baseline, and generation of the year-long $k_t$ prediction lookup (`tcn_kt_predictions_2020.npy`). Trained model in `TCN_Model/`. |
| `03_reinforcement_learning/` | `TD3.ipynb` (proposed controller), `PPO.ipynb` (benchmark), and `Q_learning.ipynb` (discrete baseline). Contains the pymgrid environment wrapper, reward, training and evaluation loops, the forecast-horizon sweep, and the diagnostic tests reported in the paper (randomized forecast input, sensitivity probe, advantage decomposition, auxiliary loss). Trained checkpoints in `Models/`. |
| `docs/` | Quality-control flag definitions for the weather station data. |

## Run order

1. **`01_data_and_sizing/01_data_and_sizing.ipynb`** — produces the aligned hourly dataset and the sized microgrid configuration.
2. **`02_forecaster/02_forecaster.ipynb`** — trains/evaluates the TCN and writes `tcn_kt_predictions_2020.npy`, the lookup table the RL wrapper reads at runtime.
3. **`03_reinforcement_learning/TD3.ipynb`** and **`PPO.ipynb`** — build the pymgrid environment, train with and without the forecast across horizons H = 1–24 h, and run the evaluation and diagnostic tests.

Intermediate outputs needed by later stages are committed, so each notebook can also be run standalone.

## Data

- **Weather:** Ras Baalbak, Lebanon ground station (Helioscale Phi, Tier 2), 1-min resolution, Mar 2019 – May 2021, from the World Bank / ESMAP Lebanon solar measurement campaign. Timestamps are UTC (verified against astronomical solar elevation).
- **Load:** hourly demand for Qaraoun, Lebanon (8,760 values, 85.2 GWh/yr), measured by Électricité du Liban.
- Two derived datasets are used deliberately: a quality-controlled subset for TCN training (no interpolated values) and a gap-filled continuous 2020 series for the RL environment. The cleaning pipeline is documented in the paper and in `02_forecaster/`.

## Environment

```
pip install -r requirements.txt
```

Key dependencies: `pymgrid`, `pvlib`, `torch`, `numpy`, `pandas`. The pymgrid version is pinned — the environment wrapper depends on its module API.

## Citation

If you use this code or data, please cite the paper (see `CITATION.cff`; DOI to be added upon publication).

## License

See `LICENSE`.
