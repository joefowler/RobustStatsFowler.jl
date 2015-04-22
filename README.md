# RobustStats

##Location estimators:
* bisquareWM     - Mean with weights given by the bisquare rho function.
* huberWM        - Mean with weights given by Huber's rho function.
* trimean        - Tukey's trimean, the average of the median and the midhinge.
* shorth_range   - Primarily a dispersion estimator, but called with location=true gives a (poor) location.

## Dispersion estimators:
* shorthalfrange - Length of the shortest closed interval containing at least half the data.  
* Qscale         - Normalized Rousseeuw & Croux Q statistic, from the 25%ile of all 2-point distances. (TODO)

## Utility functions:
* high_median    - Weighted median

## Recommendations:
For location, consider the bisquare_weighted_mean with k=3.9*sigma, if you can make any reasonable
guess as to the "Gaussian-like width" sigma.  If not, trimean is a good second choice, though less
efficient.

For dispersion, the Qscale is very efficient for nearly Gaussian data.  The mad (median absolute
deviation from the median) is the most robust though less efficient.  
If Qscale doesn't work, then shorthalfrange is a good second choice.

Created on April 16, 2015

Joe Fowler, NIST Boulder Laboratories

[![Build Status](https://travis-ci.org/joefowler/RobustStats.jl.svg?branch=master)](https://travis-ci.org/joefowler/RobustStats.jl)
