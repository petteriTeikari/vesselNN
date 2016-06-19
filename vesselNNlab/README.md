# Matlab scripts

Helper scripts to support the `znn-release` 3D framework

The structure is the following:

## `3rdParty`

Contains 3rd part implementations for edge detection using Structured Forests by Piotr Dollar (https://github.com/pdollar/edges) which require the toolbox by the same author (https://pdollar.github.io/toolbox/). `densecrf` is a command-line fork from Philipp Krähenbühl which could be later updated to the Matlab wrapper by (Johannes Ulén)[https://github.com/johannesu/meanfield-matlab]. The `EvaluateSegmentation` repository contains a good collection of different quality metrics for segmentation evaluation. The `latexTable` creates automatically latex tables to be used in articles.

## `IO`

Helper functions to handle simple I/O operations

## `filters`

Filter wrappers for basic filters that I have used during the "manual phase" outside deep learning

## `mesh`

Only the Marching Cubes wrapper to create meshes from raster stacks.

## `metrics`

`MAIN_evaluateOutputResults.m` evaluates the quality of the segmentation of the output of different architectures and different post-processing results and it provides a way to track the progress of the performance of future architectures.

## `utils`

`gt_createSeed_simplified2.m` is a quick'n'dirty helper function to create rough seeds for the vasculature labels so that they can be refined manually in GIMP for example. In the future it would make more sense to use the deep learning network architecture itself as a "seed generator" for future ground truth labels

## `visualization`

`labelPercentages.m` quantifies class imbalance per file

`plot_trainingData.m` plots the training data as maximum intensity projections (MIP)
