"""
    metropolis_swap(rbm1, h1, rbm2, v2)

Swaps hidden configuration `h1` of `rbm1` with the visible configuration `v2` of `rbm2`,
with the Metropolis-Hastings acceptance probability.
"""
function metropolis_swap(rbm1, h1::AbstractArray, rbm2, v2::AbstractArray)
    A = metropolis_swap_acceptance_flags_reshaped(rbm1, h1, rbm2, v2)
    h1_new, v2_new = swap(A, h1, v2)
    return h1_new, v2_new
end

function metropolis_swap_acceptance_flags_reshaped(rbm1, h1::AbstractArray, rbm2, v2::AbstractArray)
    A = metropolis_swap_acceptance_flags(rbm1, h1, rbm2, v2)
    return reshape(A, map(one, size(rbm1.hidden))..., size(A)...)
end

function metropolis_swap_acceptance_flags(rbm1, h1::AbstractArray, rbm2, v2::AbstractArray)
    ΔE = swap_energy(rbm1, h1, rbm2, v2)
    return metropolis_rule.(ΔE)
end

"""
    swap_energy(rbm1, h1, rbm2, v2)

Energetic cost of swapping `h1` with `v2`.
"""
function swap_energy(rbm1, h1::AbstractArray, rbm2, v2::AbstractArray)
    Δ1 = free_energy_h(rbm1, v2) - free_energy_h(rbm1, h1)
    Δ2 = free_energy_v(rbm2, h1) - free_energy_v(rbm2, v2)
    return Δ1 + Δ2
end
