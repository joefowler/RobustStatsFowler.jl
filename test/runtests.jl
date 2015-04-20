using RobustStats
using Base.Test

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



