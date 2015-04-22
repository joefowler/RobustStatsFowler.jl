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

