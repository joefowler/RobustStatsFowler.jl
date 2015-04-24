# RobustStats

##Location estimators:
* bisquareWM     - Mean with weights given by the bisquare rho function.
* huberWM        - Mean with weights given by Huber's rho function.
* trimean        - Tukey's trimean, the average of the median and the midhinge.

## Dispersion estimators:
* shorthrange    - Length of the shortest closed interval containing at least half the data.  
* scaleQ         - Normalized Rousseeuw & Croux Q statistic, from the 25%ile of all 2-point distances.
* scaleS         - Normalized Roouseeuw & Croux S statistic, from the median of the median of all 2-point distances. (TODO)

## Utility functions:
* _weightedhighmedian    - Weighted median (breaks ties by rounding up). Used in scaleQ.

## Recommendations:
For location, consider the bisquareWM with k=3.9*sigma, if you can make any reasonable
guess as to the "Gaussian-like width" sigma.  If not, trimean is a good second choice, though less
efficient.

For dispersion, the scaleQ is very efficient for nearly Gaussian data.  The mad (median absolute
deviation from the median) is the most robust though less efficient.  
If scaleQ doesn't work, then shorthrange is a good second choice.

## References:
* Shortest Half-range comes from P.J. Rousseeuw and A.M. Leroy, ["A Robust Scale Estimator Based on the Shortest Half"](http://onlinelibrary.wiley.com/doi/10.1111/j.1467-9574.1988.tb01224.x/abstract) in _Statistica Neerlandica_ Vol 42 (1988), pp. 103-116. doi:10.1111/j.1467-9574.1988.tb01224.x . See also R.D. Martin and R. H. Zamar, ["Bias-Robust Estimation of Scale"](http://projecteuclid.org/euclid.aos/1176349161)  in _Annals of Statistics_ Vol 21 (1993) pp. 991-1017.  doi:10.1214/aoe/1176349161

* Scale-Q and Scale-S statistics are described in P.J. Rousseeuw and C. Croux ["Alternatives to the Median Absolute Deviation"](http://www.jstor.org/stable/2291267) in _J. American Statistical Assoc._ Vo 88 (1993) pp 1273-1283. The time-efficient algorithms for computing them appear in C. Croux and P.J. Rousseeuw, ["Time-Efficient Algorithms for Two Highly Robust Estimators of Scale"](http://link.springer.com/chapter/10.1007/978-3-662-26811-7_58) in _Computational Statistics, Vol I_ (1992), Y. Dodge and J. Whittaker editors, Heidelberg, Physica-Verlag, pp 411-428. If link fails, see ftp://ftp.win.ua.ac.be/pub/preprints/92/Timeff92.pdf

Created on April 16, 2015

Joe Fowler, NIST Boulder Laboratories

[![Build Status](https://travis-ci.org/joefowler/RobustStats.jl.svg?branch=master)](https://travis-ci.org/joefowler/RobustStats.jl)
