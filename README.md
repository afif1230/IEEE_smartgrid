# Physics-Informed TCN Predictive Control via Reinforcement Learning for Off-Grid Microgrid Energy Management

Code and data accompanying the paper:

> A. El Bsat and N. Daher, "Physics-Informed TCN Predictive Control via Reinforcement Learning for Off-Grid Microgrid Energy Management," submitted to *IEEE Transactions on Smart Grid*.

## Abstract

Managing uncertainty in solar generation is critical to continuously meet demand while operating isolated microgrids. To that end, this work gives off-grid microgrid operators a forecast-aware dispatch policy that lowers unmet demand without added hardware, together with a criterion for which reinforcement learning (RL) algorithms can exploit solar forecast to make better dispatch decisions. We propose a forecast-augmented Twin Delayed Deep Deterministic Policy Gradient (TD3) controller for a photovoltaic-battery-diesel off-grid microgrid, in which a physics-informed temporal convolutional network (TCN) forecast of the hourly clear-sky index is integrated into the agent's observation vector. Under matched training conditions, the forecast substantially reduces TD3's unmet demand relative to its no-forecast baseline. To benchmark this result, an on-policy Proximal Policy Optimization (PPO) agent is identically trained and sees little comparable improvement. A randomized-input test confirms that PPO essentially ignores the forecast, where replacing it with uniform noise increases unmet demand by only 3.5% for PPO against 35.5% for TD3. A decomposition of PPO's actor update traces this insensitivity to the advantage, through which the forecast reaches the actor almost entirely as a shift common to each available action, and therefore contributes nothing to the expected policy gradient. An auxiliary-loss intervention that bypasses the advantage entirely restores forecast responsiveness, confirming the structural origin of the effect.

## Repository layout

| Folder | Contents |
|---|---|
| `01_data_and_sizing/` | Notebook that builds the aligned 2020 weather/load dataset and sizes the microgrid (PV capacity, battery sweep against LPSP). Includes the hourly RL weather file, the Qaraoun load profile, and the PV series. |
| `02_forecaster/` | TCN notebook: data cleaning and QC, physics-informed clear-sky features, training, evaluation against the persistence baseline, and generation of the year-long clear-sky-index prediction lookup (`tcn_kt_predictions_2020.npy`). Trained model in `TCN_Model/`. |
| `03_reinforcement_learning/` | `TD3.ipynb` (proposed controller) and `PPO.ipynb` (benchmark). Contains the pymgrid environment wrapper, reward, training and evaluation loops, the forecast-horizon sweep, and the diagnostic tests reported in the paper (randomized forecast input, sensitivity probe, advantage decomposition, auxiliary loss). Trained checkpoints in `Models/`. |
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

If you use this code or data, please cite the paper (DOI to be added upon publication).

## License

See `LICENSE`.
