function shorthrange_and_location!{T <: Real}(x::Vector{T}, normalize::Bool=false)
    sort!(x)

    n = length(x)         # Number of data values
    nhalves = div(n+1, 2) # Number of minimal intervals (containing at least half the data)
    nobs = 1 + div(n, 2)  # Number of values in each minimal interval

    range_each_half = x[end-nhalves:end]-x[1:nhalves+1]
    idxa = indmin(range_each_half)
    a, b = x[idxa], x[idxa+nobs-1]
    shorth_range = b-a
    
    if normalize
        shorth_range /= (2*.674480)   # The asymptotic expectation for normal data is sigma*2*0.674480
        
        # The small-n corrections depend on n mod 4.  See [citation]
        if n%4==0
            shorth_range *= (n+1.0)/n
        elseif n%4==1
            shorth_range *= (n+1.0)/(n-1.0)
        elseif n%4==2
            shorth_range *= (n+1.0)/n
        else
            shorth_range *= (n+1.0)/(n-1.0)
        end
    end

    # Warning! This returns a triple of (SHrange, SHmean, and SHcenter),
    # where the last two are different estimators of location. These estimators are highly
    # inefficient, and so are potentially fun for showing what inefficient estimators do,
    # but they are not a good plan for actual use. That's why this function isn't exported
    # by the module.
    
    # In this, SHmean is the mean of all samples in the closed range [a,b], and
    # SHcenter = (a+b)/2.  Beware that both of these location estimators have the
    # undesirable property that their asymptotic standard deviation improves only as
    # N^(-1/3) rather than the more usual N^(-1/2).
    return (shorth_range, mean(x[idxa:idxa+nobs-1]), 0.5*(a+b))
end

"""
Return the Shortest Half (shorth) Range, a robust estimator of dispersion (sorts, but 
    does not otherwise modif the inputs).
"""
function shorthrange!{T <: Real}(x::Vector{T}, normalize::Bool=false) 
    shorthrange_and_location!(x, normalize)[1]
end


"""
Return the Shortest Half (shorth) Range, a robust estimator of dispersion.

The Shortest Half of a data set {x} means the smallest closed interval [a,b] where 
(1) a and b are both elements of the data set and (2) at least half of the elements are
in the closed interval.  The shorth range is (b-a).

x            - The data set under study.  Must be a sequence of values.
normalize    - If False (default), then return the actual range b-a.  If True, then the range will be
               divided by 1.348960, which normalizes the range to be a consistent estimator of the
               parameter sigma in the case of an exact Gaussian distribution.  (A small correction of 
               order 1/N is applied, too, which mostly corrects for bias at modest values of the sample
               size N.)
Returns:       shorth range
"""

# The shortest-half range, a robust estimator of dispersion.
shorthrange{T <: Real}(x::Vector{T}, normalize::Bool=false) =
    shorthrange!(copy(x), normalize)

