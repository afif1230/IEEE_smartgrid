#!/usr/bin/env bash
# =============================================================================
# scaffold.sh — builds the repo skeleton for the TCN-RL microgrid paper.
#
# Usage:   bash scaffold.sh
#
# What it does:
#   - creates the folder tree
#   - writes a self-documenting PLACEHOLDER for every code file and dataset
#   - each code stub says, in its header, what goes in it and where it comes from
#
# Safe to re-run: it never overwrites a file that already exists, so once you
# drop in your real code/data, running it again won't clobber your work.
# =============================================================================

set -euo pipefail
ROOT="."
mkdir -p "$ROOT"; cd "$ROOT"

# --- helpers -----------------------------------------------------------------
# stub <path> <line1> <line2> ...   -> writes a text/code placeholder
stub () {
  local path="$1"; shift
  if [ -e "$path" ]; then echo "skip (exists): $path"; return; fi
  mkdir -p "$(dirname "$path")"
  printf '%s\n' "$@" > "$path"
  echo "created: $path"
}
# data <path> <description>         -> writes a .placeholder marker for a dataset
data () {
  local path="$1.placeholder"; local desc="$2"
  if [ -e "$1" ] || [ -e "$path" ]; then echo "skip (exists): $path"; return; fi
  mkdir -p "$(dirname "$path")"
  printf 'PLACEHOLDER — replace with the real file: %s\nExpected filename: %s\n' \
    "$desc" "$(basename "$1")" > "$path"
  echo "created: $path"
}

# =============================================================================
# Top-level files
# =============================================================================
stub "README.md" \
  "# Integrating Physics-Informed TCN Forecasting with RL for Off-Grid Microgrids" \
  "" \
  "Code and data for the paper. See each numbered folder; run them in order." \
  "" \
  "## Run order" \
  "1. 01_data_and_sizing  — build aligned weather/load and PV/battery sizing" \
  "2. 02_forecaster       — TCN weights, test metrics, and the kt lookup table" \
  "3. 03_environment       — pymgrid build + RL wrapper/reward (shared)" \
  "4. 04_ppo / 05_td3      — train & evaluate, with and without the TCN forecast" \
  "5. 06_analysis          — randomized-kt test and sensitivity probe" \
  "" \
  "## Reproduce map (fill in)" \
  "- Table  (TCN metrics)      -> 02_forecaster/evaluate_tcn.py" \
  "- Table  (baseline LL)       -> 04_ppo, 05_td3 (no-TCN)" \
  "- Table  (horizon sweep)     -> 04_ppo, 05_td3 (TCN)" \
  "- Table  (randomized kt)     -> 06_analysis/randomized_kt_test.py" \
  "- Table  (sensitivity)       -> 06_analysis/sensitivity_probe.py" \
  "" \
  "## Data" \
  "See data/DATA.md for sources, links, and what is shipped vs. linked." \
  "" \
  "## Environment" \
  "pip install -r requirements.txt  (pymgrid version is pinned — keep it pinned)."

stub "requirements.txt" \
  "# Pin pymgrid to the EXACT version you used — the repo will not run otherwise." \
  "pymgrid==<FILL_IN>" \
  "numpy==<FILL_IN>" \
  "pandas==<FILL_IN>" \
  "pvlib==<FILL_IN>" \
  "torch==<FILL_IN>" \
  "matplotlib==<FILL_IN>"

stub "LICENSE" \
  "PLACEHOLDER — choose a license (e.g. MIT for code). Note: the datasets may" \
  "have their own terms; document those separately in data/DATA.md."

stub "CITATION.cff" \
  "cff-version: 1.2.0" \
  "title: TCN-RL for Off-Grid Microgrids" \
  "authors:" \
  "  - family-names: El Bsat" \
  "    given-names: Afif" \
  "message: \"If you use this code, please cite the paper.\"" \
  "# Add DOI / journal reference once available."

stub ".gitignore" \
  "__pycache__/" \
  "*.pyc" \
  ".ipynb_checkpoints/" \
  "# Uncomment if data files are too large to commit:" \
  "# data/processed/*.npy" \
  "# data/forecasts/*.npy"

# =============================================================================
# 01_data_and_sizing
# =============================================================================
stub "01_data_and_sizing/data_loading.py" \
  "\"\"\"Load Karoun load (.m) + cleaned weather CSV, align to 8760 hourly steps." \
  "Source: PV_sizing.ipynb -> 'Pair Matching' cell." \
  "Outputs: aligned load + weather series used by everything downstream.\"\"\""

