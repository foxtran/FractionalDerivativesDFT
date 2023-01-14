#!/usr/bin/python3

import sympy
from sympy import *
I, r, n, t = symbols('I r n t')

half = Rational(1,2)
quarter = Rational(1,4)

psi = r**n*exp(-I*r*r)
psi = psi.subs({n:0}) #otherwise, nan is
rho = psi**2


D0p = integrate(simplify(diff(psi.subs({r:r*t}),r)),(t, 0, 1))
D0p = D0p.args[1][0]

xi = half*D0p**2

print(xi)
print(xi.subs({I*r*r:-t/2}))

I_GTO = -xi*ln(rho) / (sqrt(rho)-sqrt(2*pi)/(2*sqrt(-ln(rho)))*erf(sqrt(-ln(rho)/2)) )**2

print(I_GTO.subs({n:0,r:1,I:0.5}).evalf())
print(I_GTO.subs({n:0,r:2,I:0.5}).evalf())
print(I_GTO.subs({n:0,r:4,I:0.5}).evalf())

I_GTO = half*xi*ln(rho)**2 / lowergamma(1+half,-ln(rho)/2)**2

print(I_GTO.subs({n:0,r:1,I:0.5}).evalf())
print(I_GTO.subs({n:0,r:2,I:0.5}).evalf())
print(I_GTO.subs({n:0,r:4,I:0.5}).evalf())
