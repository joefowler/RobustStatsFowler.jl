using RobustStats
using Base.Test

# Basic tests of the weighted means
a=[-2:2]
@test_approx_eq_eps bisquareWM(a,3,.1,1e-5) 0.0 1e-4
@test_approx_eq_eps huberWM(a,3,.1,1e-5) 0.0 1e-4
push!(a, 97)
@test_approx_eq_eps bisquareWM(a,3,.1,1e-5) 0.0 1e-4
push!(a, 98)
@test_approx_eq_eps bisquareWM(a,3,.1,1e-5) 0.0 1e-4
push!(a, 99)
@test_approx_eq_eps bisquareWM(a,3,.1,1e-5) 0.0 1e-4
push!(a, 98)
@test_approx_eq_eps bisquareWM(a,3,.1,1e-5) 0.0 1e-4
append!(a, [98,98,98])
@test_approx_eq_eps bisquareWM(a,3,97,1e-4) 98.0 1e-3

@test_throws ErrorException bisquareWM([0:9], 0.1)

# Test 10 sets of 100 N(0,1) random numbers
# Add up to 8 values of much larger tailiness
# Expected mean is within [-.2, +.2] (2-sigma), so test for
# being in the [-1, +1] range, even with added large values.
for i=1:10
    r=randn(100)
    for j=1:5
        b=bisquareWM(r, 4, 0, 0.01)
        h=huberWM(r, 1.3, 0, 0.01)
        @test_approx_eq_eps b 0 1
        @test_approx_eq_eps h 0 1
        @test_approx_eq_eps b h 1.5
        append!(r, randn(2)*100)
    end
end


# Trimean: exact quartiles
a=[0:12]
@test_approx_eq trimean(a) 6.0
@test_approx_eq trimean(a.^2) (3^2+9^2)/4.+6^2/2.

# Trimean: exact median, inexact 1st and 3rd quartiles
a=[0:10]
@test_approx_eq trimean(a) 5.0
@test_approx_eq trimean(a.^2) (6.5+56.5)/4. + 25.0/2

# Trimean: inexact quartiles
a=[0:9]
@test_approx_eq trimean(a) 4.5
@test_approx_eq trimean(a.^2) (4*.75+9*.25 + 36*.25+49*.75)/4. + (16*.5+25*.5)/2

# Shortest half-range
a=[10,3,5,6,6.5,7,8,0,13]  # Odd # of values. 9 values, with "half" containing 5
@test_approx_eq shorthrange(a) 3
@test_approx_eq a[1] 10 # Be sure it didn't rearrange a
@test_approx_eq shorthrange!(a) 3
@test_approx_eq a[1] 0  # Should have sorted a
a=[0,4.5,6,7,8,10,14,99]  # Even # of values. 8 values, with each "half" containing 5
@test_approx_eq shorthrange(a) 10-4.5

# Weighted high median
whm = RobustStats._weightedhighmedian
whm! = RobustStats._weightedhighmedian!

# Check that whm and whm! give correct and equal answers.
function _verify_whm{T<:Real,U<:Integer}(a::Vector{T}, wts::Vector{U})
	answer = whm(a,wts)
	wlow = whigh = wexact =  0
	for i=1:length(a)
		if a[i] < answer
			wlow += wts[i]
		elseif a[i] > answer
			whigh += wts[i]
		else
			wexact += wts[i]
		end
	end
	wtotal = wlow + wexact + whigh
	@test 2*wlow <= wtotal && 2*whigh < wtotal

	answermangled = whm!(a,wts)
	@test answer == answermangled
end


_verify_whm([1:5], [1,1,1,1,1])
_verify_whm([1:5], [1,2,3,4,5])
_verify_whm([1:5], [1,2,3,4,9])
_verify_whm([1:5], [1,2,3,4,10])
_verify_whm([1:5], [2,1,1,1,1])
_verify_whm([1:5], [1,1,1,2,1])

_verify_whm([5:-1:1], [1,1,1,1,1])
_verify_whm([5:-1:1], [1,2,3,4,5])
_verify_whm([5:-1:1], [1,2,3,4,9])
_verify_whm([5:-1:1], [1,2,3,4,10])
_verify_whm([5:-1:1], [1,2,3,4,11])
_verify_whm([5:-1:1], [2,1,1,1,1])
_verify_whm([5:-1:1], [1,1,1,2,1])
_verify_whm([1,4,2,5,3,6], [1,4,2,5,3,6])
_verify_whm([1,4,2,5,3,6], [1,4,2,5,3,5])
_verify_whm([1,4,2,5,3,6], [1,4,2,5,3,4])

datalengths = [10,11,1000,1111]
wttypes = [Int8,Int16,Int32,Int64,Uint8,Uint16,Uint32,Uint64]
for i=1:length(datalengths)
	for j=1:length(wttypes)
		N = datalengths[i]
		a = randn(N)
		w = Array(wttypes[j], N)
		rand!(w)
		# Careful! Can't have sum of weights overflow, and can't have negative weights
		for k=1:N
			if w[k]<0
				w[k] = 1
			end
			w[k] %= 8192
		end
		result = whm(a,w)
		_verify_whm(a, w)
		println("Success on size $(N) and type $(eltype(w))")
	end
end
@test_throws ArgumentError whm([1:5],[1:4])


@show RobustStats._slow_scaleQ([1,2,3,4,5])
