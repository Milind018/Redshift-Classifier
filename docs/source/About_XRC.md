# About

## Why was Redshift-Classifier (X-Ray) developed?
Although Convolutional Neural Networks (CNNs) have been used for galaxy morphology determination for quite some time now, a few challenges had persisted. 

Most previously developed CNNs provided broad morphological classifications; and there had been very limited work on estimating structural parameters of galaxies or associated uncertainties using CNN. Even popular non-machine learning tools like Galfit severely underestimate uncertainties by values as high as $\sim75\%$. 

The computation of full Bayesian posteriors for these structural parameters is crucial for drawing scientific inferences that account for uncertainty and are indispensable in the derivation of robust scaling relations or tests of theoretical models using morphology.

One other challenge of using CNNs in astronomy, is the necessity to use fixed cutout sizes. Many practitioners choose to use a large cutout size for which "most galaxies" would remain in the frame. However, this means that typical cutouts contain other galaxies in the frame, often leading to less accurate results. Thus, this becomes a bottleneck when applying CNNs to galaxies over a wide magnitudes or redshifts.

In order to address these above challenges, we developed GaMPEN.

:::{admonition} Redshift-Classifier (X-Ray) Feature Summary:-
:class: note

1. GaMPEN estimates posterior distributions for (user-selected) structural parameters of galaxies.

    * GaMPEN's predicted posteriors are **extremely well-calibrated and accurate ($\lesssim 5\%$ derivation)**. They have been shown to be **upto $\sim60\%$ more accurate compared to uncertainties predicted by light-profile fitting algorithms.**

    * GaMPEN takes into account both aleatoric & epistemic uncertainties.

    * GaMPEN incorporates the full covariance matrix in its loss function allowing it to achieve well-calibrated uncertainties for all output parameters.

2. GaMPEN automatically crops input images to an optimal size before determining their morphology.
    *  Due to GaMPEN's design, this step requires no additional training step; except the training to predict structural parameters.
:::

 

## What Parameters and Surveys can Redshift-Classifier (X-Ray) be Used for?

The [publicly released GaMPEN models](./Public_data.md) can be easily used for the specific surveys (and magnitude/redshift ranges) on which the models were trained. For example, our [Hyper Suprime-Cam (HSC) models](./Public_data.md#hsc-wide-pdr2-galaxies) can be used to estimate the bulge-to-total light ratio, effective radius, and flux of HSC galaxies till $z < 0.75$.

:::{note}
However, GaMPEN models can be trained from scratch to determine **any combination of parametric and non-parametric structural parameters** (e.g., Sersic Index, Concentration, Asymmetry, etc.) for **any space or ground-based imaging survey**. 
:::

The only catch is that if your data or desired prediction-parameters are different from what we used to train the models, you might have to either fine-tune one of the publicly-released models or train a new model from scratch. We provide a couple of example scenarios below:-

* **Predicting on HSC Data but with Fainter/Higher Redshift Galaxies or Data in a Different Band:** Start with a publicly-released model that is the closest to your dataset; then fine-tune this model using $\sim \mathcal{O} (10^3)$ galaxies with available ground-truth values.

* **Predicting Structural Parameters on HSC Data Not Included in Our Public Release:** Start with our publicly-released models on real HSC data; discard the last few layers; re-train with ground-truth values for the new structural parameters you want to predict (e.g., Sérsic Index, Concentration, etc.) for  $\sim \mathcal{O} (10^3-10^4)$ galaxies.

* **Predicting on Dark Energy Survey Data:** Start with our publicly-released models on real HSC data (as this will be better than starting from a random initialization); retrain with $\sim \mathcal{O} (10^3-10^4)$ real DES galaxies with ground-truth values.

Don't hesitate to contact us if you want our help/advice in training a GaMPEN model for your survey/parameters! 

## More Technical Details About Redshift-Classifier (X-Ray)

### GaMPEN's Architecture

![GaMPEN architecture](../assets/GaMPEN_architecture.png "Architecture of GaMPEN")

GaMPEN's architecture consists of two separate entities:-
 * an upstream Spatial Transformer Network (STN) which enables GaMPEN to automatically crop galaxies to an optimal size;
 * a downstream Convolutional Neural Network (CNN) which enables GaMPEN to predict posterior distributions for various morphological parameters.

GaMPEN's design is based on our previously successful classification CNN, [GaMorNet](https://gamornet.readthedocs.io/en/latest/), as well as as different variants of the Oxford Visual Geometry Group networks. We tried a variety of different architectures before finally converging on this design.



## Publications
The Redshift-Classifier(X-Ray) was initially introduced in [Dainotti et. al. 2025](https://arxiv.org/abs/2408.08763). Please cite this publication if you make use of the Redshift-Classifier (X-ray) Web app or some code herein.


## Attribution Info.

Please cite the below mentioned publication if you make use of GaMPEN or some code herein.

``` tex
@misc{dainotti2025grbredshiftclassifierfollowup,
      title={GRB Redshift Classifier to Follow-up High-Redshift GRBs Using Supervised Machine Learning}, 
      author={Maria Giovanna Dainotti and Shubham Bhardwaj and Christopher Cook and Joshua Ange and Nishan Lamichhane and Malgorzata Bogdan and Monnie McGee and Pavel Nadolsky and Milind Sarkar and Agnieszka Pollo and Shigehiro Nagataki},
      year={2025},
      eprint={2408.08763},
      archivePrefix={arXiv},
      primaryClass={astro-ph.HE},
      url={https://arxiv.org/abs/2408.08763}, 
}
```


## Getting Help/Contributing

If you have a question, please send me an e-mail at this
`mariagiovannadainotti@xxxxx.it` yahoo address.

If you have spotted a bug in the code/documentation or you want to
propose a new feature, please feel free to open an issue/a pull request
on GitHub.
