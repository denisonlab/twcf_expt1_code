
## Experimental (stimulus presentation) code accompanying the project

> **When awareness outstrips performance: critical tests of subjective
> inflation under inattention**\
> [https://doi.org/10.1101/2025.07.03.661972](https://www.biorxiv.org/content/10.1101/2025.07.03.661972v2)

This repository contains the code used to run the four psychophysics
experiments reported in the paper. Analysis code and data are hosted
separately.  

## Repository structure

```
├── README.md
├── experiments
│   ├── cue_gab_det/             # Exp 1: gabor detection
│   │   ├── expt.m               # ← main entry point (run this)
│   │   ├── expt_param.m         # stimulus & timing parameters
│   │   ├── manual/              # explanation of variables
│   │   │   ├── explanation_of_variables.xlsx             # explanation of variables
│   │   │   ├── twcf_cue_gab_det_param_table.xlsx         # parameter settings used at BU and UCI
│   ├── cue_gab_dis/             # Exp 2: gabor discrimination
│   ├── cue_tex_det/             # Exp 3: texture detection
│   ├── cue_tex_dis/             # Exp 4: texture discrimination
├── supporting_code/             # shared helpers (eyetracking, gamma calibration, stimulus calibration)
```

### Relevant files (per experiment)
 
For each experiment folder, the files a reader is most likely to want:
 
- **`expt.m`** — primary script for running the experiment
- **`expt_params`** — all tunable stimulus, timing, and staircase parameters
---

### Running an experiment

#### Dependencies
- [Psychtoolbox-3](http://psychtoolbox.org/) 

#### Screen calibration (texture experiments only)
Texture experiments require a one-time stimulus calibration that depends on the
display size and viewing distance of the testing setup. This must be done
before running `expt.m`, and must be redone whenever the monitor or viewing
distance changes.

```matlab
cd cue_tex_det          % the experiment folder
expt_calibrateStim      % follow the on-screen calibration procedure
```

#### Run the experiment
```matlab
cd cue_tex_det          % the experiment folder
expt                    % then choose a stage at the prompt (see below)
```
The primary script for running the experiment is `expt.m`, which prompts for which stage to run:
 
| Stage         | Notes                                                                 |
|:---------------|-----------------------------------------------------------------------|
| Practice  | Task instructions and practice trials on easy settings to learn the task. |
| Thresholding  | Per-participant calibration of stimulus strength. Required once per participant before the main experiment. |
| Training | Reference training block. Only for the discrimination experiments (2 and 4). |
| Validation | Practice trials with attentional cues using participant-titrated stimulus settings. |
| Full experiment | The key experimental trials. |   

### Citation

If you use this code, please cite the paper:

``` bibtex
@article{InattentionalInflation,
  title   = {When awareness outstrips performance: critical tests of subjective inflation under inattention},
  author  = {Tian, Karen J and Maniscalco, Brian and Epstein, Michael L and Shen, Angela and Castaneda, Olenka Graham and Kurosawa, Taiga and Motzer, Jennifer A and Olsson, Emil and Russell, Emily E and Walsh, Meghan E and Wang, Juneau and Zeb, Tugral Bek Awrang, Brown, Richard and Lamme, Victor AF and Lau, Hakwan and He, Biyu J and Brascamp, Jan W and Block, Ned and Chalmers, David and Peters, Megan AK and Denison, Rachel N},
  journal = {bioRxiv},
  year    = {2025},
  doi     = {10.1101/2025.07.03.661972},
  url     = {https://www.biorxiv.org/content/10.1101/2025.07.03.661972v2}
}
```