stub "01_data_and_sizing/pv_sizing.py" \
  "\"\"\"pvlib pipeline: specific yield (1 kWp) -> per-tier PV -> hourly PV series." \
  "Source: PV_sizing.ipynb -> 'Specific Yield' + 'Getting Total Solar power/tier'." \
  "Saves: pv_hourly_tier1..4.npy (paper uses tier1 = 30%).\"\"\""

stub "01_data_and_sizing/battery_sizing.py" \
  "\"\"\"LPSP sweep to pick the smallest battery meeting the tier target." \
  "Source: PV_sizing.ipynb -> 'Sizing the batteries' + 'tier 4 extended search'.\"\"\""

stub "01_data_and_sizing/README.md" \
  "# 01 — Data & sizing" \
  "Run data_loading -> pv_sizing -> battery_sizing. Produces pv_hourly_tierX.npy."

# =============================================================================
# 02_forecaster
# =============================================================================
stub "02_forecaster/tcn_model.py" \
  "\"\"\"TCN architecture definition (dilation blocks, filters, dropout)." \
  "Source: your TCN training notebook/script.\"\"\""

stub "02_forecaster/load_tcn.py" \
  "\"\"\"Instantiate tcn_model and load trained weights (models/tcn/tcn_best.pt)." \
  "Minimal example showing how to load and run a forward pass.\"\"\""

stub "02_forecaster/evaluate_tcn.py" \
  "\"\"\"Reproduce the TCN test-set metrics (MAE/RMSE/MBE/skill) on the clean data." \
  "Source: your TCN evaluation code.\"\"\""

stub "02_forecaster/precompute_kt.py" \
  "\"\"\"Predict-and-store: run the TCN over 2020 and save the year-long kt lookup" \
  "table that the RL wrapper reads at runtime. Falls back to persistence on" \
  "sensor-outage hours (~40%), per the paper. Saves data/forecasts/kt_lookup_2020.npy.\"\"\""

stub "02_forecaster/README.md" \
  "# 02 — Forecaster" \
  "load_tcn shows loading; evaluate_tcn reproduces metrics; precompute_kt writes" \
  "the kt lookup table needed by the +TCN agents."

# =============================================================================
# 03_environment (shared by all agents)
# =============================================================================
stub "03_environment/build_microgrid.py" \
  "\"\"\"Assemble the pymgrid Microgrid (PV/Load/Battery/Genset/Unbalanced) per tier," \
  "plus BatteryActionConverter." \
  "Source: PV_sizing.ipynb -> 'Microgrid Generation' cell.\"\"\""

stub "03_environment/rl_wrapper.py" \
  "\"\"\"Gym-style wrapper shared by PPO/TD3: state vector, action mapping, and the" \
  "6-term shaped REWARD with its coefficients (this is the reward the paper" \
  "promises to release). Optional kt-forecast augmentation via a flag." \
  "Source: PV_sizing.ipynb -> TD3 'Wrapper' cell (the env wrapper + reward).\"\"\""

stub "03_environment/README.md" \
  "# 03 — Environment" \
  "build_microgrid builds the physical sim; rl_wrapper adds the RL interface and" \
  "reward. Both agents import from here — do not duplicate the reward."

# =============================================================================
# 04_ppo
# =============================================================================
stub "04_ppo/ppo_agent.py" \
  "\"\"\"PPO actor/critic networks (custom PyTorch). Source: your PPO code.\"\"\""
stub "04_ppo/train_ppo.py" \
  "\"\"\"Train PPO. Flag --tcn / --no-tcn selects whether the kt forecast is in the" \
  "state (and --horizon H for the +TCN case). Saves to models/ppo/.\"\"\""
stub "04_ppo/evaluate_ppo.py" \
  "\"\"\"Evaluate a saved PPO checkpoint over the 36 test pairs -> total loss load.\"\"\""
stub "04_ppo/README.md" \
  "# 04 — PPO" "train_ppo (±TCN) then evaluate_ppo. Imports env from 03_environment."

# =============================================================================
# 05_td3
# =============================================================================
stub "05_td3/td3_agent.py" \
  "\"\"\"TD3 actor + twin critics + replay buffer (custom PyTorch)." \
  "Source: PV_sizing.ipynb -> 'TD3' section (imports/agent) + your TD3 code.\"\"\""
stub "05_td3/train_td3.py" \
  "\"\"\"Train TD3. Flag --tcn / --no-tcn (+ --horizon H). Saves to models/td3/.\"\"\""
