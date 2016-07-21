# vesselNN

This a repository for volumetric vessel segmentation using convolutional network based on ZNN framework as decribed in our arXiv paper [arXiv:1606.02382](http://arxiv.org/abs/1606.02382) (see below for full citation). The repository comes with an [open-source dataset](https://github.com/petteriTeikari/vesselNN_dataset/tree/4daf46cee49f411b759f04ff92b92dd1dbbc25b4) with dense voxel-level annotations for vasculature that we hope that stimulate further research on vascular segmentation using deep learning networks.

## Getting Started

Clone this repository with all the submodules (remove the `--recursive` if you don't want the datasets and the submodules)

```
git clone --recursive https://github.com/petteriTeikari/vesselNN
```

The structure of the repository is as following

* `configs` contains the config files specifying the network parameters, locations of the data, etc. for each framework currently only having ZNN configs. In the future, there are plans to provide scripts for common frameworks such as TensorFlow, Theano and Caffe.
* `vesselNN_dataset` contains the dataset provided with the paper consisting of 12 volumetric vasculature stacks obtained using two-photon microsope. 
* `vesselNNlab` contains some Matlab helper functions to post-process and analyze the ZNN results.
* `znn-release` the actual deep learning framework [ZNN](https://github.com/seung-lab/znn-release/) developed at MIT/Princeton.

### ZNN setup

The best idea is to follow the documentation from [ZNN repository](https://github.com/seung-lab/znn-release/) of how to setup the framework as these instructions (June 2016) can be subject to changes as the framework is still in its experimental state.

The ZNN is working  **only underMacOS/Linux** (Ubuntu 14.04.3 LTS seems to work with no problems), and has the following prequisities:
* [fftw](http://www.fftw.org/) (`libfftw3-dev`)
* [boost](http://www.boost.org/) (`libboost-all-dev`)
* [BoostNumpy](http://github.com/ndarray/Boost.NumPy) (clone from Github to `/python`, and build&install either with `scons` or `cmake`)
* [jemalloc](http://www.canonware.com/jemalloc/) (`libjemalloc-dev`)
* [tifffile](https://pypi.python.org/pypi/tifffile) (`python-tifffile`)

#### Compilation

1. You need to run `make` from the `znn-release` root to compile the `malis_test.cpp`

2. If you want to use the Python (2.xx) interface for the ZNN, you need to go to the `znn-release/python/core` and modify possibly the `Makefile` according to your library locations. Then you need to run `make` to compile `pyznn.cpp`.

### Xeon Phi acceleration

It is possible to accelerate the framework using the [Xeon Phi accelerator](http://www.intel.co.uk/content/www/uk/en/processors/xeon/xeon-phi-detail.html) which have come down in price recently (e.g. see this [Reddit thread](https://www.reddit.com/r/buildapcsales/comments/2kmlxp/other_intel_xeon_phi_coprocessor_31s1p_195_msrp/). However, it should be noted that the user-friendliness of Xeon Phi is nowhere near of the near "plug'n'play" acceleration provided by NVIDIA GPUs for example. You first need a modern motherboard (see [recommended motherboards](https://streamcomputing.eu/blog/2015-08-01/xeon-phi-knights-corner-compatible-motherboards/) by Stream Computing), and you will need to obtain the [Intel Math Kernel Library (MKL)](https://software.intel.com/en-us/intel-mkl) that is free for non-commercial use. For example the Asus WS series (e.g. [X99-E WS
Overview](https://www.asus.com/uk/Motherboards/X99E_WS/) that is commonly used in deep learning builds) seem to support the Xeon Phi accelerators based on [Puget Systems](https://www.pugetsystems.com/labs/hpc/Will-your-motherboard-work-with-Intel-Xeon-Phi-490/). Officially there is no Ubuntu support from Intel for Xeon Phi, but it should be possible to make it run [under Ubuntu 14.04](http://arrayfire.com/getting-started-with-the-intel-xeon-phi-on-ubuntu-14-04linux-kernel-3-13-0/) (Peter from Arrayfire.com).

## The usage of framework

With the Python interface, to **train** the network:

```
python train.py -c ../../configs/ZNN_configs/config_VD2D_tanh.cfg
```

and to do the inference (forward pass):

```
python forward.py -c ../../configs/ZNN_configs/config_VD2D_tanh.cfg
```

The interface at the moment does not allow new images outside the training set to be used for quick inference testing. You need to add your own images to the `.spec` file without the label mask to try the generalization performance of the network.

Note (June 2016)! The instructions for this part at `znn-release` seem to be outdated without the needed `-c` flag as updated to [train.py](https://github.com/seung-lab/znn-release/blob/master/python/train.py).

### Defining config files

Open for example [config_VD2D3D_tanh.cfg](/configs/ZNN_configs/config_VD2D3D_tanh.cfg), and you see the main paths that set up the network architecture and the dataset:

```
# specification file of network architecture
fnet_spec = ../../configs/ZNN_configs/networks/VD2D3D_tanh.znn
# file of data spec
fdata_spec = ../../configs/ZNN_configs/datasetPaths/dataset_forVD2D3D.spec
```

If you are familiar with convolutional network architecture construction, the file [VD2D3D_tanh.znn](https://github.com/petteriTeikari/vesselNN/blob/master/configs/ZNN_configs/networks/VD2D3D_tanh.znn) is rather self-explanatory

[dataset_forVD2D3D.spec](https://github.com/petteriTeikari/vesselNN/blob/master/configs/ZNN_configs/datasetPaths/dataset_forVD2D.spec) defines path for image/label files of your dataset. For example images 1-12 refer to the images from the microscope, 13-24 refer to the output images from the VD2D part of the recursive "two-stage" approach of ZNN. The outputs of the VD2D part are provided in the [dataset repository](https://github.com/petteriTeikari/vesselNN_dataset/tree/4daf46cee49f411b759f04ff92b92dd1dbbc25b4/experiments/VD2D_tanh), and can be used for re-training of the VD2D3D stage, or if you may you can obtain new VD2D outputs for your dataset if you wish.

In the `.cfg` files you specify your typical hyperparameters for training, what files to use for training and testing, whether to use data augmentation, how many CPU cores you use, where to save the output files, whether to correct class imbalance. Special thing in ZNN is that you can optimize your training/inference on your chosen convolution, i.e. if there is a bigger overhead in doing Fourier transforms with FFT over doing spatial domain convolutions. As a practical note, the optimization might sometime give errors, so then you could just use `force_fft = yes`

## References

If you find this vasculature segmentation approach useful and plan to cite it, improve the network architecture, add more training data, fine-tune, etc., you can use the following citation:

* Teikari, P., Santos, M., Poon, C. and Hynynen, K. (2016) Deep Learning Convolutional Networks for Multiphoton Microscopy Vasculature Segmentation. [arXiv:1606.02382](http://arxiv.org/abs/1606.02382).

And do not forget to cite the original ZNN paper that inspired this:

* Zlateski, A., Lee, K. & Seung, H. S. (2015) ZNN - A Fast and Scalable Algorithm for Training 3D Convolutional Networks on Multi-Core and Many-Core Shared Memory Machines. [arXiv:1510.06706](http://arxiv.org/abs/1510.06706).
* Lee, K., Zlateski, A., Vishwanathan, A. & Seung, H. S. (2015) Recursive Training of 2D-3D Convolutional Networks for Neuronal Boundary Detection. [arXiv:1508.04843](http://arxiv.org/abs/1508.04843).

For related papers, you could see the volumetric convolutional network by Merkow et al. (2016) for vascular boundary detection that wa spublished around the same time as this paper:

* Merkow, J., Kriegman, D., Marsden, A. and Tu, Z. (2016). Dense Volume-to-Volume Vascular Boundary Detection. arXiv preprint [arXiv:1605.08401](http://arxiv.org/abs/1605.08401).

## References

### /usr/bin/ld: cannot find -lboost_numpy

You probably have not cloned [BoostNumpy](http://github.com/ndarray/Boost.NumPy) to `/python` folder of `znn-release` and built and install with `scons` or `cmake`.

