```{toctree}
:maxdepth: 2
:hidden:

self
About_XRC
Getting_Started
Using_XRC
```

# Home

```{attention}
Note that although GaMPEN's current documentation is fairly substantive, we are still working on some parts of the documentation and some Tutorials. If you run into issues while trying to use GaMPEN, please contact us! We will be more than happy to help you!
```


***

The Galaxy Morphology Posterior Estimation Network (GaMPEN) is a Bayesian machine learning framework that can estimate robust posteriors (i.e., values + uncertainties) for structural parameters of galaxies. As the above image shows, GaMPEN also automatically crops input images to an optimal size before structural parameter estimation.

GaMPEN's predicted posteriors are extremely well-calibrated ($<5\%$ deviation) and have been shown to be up to $\sim 60\%$ more accurate compared to the uncertainties predicted by many
light-profile fitting algorithms. 

Once trained, it takes GaMPEN less than a millisecond to perform a single model evaluation on a CPU. Thus, GaMPEN's posterior prediction capabilities are ready for large galaxy samples expected from upcoming large imaging surveys, such as Rubin-LSST, Euclid, and NGRST.



## First Steps with GaMPEN
0. For a quick blog-esque introduction to the most important features of Redshift-Classifier(X-Ray), please check out [About](./About_XRC.md).
:::{tip}
For a deep-dive, please refer to [Dainotti et. al. 2022](https://arxiv.org/abs/2408.08763).
:::
1. Follow the installation instructions and quick-start guide in [Getting Started](./Getting_Started.md).
2. Review the [Usage](./Using_XRC.md) page to dive into the details about the various user-facing functions that our classifier provides and how to use them in a GUI environment.

