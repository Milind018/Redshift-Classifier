# Redshift-Classifier (X-Ray)

<!--[![Status of Build and Tests Workflow](https://github.com/aritraghsh09/GaMPEN/actions/workflows/main.yml/badge.svg)](https://github.com/aritraghsh09/GaMPEN/actions/workflows/main.yml)-->
[![Documentation Status](https://readthedocs.org/projects/gampen/badge/?version=latest)](https://redshift-classifier.readthedocs.io/en/latest/)
[![R Version 4.3](https://img.shields.io/badge/R-4.3-blue)](https://cran.r-project.org/)
[![Python Version 3.8](https://img.shields.io/badge/Python-3.8-blue)](https://www.python.org/downloads/)
[![GitHub license](https://img.shields.io/github/license/Milind018/Redshift-Classifier)](https://github.com/Milind018/Redshift-Classifier/blob/main/LICENSE)
[![image](https://img.shields.io/badge/code%20style-black-000000.svg)](https://github.com/psf/black)
[![Code DOI](https://zenodo.org/badge/299731956.svg)](https://zenodo.org/badge/latestdoi/299731956)
<!--[![Publication DOI](https://img.shields.io/badge/publication%20doi-10.3847%2F1538--4357%2Fac7f9e-blue)](https://doi.org/10.3847/1538-4357/ac7f9e)-->
[![arXiv](https://img.shields.io/badge/arXiv-2408.08763-blue)](https://arxiv.org/abs/2408.08763)


Gamma-ray bursts (GRBs) are intense, short-lived bursts of gamma-ray radiation observed up to a
high redshift (z ∼ 10) due to their luminosities. Thus, they can serve as cosmological tools to probe the
early Universe. However, we need a large sample of high−z GRBs, currently limited due to the difficulty
in securing time at the large aperture Telescopes. Thus, it is painstaking to determine quickly whether
a GRB is high−z or low−z, which hampers the possibility of performing rapid follow-up observations.
Previous efforts to distinguish between high− and low−z GRBs using GRB properties and machine
learning (ML) have resulted in limited sensitivity. In this study, we aim to improve this classification
by employing an ensemble ML method on 251 GRBs with measured redshifts and plateaus observed
by the Neil Gehrels Swift Observatory. Incorporating the plateau phase with the prompt emission,
we have employed an ensemble of classification methods to enhance the sensitivity unprecedentedly.
Additionally, we investigate the effectiveness of various classification methods using different redshift
thresholds, zthreshold=zt at zt = 2.0, 2.5, 3.0, and 3.5. We achieve a sensitivity of 87% and 89% with
a balanced sampling for both zt = 3.0 and zt = 3.5, respectively, representing a 9% and 11% increase
in the sensitivity over Random Forest used alone. Overall, the best results are at zt = 3.5, where the
difference between the sensitivity of the training set and the test set is the smallest. This enhancement
of the proposed method paves the way for new and intriguing follow-up observations of high−z GRBs.

# Documentation

The Redshift-Classifier's (X-Ray) documentation is available in this repository and also hosted 
on [readthedocs.io](https://gampen.readthedocs.io/) . Although the documentation
is fairly complete; if you are trying to use  Redshift-Classifier(X-Ray) Web-app and run into issues, 
please get in touch with us!

# Publications
The Redshift-Classifier(X-Ray) was initially introduced in the following publication. Please cite this publication if you make use of Redshift-Classifier(X-Ray) Web-app or some code herein.

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
# License

Copyright 2025 Maria Giovanna Dainotti, Shubham Bhardwaj, Milind Sarkar & contributors

Made available under a [GNU GPL
v3.0](https://github.com/Milind018/Redshift-Classifier/blob/main/LICENSE)
license.

# Contributors

The Redshift-Classifier(X-Ray) Ensemble Learning Framework and Web-App was initially developed by Shubham and Milind

The initial documentation was developed by [Milind](https://milind018.github.io/) and [Shubham](https://scholar.google.com/citations?user=D8R-iWoAAAAJ&hl=en)


# Getting Help/Contributing

If you have a question, please send me an e-mail at this
`mariagiovannadainotti@xxxxx.it` yahoo address.

If you have spotted a bug in the code/documentation or you want to
propose a new feature, please feel free to open an issue/a pull request
on GitHub.