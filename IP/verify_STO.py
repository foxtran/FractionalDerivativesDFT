#!/usr/bin/python3

from sympy import *
I, r, n, t = symbols('I r n t')

half = Rational(1,2)
quarter = Rational(1,4)

psi = r**n*exp(-I*r)
rho = psi**2

D0p = integrate(simplify(diff(psi.subs({r:r*t}),r)),(t, 0, 1))
D0p = D0p.args[0][0]

print(D0p)

xi = half*D0p**2

I_STO = half*ln(rho)**2*sqrt(2*xi) / (2-(2-ln(rho))*sqrt(rho))

print(I_STO.subs({n:0,r:1,I:0.5}))
print(I_STO.subs({n:0,r:2,I:0.5}))
print(I_STO.subs({n:0,r:4,I:0.5}))

I_STO = quarter*ln(rho)**2*sqrt(2*xi) / lowergamma(2, -ln(rho)/2)

print(I_STO.subs({n:0,r:1,I:0.5}))
print(I_STO.subs({n:0,r:2,I:0.5}))
print(I_STO.subs({n:0,r:4,I:0.5}))