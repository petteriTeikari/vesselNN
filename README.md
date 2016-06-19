# vesselNN

## Getting Started

Clone this repository with all the submodules (remove the `--recursive` if you don't want the datasets and the submodules)

```
git clone --recursive https://github.com/petteriTeikari/vesselNN
```

The structure of the repository is as following

* `configs` contains the config files specifying the network parameters, locations of the data, etc. for each framework currently only having ZNN configs. In the future, there are plans to provide scripts for common frameworks such as TensorFlow, Theano and Caffe.
* `vesselNN_dataset` contains the dataset provided with the paper consisting of 12 volumetric vasculature stacks obtained using two-photon microsope. 
* `vesselNNlab` contains some Matlab helper functions to post-process and analyze the ZNN results. * 
* `znn-release` the actual deep learning framework [ZNN](https://github.com/seung-lab/znn-release/) developed at MIT/Princeton.

### ZNN setup

The best idea is to follow the documentation from [ZNN repository](https://github.com/seung-lab/znn-release/) of how to setup the framework as these instructions (June 2016) can be subject to changes as the framework is still in its experimental state.

The ZNN is working only under MacOS/Linux (Ubuntu 14.04.3 LTS seems to work with no problems), and has the following prequisities:
* [fftw](https://github.com/seung-lab/znn-release/) (`libfftw3-dev`)
* [boost](https://github.com/seung-lab/znn-release/) (`libboost-all-dev`)
* [BoostNumpy](https://github.com/seung-lab/znn-release/) (clone from Github)
* [jemalloc](https://github.com/seung-lab/znn-release/) (`libjemalloc-dev`)
* [tifffile](https://github.com/seung-lab/znn-release/) (`python-tifffile`)

### Xeon Phi acceleration

It is possible to accelerate the framework using the [Xeon Phi accelerator](http://www.intel.co.uk/content/www/uk/en/processors/xeon/xeon-phi-detail.html) which have come down in price recently (e.g. see this [Reddit thread](https://www.reddit.com/r/buildapcsales/comments/2kmlxp/other_intel_xeon_phi_coprocessor_31s1p_195_msrp/). However, it should be noted that the user-friendliness of Xeon Phi is nowhere near of the near "plug'n'play" acceleration provided by NVIDIA GPUs for example. You first need a modern motherboard (see [recommended motherboards](https://streamcomputing.eu/blog/2015-08-01/xeon-phi-knights-corner-compatible-motherboards/) by Stream Computing), and you will need to obtain the [Intel Math Kernel Library (MKL)](https://software.intel.com/en-us/intel-mkl) that is free for non-commercial use. For example the Asus WS series (e.g. [X99-E WS
Overview](https://www.asus.com/uk/Motherboards/X99E_WS/) seem to support the Xeon Phi accelerators based on [Puget Systems](https://www.pugetsystems.com/labs/hpc/Will-your-motherboard-work-with-Intel-Xeon-Phi-490/)

## The use of framework



## References

If you find this vasculature segmentation approach useful and plan to cite it, improve the network architecture, add more training data, fine-tune, etc., you can use the following citation:

* Teikari, P., Santos, M., Poon, C. and Hynynen, K. (2016) Deep Learning Convolutional Networks for Multiphoton Microscopy Vasculature Segmentation. [arXiv:1606.02382](http://arxiv.org/abs/1606.02382).

And do not forget to cite the original ZNN paper that inspired this:

* Zlateski, A., Lee, K. & Seung, H. S. (2015) ZNN - A Fast and Scalable Algorithm for Training 3D Convolutional Networks on Multi-Core and Many-Core Shared Memory Machines. [arXiv:1510.06706](http://arxiv.org/abs/1510.06706).
* Lee, K., Zlateski, A., Vishwanathan, A. & Seung, H. S. (2015) Recursive Training of 2D-3D Convolutional Networks for Neuronal Boundary Detection. [arXiv:1508.04843](http://arxiv.org/abs/1508.04843).
