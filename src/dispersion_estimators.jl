function shorthrange_and_location!{T <: Real}(x::Vector{T}, normalize::Bool=false)
    sort!(x)

    N = length(x)         # Number of data values
    nhalves = div(N+1, 2) # Number of minimal intervals (containing at least half the data)
    nobs = 1 + div(N, 2)  # Number of values in each minimal interval

    range_each_half = x[end-nhalves:end]-x[1:nhalves+1]
    idxa = indmin(range_each_half)
    a, b = x[idxa], x[idxa+nobs-1]
    shorth_range = b-a

    if normalize
        # The asymptotic expectation for normal data is sigma*2*0.674480
        # where Phi(0.674480...) = 3/4 and Phi is the cumulative distribution of the standard normal.
        shorth_range /= (2*.674480)

        # The small-N corrections depend on N mod 4.  See Rousseeuw & Leroy, Statistica
        # Neerlandica 42 (1988) page 115 for the source of these values.
        if N%4==0
            shorth_range *= (N+1.0)/N
        elseif N%4==1
            shorth_range *= (N+1.0)/(N-1.0)
        elseif N%4==2
            shorth_range *= (N+1.0)/N
        else
            shorth_range *= (N+1.0)/(N-1.0)
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

"""Return the Shortest Half (shorth) Range, a robust estimator of dispersion (sorts, but
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



"""Compute the weighted high median in O(N) time.

Note that both input arrays will be changed (not merely re-ordered) by this function.
"""
function _weightedhighmedian!{T <: Real, U <: Integer}(a::Vector{T}, wts::Vector{U})
    N = length(a)
    if N != length(wts)
        throw(ArgumentError("_weightedhighmedian!(a,w) requires length(a)==length(w)"))
    end


    wtotal::Int64 = wdiscardedlow::Int64 = 0
    for i = 1:N
        wtotal += wts[i]
    end

    nn = N
    while true
        @assert nn>0 && length(a)==nn
        trial = select(a, div(nn,2)+1)

        # Count up the weight to the left of and at the trial point.
        # Weight to the right of it isn't needed
        wleft = wtrial = 0
        for i = 1:nn
            if a[i] < trial
                wleft += wts[i]
            elseif a[i] == trial
                wtrial += wts[i]
            end
        end

        if 2*(wdiscardedlow + wleft) > wtotal
            # Trial value is too high
            ncandidates = 0
            for i = 1:nn
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
            for i = 1:nn
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


"""Compute the weighted high median in O(N) time.

WHM is defined as the smallest a[j] such that the sum of the weights for all a[i]<=a[j]
is strictly greater than half of the total weight.

a    - Array containing the observations (unsorted)
wts  - Weights.

Input arrays will not be changed by this function.
"""
_weightedhighmedian{T <: Real, U <: Integer}(a::Vector{T}, wts::Vector{U}) =
    _weightedhighmedian!(copy(a), copy(wts))


"""Compute the scaleQ statistic using a simple, O(N^2) routine.

This is only for validating the faster scaleQ(), which runs in O(N log N).
"""
function _slow_scaleQ{T <: Real}(x::Vector{T})
    N = length(x)
    NMAX = 1000
    if N > NMAX
        throw(ArgumentError("_slow_scaleQ(x) requires length(x)<=$(NMAX), because it is slow"))
    end

    h = div(N,2)+1
    k = div(h*(h-1), 2)
    A = Array(T, N, N)
    for i=2:N
        for j=1:i-1
            A[i,j] = A[j,i] = abs(x[i]-x[j])
        end
    end
    for i = 1:N
        A[i,i] = 0
    end
    # The kth order statistic of all npairs distances is also
    # The (2k+N)th order statistic of all values in A.
    # The 2 is because symmetric A double-counts distances, and +N
    # because we've added in the N zeros along the diagonal.
    Q = select!(vec(A), k*2+N)

    nscale::Float64 = 0
    if N < 10
        nscale = [0,.399,.994,.512,.844,.611,.857,.669,.872][N]
    elseif N%2 == 1
        nscale = N/(N+1.4)
    else
        nscale = N/(N+3.8)
    end
    Q * 2.2219 * nscale
end

"""Compute the scale-Q statistic of Rousseeuw and Croux fast.

While the naive implementation (see _slow_scaleQ) runs in O(N^2) time
and space, this better one runs in O(N log N) and uses O(N) space.

This version calls sort!(y) on the input array but does not otherwise change it.
"""
function scaleQ!{T <: Real}(y::Vector{T})
    sort!(y)
    N = length(y)

    h = div(N, 2)+1
    k = div(h*(h-1), 2)
    left = collect(N+1:-1:2)
    right = fill(N, N)
    work = Array(T, N)
    weight = Array(Int64, N)
    P = Array(Int64, N)
    Q = Array(Int64, N)

    jhelp = div(N*(N+1), 2)
    knew = k+jhelp
    nL = jhelp
    nR = N*N
    found = false
    Qn = 0*y[1]
    while nR-nL > N && !found # 200
        j = 1
        for i = 2:N
            if left[i] <= right[i]
                weight[j] = right[i]-left[i]+1
                jhelp = left[i]+div(weight[j],2)
                work[j] = y[i]-y[N+1-jhelp]
                j += 1
            end
        end # 30

        trial = _weightedhighmedian(work[1:j-1], weight[1:j-1])
        j=0
        for i=N:-1:1
            while j<N && (y[i]-y[N-j] < trial) # 45
                j += 1
            end
            P[i] = j
        end # 40

        j = N+1
        for i = 1:N
            while y[i]-y[N-j+2] > trial # 55
                j -= 1
            end
            Q[i] = j
        end # 50

        sumP = sum(P)
        sumQ = sum(Q)-N # 60

        if knew <= sumP
            right[:] = P[:]
            nR = sumP
        elseif knew > sumQ
            left[:] = Q[:]
            nL = sumQ
        else
            Qn = trial
            found = true
        end
    end # goto 200

    if !found
        j=1
        for i=2:N
            if left[i] <= right[i]
                for jj = left[i]:right[i]
                    work[j] = y[i]-y[N-jj+1]
                    j += 1
                end # 100
            end
        end # 90
        Qn = select(work[1:j-1], knew-nL)
    end

    nscale::Float64 = 0
    if N<10
        nscale = [0,.399,.994,.512,.844,.611,.857,.669,.872][N]
    elseif N%2 == 1
        nscale = N/(N+1.4)
    else
        nscale = N/(N+3.8)
    end
    Qn * 2.2219 * nscale
end



"""
Compute the scale-Q statistic of Rousseeuw and Croux fast.

