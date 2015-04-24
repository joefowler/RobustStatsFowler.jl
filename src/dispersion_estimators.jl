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
        # The asymptotic expectation for normal data is sigma*2*0.674480
        # where Phi(0.674480...) = 3/4 and Phi is the cumulative distribution of the standard normal.
        shorth_range /= (2*.674480)
        
        # The small-n corrections depend on n mod 4.  See Rousseeuw & Leroy, Statistica
        # Neerlandica 42 (1988) page 115 for the source of these values.
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



"""
Compute the weighted high median in O(n) time.

Note that both input arrays will be changed (not merely re-ordered) by this function.
"""
function _weightedhighmedian!{T <: Real, U <: Integer}(a::Vector{T}, wts::Vector{U})
    N = length(a)
    if N != length(wts)
        throw(ArgumentError("_weightedhighmedian!(a,w) requires length(a)==length(w)"))
    end


    wtotal::Int64 = wdiscardedlow::Int64 = 0
    for i=1:N
        wtotal += wts[i]
    end

    nn = N
    while true
        @assert nn>0 && length(a)==nn
        trial = select(a, div(nn,2)+1)

        # Count up the weight to the left of and at the trial point.
        # Weight to the right of it isn't needed
        wleft = wtrial = 0
        for i=1:nn
            if a[i] < trial
                wleft += wts[i]
            elseif a[i] == trial
                wtrial += wts[i]
            end
        end

        if 2*(wdiscardedlow + wleft) > wtotal
            # Trial value is too high
            ncandidates = 0
            for i=1:nn
                if a[i] < trial
                    ncandidates += 1
                    a[ncandidates] = a[i]
                    wts[ncandidates] = wts[i]
                end
            end
            nn = ncandidates

        elseif 2*(wdiscardedlow + wleft + wtrial) > wtotal
            # Trial value is just right
            return trial

        else
            # Trial value is too low
            ncandidates = 0
            for i=1:nn
                if a[i] > trial
                    ncandidates += 1
                    a[ncandidates] = a[i]
                    wts[ncandidates] = wts[i]
                end
            end
            nn = ncandidates
            wdiscardedlow += wleft+wtrial
        end
        a=a[1:nn]
        wts=wts[1:nn]
    end
end


"""
Compute the weighted high median in O(n) time.

WHM is defined as the smallest a[j] such that the sum of the weights for all a[i]<=a[j]
is strictly greater than half of the total weight.

a    - Array containing the observations (unsorted)
wts  - Weights.

Input arrays will not be changed by this function.
"""
_weightedhighmedian{T <: Real, U <: Integer}(a::Vector{T}, wts::Vector{U}) =
    _weightedhighmedian!(copy(a), copy(wts))