stub "05_td3/evaluate_td3.py" \
  "\"\"\"Evaluate a saved TD3 checkpoint over the 36 test pairs -> total loss load.\"\"\""
stub "05_td3/README.md" \
  "# 05 — TD3" "train_td3 (±TCN) then evaluate_td3. Imports env from 03_environment."

# =============================================================================
# 06_analysis
# =============================================================================
stub "06_analysis/randomized_kt_test.py" \
  "\"\"\"Re-evaluate a trained +TCN model with the kt slot replaced by U(0,1.5)." \
  "Reports loss-load degradation vs. real kt (the asymmetry result)." \
  "Set MODEL_PATH at the top.\"\"\""
stub "06_analysis/sensitivity_probe.py" \
  "\"\"\"Sweep kt over [0,1] at each visited state; report actor/critic output range." \
  "Runs ONE model at a time — set MODEL_PATH at the top, then re-run per model.\"\"\""
stub "06_analysis/README.md" \
  "# 06 — Analysis" \
  "randomized_kt_test and sensitivity_probe each take one MODEL_PATH at the top."

# =============================================================================
# data/  (markers + manifest; link upstream, ship your derived files)
# =============================================================================
stub "data/DATA.md" \
  "# Data sources and provenance" \
  "" \
  "## Linked (do NOT redistribute if terms forbid it — link instead)" \
  "- Weather: Ras Baalbak ground station — <ADD LINK / SOURCE>" \
  "- Load: Qaraoun / EDL via Karaki group, AUB — <ADD LINK / CONTACT>" \
  "" \
  "## Shipped (your derived work product)" \
  "- data/processed/baalbeck_2020_hourly_rl.csv  (interpolated hourly RL weather)" \
  "- data/processed/tcn_clean_hourly.csv         (QC'd hourly data for TCN)" \
  "- data/processed/pv_hourly_tier1..4.npy        (per-tier PV series)" \
  "- data/forecasts/kt_lookup_2020.npy            (TCN predict-and-store output)" \
  "" \
  "Note licenses for each item here."

data "data/processed/baalbeck_2020_hourly_rl.csv" "interpolated hourly weather for the RL env (2020)"
data "data/processed/Data_year_karoun.m"          "Karoun hourly load matrix (MATLAB source)"
data "data/processed/tcn_clean_hourly.csv"        "QC'd hourly data the TCN was trained on"
data "data/processed/pv_hourly_tier1.npy"         "tier1 (30%) hourly PV series"
data "data/processed/pv_hourly_tier2.npy"         "tier2 (40%) hourly PV series"
data "data/processed/pv_hourly_tier3.npy"         "tier3 (50%) hourly PV series"
data "data/processed/pv_hourly_tier4.npy"         "tier4 (60%) hourly PV series"
data "data/forecasts/kt_lookup_2020.npy"          "year-long kt forecast lookup table"

# =============================================================================
# models/  (trained-weight markers)
# =============================================================================
stub "models/README.md" \
  "# Trained models" \
  "tcn/  — TCN weights;  ppo/ & td3/ — best ±TCN checkpoints used in the paper."
data "models/tcn/tcn_best.pt"        "trained TCN weights"
data "models/ppo/ppo_noTCN.pt"       "PPO baseline (no forecast)"
data "models/ppo/ppo_TCN_h7.pt"      "best PPO + TCN (horizon 7)"
data "models/td3/td3_noTCN.pt"       "TD3 baseline (no forecast)"
data "models/td3/td3_TCN_h23.pt"     "best TD3 + TCN (horizon 23)"

# =============================================================================
# docs/  (the QC-flag definitions the paper promises)
# =============================================================================
stub "docs/qc_flag_definitions.md" \
  "# Quality-control flag definitions" \
  "PLACEHOLDER — paste the flag definitions provided by the data authors" \
  "(the paper points readers here)."

# =============================================================================
# OPTIONAL — paper-reported but not in your current 5-section plan.
# Uncomment the block to scaffold them too.
# =============================================================================
# stub "04b_qlearning/qlearning.py" \
#   "\"\"\"Tabular Q-learning baseline (discretised env, AUTO genset)." \
#   "Source: your Q-learning code.\"\"\""
# stub "05_td3/buffer_ablation.py" \
#   "\"\"\"Retrain TD3 (no-TCN) at buffer sizes {5e5,1e5,1e4,5e3}; record loss load." \
#   "Evidence for the replay-buffer explanation of the TD3>PPO gap.\"\"\""

echo
echo "Done. Tree created under ./$ROOT"
echo "Replace each *.placeholder and each stub with your real file."
