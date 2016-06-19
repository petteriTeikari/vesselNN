# vesselNN

## Getting Started

Clone this repository with all the submodules (remove the `--recursive` if you don't want the datasets and the submodules)

`git clone --recursive https://github.com/petteriTeikari/vesselNN`

The structure of the repository is as following

* `configs` contains the config files specifying the network parameters, locations of the data, etc. for each framework currently only having ZNN configs. In the future, there are plans to provide scripts for common frameworks such as TensorFlow, Theano and Caffe.
* `vesselNN_dataset` contains the dataset provided with the paper consisting of 12 volumetric vasculature stacks obtained using two-photon microsope. 
* `vesselNNlab` contains some Matlab helper functions to post-process and analyze the ZNN results. * 
* `znn-release` the actual deep learning framework [ZNN](https://github.com/seung-lab/znn-release/) developed at MIT/Princeton.

## References

If you find this vasculature segmentation approach useful and plan to cite it, improve the network architecture, add more training data, fine-tune, etc., you can use the following citation:

* Teikari, P., Santos, M., Poon, C. and Hynynen, K. (2016) Deep Learning Convolutional Networks for Multiphoton Microscopy Vasculature Segmentation. [arXiv:1606.02382](http://arxiv.org/abs/1606.02382).

And do not forget to cite the original ZNN paper that inspired this:

* Zlateski, A., Lee, K. & Seung, H. S. (2015) ZNN - A Fast and Scalable Algorithm for Training 3D Convolutional Networks on Multi-Core and Many-Core Shared Memory Machines. [arXiv:1510.06706](http://arxiv.org/abs/1510.06706).
* Lee, K., Zlateski, A., Vishwanathan, A. & Seung, H. S. (2015) Recursive Training of 2D-3D Convolutional Networks for Neuronal Boundary Detection. [arXiv:1508.04843](http://arxiv.org/abs/1508.04843).
