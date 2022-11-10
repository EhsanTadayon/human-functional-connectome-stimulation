### Human Functional Connectome Brain Network Stimulation 
Author: Ehsan Tadayon, MD

This repository contains a script to generate following cortical maps in the individual structural MRI space: 
1) group-based functional networks (Yeo 2011 - 7 or 17 Networks)
2) their corresponding confidence maps (Yeo 2011 - Confidence Maps) 

It registers Yeo-2011 maps in fsaverage space (normalized space) to individual subject space (both native MRI space and freesurfer modified space) using surface-based reistration. 

If you use this script, please cite the following paper: 

Ozdemir, R. A., Tadayon, E., Boucher, P., Momi, D., Karakhanyan, K. A., Fox, M. D., ... & Santarnecchi, E. (2020). Individualized perturbation of the human connectome reveals reproducible biomarkers of network dynamics relevant to cognition. Proceedings of the National Academy of Sciences, 117(14), 8115-8125.

<b> How to run: </b>

```bash yeo2subject.sh <subject> <nNetworks> <subjects_dir> ```

subject: freesurfer processed subject_id 

nNetworks: 7 or 17 

subjects_dir: Freesurfer SUBJECTS_DIR
  



