module RobustStats

"""
Functions from the field of robust statistics.

Location estimators:
bisquare_weighted_mean - Mean with weights given by the bisquare rho function.
huber_weighted_mean    - Mean with weights given by Huber's rho function.
trimean                - Tukey's trimean, the average of the median and the midhinge.
shorth_range           - Primarily a dispersion estimator, but location=True gives a (poor) location.

Dispersion estimators:
median_abs_dev - Median absolute deviation from the median.
shorth_range   - Length of the shortest closed interval containing at least half the data.  
Qscale         - Normalized Rousseeuw & Croux Q statistic, from the 25%ile of all 2-point distances.

Utility functions:
high_median    - Weighted median

Recommendations:
For location, suggest the bisquare_weighted_mean with k=3.9*sigma, if you can make any reasonable
guess as to the Gaussian-like width sigma.  If not, trimean is a good second choice, though less
efficient.

For dispersion, the Qscale is very efficient for nearly Gaussian data.  The median_abs_dev is 
the most robust though less efficient.  If Qscale doesn't work, then shorth_range is a good
second choice.

Created on April 16, 2015

Joe Fowler, NIST Boulder Laboratories
"""

export 
    bisquare_weighted_mean,
    trimean

include("location_estimators.jl")
end # module
