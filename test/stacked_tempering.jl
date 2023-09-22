using Test: @testset, @test, @inferred
using Statistics: mean
using RestrictedBoltzmannMachines: RBM, BinaryRBM, sample_v_from_v, sample_h_from_v
using StackedTempering: sample_bottom_to_top, sample_top_to_bottom, stacked_tempering

rbms = (
    BinaryRBM(randn(7), randn(5), randn(7,5)),
    BinaryRBM(randn(5), randn(3), randn(5,3)),
    BinaryRBM(randn(3), randn(2), randn(3,2))
)

hs = @inferred sample_bottom_to_top(rbms, falses(7, 10))
vs = @inferred sample_top_to_bottom(rbms, falses(2, 10))
@test length(vs) == length(hs) == length(rbms)

@inferred stacked_tempering(rbms, vs, hs)
@test stacked_tempering((), (), (); nsteps=5) == ((), ())

vs = (falses(7, 1000), falses(5, 1000), falses(3, 1000))
vs = sample_v_from_v.(rbms, vs; steps=100)
hs = sample_h_from_v.(rbms, vs)

μs_v = vec.(mean.(vs; dims=2))
μs_h = vec.(mean.(hs; dims=2))

vs_dt, hs_dt = @inferred stacked_tempering(rbms, vs, hs; nsteps=100)

μs_v_dt = mean.(vs_dt; dims=2)
μs_h_dt = mean.(hs_dt; dims=2)

for (μ_dt, μ) in zip(μs_v_dt, μs_v)
    @test μ_dt ≈ μ rtol=0.1
end

for (μ_dt, μ) in zip(μs_h_dt, μs_h)
    @test μ_dt ≈ μ rtol=0.1
end
