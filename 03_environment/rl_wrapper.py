"""Gym-style wrapper shared by PPO/TD3: state vector, action mapping, and the
6-term shaped REWARD with its coefficients (this is the reward the paper
promises to release). Optional kt-forecast augmentation via a flag.
Source: PV_sizing.ipynb -> TD3 'Wrapper' cell (the env wrapper + reward)."""
