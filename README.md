# RobustStats

##Location estimators:
* bisquareWM     - Mean with weights given by the bisquare rho function.
* huberWM        - Mean with weights given by Huber's rho function.
* trimean        - Tukey's trimean, the average of the median and the midhinge.

## Dispersion estimators:
* shorthrange    - Length of the shortest closed interval containing at least half the data.
* scaleQ         - Normalized Rousseeuw & Croux Q statistic, from the 25%ile of all 2-point distances.
* scaleS         - Normalized Rousseeuw & Croux S statistic, from the median of the median of all 2-point distances.

## Utility functions:
* _weightedhighmedian    - Weighted median (breaks ties by rounding up). Used in scaleQ.

## Recommendations:
For location, consider the bisquareWM with k=3.9*sigma, if you can make any reasonable guess as to the "Gaussian-like width" sigma (see dispersion estimators for this).  If not, trimean is a good second choice, though less efficient.

For dispersion, the scaleS is a good general choice, though scaleQ is very efficient for nearly Gaussian data.  The MAD is the most robust though less efficient.  If scaleS doesn't work, then shorthrange is a good second choice.

The first reference on scaleQ and scaleS (below) is a lengthy discussion of the tradeoffs among scaleQ, scaleS, shortest half, and median absolute deviation (MAD, see BaseStats.mad for Julia implementation). All four have the virtue of having the maximum possible breakdown point, 50%. This means that replacing up to 50% of the data with unbounded bad values leaves the statistic still bounded. The efficiency of Q is better than S and S is better than MAD (for Gaussian distributions), and the influence of a single bad point and the bias due to a fraction of bad points is only slightly larger on Q or S than on MAD. Unlike MAD, the other three do not implicitly assume a symmetric distribution.

To choose between Q and S, the authors note that Q has higher statistical efficiency, but S is typically twice as fast to compute and has lower gross-error sensitivity. An interesting advantage of Q over the others is that its influence function is continuous. For a rough idea about the efficiency, the large-N limit of the standardized variance of each quantity is 2.722 for MAD, 1.714 for S, and 1.216 for Q, relative to 1.000 for the standard deviation (given Gaussian data). The paper gives the ratios for Cauchy and exponential distributions, too; the efficiency advantages of Q are less for Cauchy than for the other distributions.


## References:
* Shortest Half-range comes from P.J. Rousseeuw and A.M. Leroy, ["A Robust Scale Estimator Based on the Shortest Half"](http://onlinelibrary.wiley.com/doi/10.1111/j.1467-9574.1988.tb01224.x/abstract) in _Statistica Neerlandica_ Vol 42 (1988), pp. 103-116. doi:10.1111/j.1467-9574.1988.tb01224.x . See also R.D. Martin and R. H. Zamar, ["Bias-Robust Estimation of Scale"](http://projecteuclid.org/euclid.aos/1176349161)  in _Annals of Statistics_ Vol 21 (1993) pp. 991-1017.  doi:10.1214/aoe/1176349161

* Scale-Q and Scale-S statistics are described in P.J. Rousseeuw and C. Croux ["Alternatives to the Median Absolute Deviation"](http://www.jstor.org/stable/2291267) in _J. American Statistical Assoc._ Vo 88 (1993) pp 1273-1283. The time-efficient algorithms for computing them appear in C. Croux and P.J. Rousseeuw, ["Time-Efficient Algorithms for Two Highly Robust Estimators of Scale"](http://link.springer.com/chapter/10.1007/978-3-662-26811-7_58) in _Computational Statistics, Vol I_ (1992), Y. Dodge and J. Whittaker editors, Heidelberg, Physica-Verlag, pp 411-428. If link fails, see ftp://ftp.win.ua.ac.be/pub/preprints/92/Timeff92.pdf

Created on April 16, 2015
Updated January 24, 2017 for Julia v0.5

Joe Fowler, NIST Boulder Laboratories

[![Build Status](https://travis-ci.org/joefowler/RobustStats.jl.svg?branch=master)](https://travis-ci.org/joefowler/RobustStats.jl)
