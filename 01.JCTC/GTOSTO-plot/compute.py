#!/usr/bin/env python

import math
import numpy as np
import scipy as sc
import scipy.special as scsp


class Quadrature(object):
    def _tanhsinh(n, h):
        x = np.zeros(2*n)
        w = np.zeros(2*n)
        for i in range(-n, n):
            x[n+i] = np.tanh(0.5*sc.pi*np.sinh(i*h))
            w[n+i] = h*sc.pi*np.cosh(i*h)/(np.cosh(0.5*sc.pi*np.sinh(i*h)))**2
            w[n+i] = w[n+i]*0.5
        return (x+1)/2, w

    def __init__(self):
        self.n = 0
        self.h = 0
        self.quadrature = Quadrature._tanhsinh

    def __call__(self, n, h):
        if self.n != n or self.h != h:
            self.n = n
            self.h = h
            self.x, self.w = self.quadrature(n, h)
        return self.x, self.w


quadrature = Quadrature()


def STO(x, y, z, dzeta):
    r = np.sqrt(x*x+y*y+z*z)
    return np.exp(-dzeta*r)


def STO_der(x, y, z, dzeta, var):
    r = np.sqrt(x*x+y*y+z*z)
    v = -dzeta * STO(x, y, z, dzeta) / r
    if var == "x":
        v *= x
    elif var == "y":
        v *= y
    elif var == "z":
        v *= z
    return v


def GTO(x, y, z, dzeta):
    r2 = (x*x+y*y+z*z)
    return np.exp(-dzeta*r2)


def GTO_der(x, y, z, dzeta, var):
    r2 = (x*x+y*y+z*z)
    v = -2 * dzeta * GTO(x, y, z, dzeta)
    if var == "x":
        v *= x
    elif var == "y":
        v *= y
    elif var == "z":
        v *= z
    return v


BASISFUNC = {"GTO": [GTO, GTO_der], "STO": [STO, STO_der]}


def frac_deriv(alpha, p, x, y, z, dzeta, f, v=None):
    global quadrature
    t, w = quadrature(100, 0.02)

    def frac_deriv_internal(alpha, p, t, x, y, z, dzeta, f, v=None):
        if v == None:
            fval = f(t*x, t*y, t*z, dzeta)
        else:
            fval = f(t*x, t*y, t*z, dzeta, v)
        # rescale
        scal = (1-t)**(p-alpha-1)
        return fval*scal
    res = frac_deriv_internal(alpha, p, t, x, y, z, dzeta, f, v)
    return sum(res*w)


def xi_alpha(alpha, p, x, y, z, dzeta, BF):
    global BASISFUNC
    f = BASISFUNC[BF][p]
    if p == 0:
        v = frac_deriv(alpha, p, x, y, z, dzeta, f)
        v = v*v
    elif p == 1:
        dx = frac_deriv(alpha, p, x, y, z, dzeta, f, "x")
        dy = frac_deriv(alpha, p, x, y, z, dzeta, f, "y")
        dz = frac_deriv(alpha, p, x, y, z, dzeta, f, "z")
        v = dx*dx + dy*dy + dz*dz
    v = 1/2 * v  # / scsp.gamma(p-alpha) # not necessary for ratio
    return v


if __name__ == '__main__':
    out = []
    # to check radial symmetry
    deg = 30
    xscal = math.sin(math.radians(deg))
    yscal = math.cos(math.radians(deg))
    out.append("p;Alpha;r;STO;GTO")
    for alpha, p in [(-2, 0), (-1, 0), (-0.5, 0), (0, 0), (0, 1), (0.5, 1), (1, 1)]:
        for r in np.arange(0, 10, 0.01):
            STOval = xi_alpha(alpha, p, r*xscal, r*yscal, 0, 1, "STO")
            GTOval = xi_alpha(alpha, p, r*xscal, r*yscal, 0, 1, "GTO")
            out.append(f"{p};{alpha};{r};{STOval};{GTOval}")
        for r in np.arange(10, 100+1e-10, 1):
            STOval = xi_alpha(alpha, p, r*xscal, r*yscal, 0, 1, "STO")
            GTOval = xi_alpha(alpha, p, r*xscal, r*yscal, 0, 1, "GTO")
            out.append(f"{p};{alpha};{r};{STOval};{GTOval}")
    open("STO-GTO.csv", "w").write("\n".join(out))
