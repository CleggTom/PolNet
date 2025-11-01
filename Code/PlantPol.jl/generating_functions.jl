#Poisson degree generating functions
G(x,z) = exp(z*(x-1))
L(x,l) = x*exp(l*(x-1))

#Function to solve for feasible states
function a_sol(a, zp, za, la)
    p = 1 - G(1 - a,zp)
    return L(1 - G( 1 - p, za),la) - a
end

#Function to solve for feasible states
function p_sol(p, zp, za, la)
    a = L(1 - G( 1 - p, za),la)
    return 1 - G(1 - a, zp) - p
end

#non-temporal model
function a_sol_static(a,zp,za,la)
    p = 1 - G(1 - a,zp)
    return 1-L(G( 1 - p, za),la) - a
end