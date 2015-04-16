using StatsBase

# Bisquare weighted mean, a location estimator
function bisquare_weighted_mean{T <: Real}(x::Vector{T}, k::Real, center::Real, tol::Real)
    """Return the bisquare weighted mean of the data <x> with a k-value of <k>.
    A sensible choice of <k> is 3 to 5 times the rms width or 1.3 to 2 times the
    full width at half max of a peak.  For strictly Gaussian data, the choices of 
    k= 3.14, 3.88, and 4.68 times sigma will be 80%, 90%, and 95% efficient.

    <center> is used as an initial guess at the weighted mean.
    If <center> is omitted, then the data median will be used.

    The answer is found iteratively, revised until it changes by less than <tol>.  If
    <tol> is omitted, then <tol> will use 1e-5 times the median absolute
    deviation of <x> about its median.

    Data values a distance of more than <k> from the weighted mean are given no
    weight."""

    for _iteration in 1:100
        weights = (1.0-((x-center)/k).^2).^2
        weights[abs(x-center).>k] = 0.0
        newcenter = sum(weights .* x)/sum(weights)
        if abs(newcenter - center)<tol
            return newcenter
        end
        center = newcenter
    end
    # raise RuntimeError("bisquare_weighted_mean used too many iterations.\n"+
    #                    "Consider using higher <tol> or better <center>, or change to trimean(x).")
end


bisquare_weighted_mean{T <: Real}(x::Vector{T}, k::Real, center::Real) =
    bisquare_weighted_mean(x, k, center, 1e-5*mad(x, center))
bisquare_weighted_mean{T <: Real}(x::Vector{T}, k::Real) =
    bisquare_weighted_mean(x, k, median(x))


# Tukey's trimean, a location estimator
function trimean{T <: Real}(x::Vector{T})
    """Return Tukey's trimean for a data set <x>, a measure of its central tendency
    ("location" or "center").

    If (q1,q2,q3) are the quartiles (i.e., the 25%ile, median, and 75 %ile),
    the trimean is (q1+q3)/4 + q2/2. 
    """
    q1,q2,q3 = quantile(x, [.25,.50,.75])
    return 0.25*(q1+q3) + 0.5*q2
end

