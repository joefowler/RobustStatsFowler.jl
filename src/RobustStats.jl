module RobustStats

using Lexicon, Docile
@document

"""
Functions from the field of robust statistics.

##Location estimators:
* bisquareWM     - Mean with weights given by the bisquare rho function.
* huberWM        - Mean with weights given by Huber's rho function.
* trimean        - Tukey's trimean, the average of the median and the midhinge.

## Dispersion estimators:
* shorthalfrange - Length of the shortest closed interval containing at least half the data.  
* scaleQ         - Normalized Rousseeuw & Croux Q statistic, from the 25%ile of all 2-point distances.
* scaleQ!        - Same as scaleQ() except that it sorts the input data.
* scaleS         - Normalized Rousseeuw & Croux S statistic, from the ??? 2-point distances. (TODO)
* scaleS!        - Same as scaleS(), except that it sorts the input data. (TODO)

## Utility functions:
* _weightedhighmedian  - Weighted median with round-high behavior (not exported)

## Recommendations:
For location, consider the bisquare_weighted_mean with k=3.9*sigma, if you can make any reasonable
guess as to the "Gaussian-like width" sigma.  If not, trimean is a good second choice, though less
efficient.

For dispersion, the Qscale is very efficient for nearly Gaussian data.  The mad (median absolute
deviation from the median) is the most robust though less efficient.  
If Qscale doesn't work, then shorthalfrange is a good second choice.

Created on April 16, 2015

Joe Fowler, NIST Boulder Laboratories
"""
RobustStats

export 
    bisquareWM,
    huberWM,
    trimean,
    shorthrange,
    shorthrange!,
    # scaleS,
    # scaleS!,
    scaleQ,
    scaleQ!

include("location_estimators.jl")
include("dispersion_estimators.jl")
end # module