While the naive implementation (see _slow_scaleQ) runs in O(N^2) time
and space, this better one runs in O(N log N) and uses O(N) space.

This version does not alter the input array.
"""
scaleQ{T <: Real}(y::Vector{T}) = scaleQ!(copy(y))


"""
Compute the scaleS statistic using a simple, O(N^2) routine.

This is only for validating the faster scaleS(), which runs in O(N log N).
"""
function _slow_scaleS{T <: Real}(x::Vector{T})
    N = length(x)
    NMAX = 1000
    if N > NMAX
        throw(ArgumentError("_slow_scaleS(x) requires length(x)<=$(NMAX), because it is slow"))
    end

    lomed(x::Vector) = select!(x, div(length(x)+1, 2))
    himed(x::Vector) = select!(x, div(length(x), 2)+1)

    a2 = Array(T, N)
    for i = 1:N
        a2[i] = himed(abs(x-x[i]))
    end

    # Normalization
    if N < 10
        cn = [0,.743, 1.851, .954, 1.351, .993, 1.198, 1.005, 1.131][N]
    elseif N%2 == 1
        cn=N/(N-0.9)
    else
        cn=1.0
    end
    cn * 1.1926 * lomed(a2)
end


"""Compute the scale-S statistic of Rousseeuw and Croux fast.

An efficient algorithm for the scale estimator:

    Sn = cn * 1.1926 * LOMEDIAN_i HIGHMEDIAN_j | x_i - x_j |

While the naive implementation (see _slow_scaleQ) runs in O(N^2) time
and space, this better one runs in O(N log N) and uses O(N) space.

This version calls sort!(x) on the input array but does not otherwise change it.
"""
function scaleS!{T <: Real}(x::Vector{T})
    N = length(x)
    lomed(x::Vector) = select!(x, div(length(x)+1, 2))
    # himed(x::Vector) = select!(x, div(length(x), 2)+1)

    sort!(x)
    a2 = Array(T, N)
    a2[1] = x[div(N,2)+1]-x[1]
    for i = 2:div(N+1, 2)
        nA = i-1
        nB = N-i
        diff = nB-nA
        leftA = leftB = 1
        rightA = rightB = nB
        Amin = div(diff,2)+1
        Amax = div(diff,2)+nA
        while leftA < rightA # 15
            len = rightA-leftA+1
            even= 1-len%2
            half=div(len-1,2)
            tryA = leftA+half
            tryB = leftB+half
            if tryA < Amin
                rightB = tryB
                leftA = tryA + even
            elseif tryA > Amax
                rightA = tryA
                leftB = tryB+even
            else
                medA = x[i]-x[i-tryA+Amin-1]
                medB = x[tryB+i] - x[i]
                if medA >= medB
                    rightA = tryA
                    leftB = tryB+even
                else
                    rightB = tryB
                    leftA = tryA+even
                end
            end
        end
        if leftA > Amax
            a2[i] = x[leftB+i]-x[i]
        else
            medA = x[i]-x[i-leftA+Amin-1]
            medB = x[leftB+i]-x[i]
            a2[i] = min(medA,medB)
        end
    end # 10

    for i = div(N+1,2)+1 : N-1
        nA = N-i
        nB = i-1
        diff = nB-nA
        leftA = leftB = 1
        rightA = rightB = nB
        Amin = div(diff,2)+1
        Amax = div(diff,2)+nA
        while leftA < rightA
            len = rightA-leftA+1
            even = 1-len%2
            half = div(len-1,2)
            tryA = leftA+half
            tryB = leftB+half
            if tryA < Amin
                rightB = tryB
                leftA = tryA + even
            elseif tryA > Amax
                rightA = tryA
                leftB = tryB+even
            else
                medA = x[i+tryA-Amin+1]-x[i]
                medB = x[i]-x[i-tryB]
                if medA >= medB
                    rightA = tryA
                    leftB = tryB+even
                else
                    rightB = tryB
                    leftA = tryA+even
                end
            end
        end
        if leftA > Amax
            a2[i] = x[i]-x[i-leftB]
        else
            medA = x[i+leftA-Amin+1]-x[i]
            medB = x[i]-x[i-leftB]
            a2[i] = min(medA,medB)
        end
    end # 20

    a2[N] = x[N]-x[div(N+1,2)]

    # Normalization
    cn = 1.0
    if N<10
        cn = [0, .743, 1.851, .954, 1.351, .993, 1.198, 1.005, 1.131][N]
    elseif N%2 == 1
        cn = N/(N-0.9)
    end
    cn * 1.1926 * lomed(a2)
end


"""Compute the scale-S statistic of Rousseeuw and Croux fast.

While the naive implementation (see _slow_scaleS) runs in O(N^2) time
and space, this better one runs in O(N log N) and uses O(N) space.

This version does not alter the input array.
"""
scaleS{T <: Real}(x::Vector{T}) = scaleS!(copy(x))
