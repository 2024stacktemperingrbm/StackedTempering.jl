module StackedTempering

using Base: tail, front
using RestrictedBoltzmannMachines: sample_v_from_h, sample_h_from_v, free_energy_h, free_energy_v
using Tail2Front2: tail2
using MetropolisRules: metropolis_rule
using ConditionalSwaps: swap

include("stacked_tempering.jl")
include("swap.jl")

end
