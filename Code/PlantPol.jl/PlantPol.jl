module PlantPol
    using CairoMakie
    using LinearAlgebra
    using Combinatorics
    using Graphs
    using Distributions
    using Roots
    using Random
    using StatsBase


    include("generating_functions.jl")
    include("simulations.jl")
    include("plotting.jl")
end