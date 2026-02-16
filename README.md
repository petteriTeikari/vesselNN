# vesselNN

> Volumetric brain vessel segmentation using 3D convolutional networks and the ZNN framework, as described in [Teikari et al. (2016), arXiv:1606.02382](https://arxiv.org/abs/1606.02382).

```mermaid
%%{init: {'theme': 'base', 'themeVariables': {'primaryColor': '#E8F4FD', 'primaryBorderColor': '#7BA7C9', 'primaryTextColor': '#2C3E50', 'secondaryColor': '#FDF2E9', 'secondaryBorderColor': '#D4A574', 'secondaryTextColor': '#2C3E50', 'tertiaryColor': '#EAFAF1', 'tertiaryBorderColor': '#82C9A1', 'tertiaryTextColor': '#2C3E50', 'lineColor': '#5D6D7E', 'textColor': '#2C3E50', 'background': '#FFFFFF', 'mainBkg': '#E8F4FD', 'nodeBorder': '#7BA7C9', 'clusterBkg': '#F8F9FA', 'clusterBorder': '#BDC3C7', 'fontSize': '14px'}}}%%
graph LR
    A[2PM Volume] --> B[BM4D Denoising]
    B --> C[VD2D Stage]
    C --> D[VD2D3D Stage]
    D --> E[Segmented Volume]
    E --> F[Evaluation]

    style A fill:#FDF2E9,stroke:#D4A574
    style B fill:#E8F4FD,stroke:#7BA7C9
    style C fill:#E8F4FD,stroke:#7BA7C9
    style D fill:#E8F4FD,stroke:#7BA7C9
    style E fill:#EAFAF1,stroke:#82C9A1
    style F fill:#EAFAF1,stroke:#82C9A1
```

## Overview

vesselNN applies 3D convolutional networks to the problem of segmenting blood vessels in volumetric two-photon microscopy (2PM) images of brain tissue. The approach uses a recursive two-stage architecture (VD2D followed by VD2D3D) built on the [ZNN framework](https://github.com/seung-lab/znn-release/) developed at MIT/Princeton. The first stage processes 2D slices, and its output is fed into the second stage which operates on full 3D volumes, progressively refining the segmentation.

The repository includes network configuration files, training and inference scripts, and an open-source [companion dataset](https://github.com/petteriTeikari/vesselNN_dataset) of 12 volumetric stacks with dense voxel-level annotations. The MATLAB helper package `vesselNNlab` provides post-processing and analysis utilities for the segmentation results.

This work targets researchers in neurovascular imaging, connectomics, and biomedical image segmentation who need automated vessel delineation in volumetric microscopy data.

## Key Features

- Recursive VD2D to VD2D3D segmentation pipeline for progressive refinement
- Built on the ZNN framework with optional Xeon Phi acceleration
- Open-source dataset of 12 two-photon microscopy stacks with manual labels
- MATLAB post-processing and visualization tools (vesselNNlab)
- Configurable network architectures via `.znn` specification files

## Quick Start

```bash
# Clone with all submodules (dataset + ZNN framework)
git clone --recursive https://github.com/petteriTeikari/vesselNN

# Build ZNN (requires fftw, boost, jemalloc -- Linux/macOS only)
cd vesselNN/znn-release && make

# Train the VD2D stage
python train.py -c ../../configs/ZNN_configs/config_VD2D_tanh.cfg

# Run inference
python forward.py -c ../../configs/ZNN_configs/config_VD2D_tanh.cfg
```

### Dependencies

- Linux or macOS (no Windows support)
- [fftw](http://www.fftw.org/) (`libfftw3-dev`)
- [boost](http://www.boost.org/) (`libboost-all-dev`)
- [Boost.NumPy](https://github.com/ndarray/Boost.NumPy)
- [jemalloc](http://jemalloc.net/) (`libjemalloc-dev`)
- [tifffile](https://pypi.python.org/pypi/tifffile)

## Project Structure

```
vesselNN/
├── configs/
│   └── ZNN_configs/
│       ├── networks/          # Network architecture definitions (.znn)
│       ├── datasetPaths/      # Dataset path specifications (.spec)
│       ├── config_VD2D_tanh.cfg
│       └── config_VD2D3D_tanh.cfg
├── vesselNN_dataset/          # Companion dataset (submodule)
├── vesselNNlab/               # MATLAB post-processing tools
└── znn-release/               # ZNN framework (submodule)
```

## Citation

```bibtex
@article{teikari2016deep,
  title={Deep Learning Convolutional Networks for Multiphoton Microscopy
         Vasculature Segmentation},
  author={Teikari, Petteri and Santos, Marc and Poon, Charissa and Hynynen, Kullervo},
  journal={arXiv preprint arXiv:1606.02382},
  year={2016}
}
```

See also the ZNN framework papers:

- Zlateski, A., Lee, K. and Seung, H.S. (2015). ZNN -- A Fast and Scalable Algorithm for Training 3D Convolutional Networks on Multi-Core and Many-Core Shared Memory Machines. [arXiv:1510.06706](https://arxiv.org/abs/1510.06706)
- Lee, K., Zlateski, A., Vishwanathan, A. and Seung, H.S. (2015). Recursive Training of 2D-3D Convolutional Networks for Neuronal Boundary Detection. [arXiv:1508.04843](https://arxiv.org/abs/1508.04843)

## License

MIT
