# Deep tempering, in the form of Algorithm 2 of Desjardins et al 2014 Deep Tempering paper.
# Other implementations in StackedRBMs.jl, but this one here is the one I'm using for the
# NIPS paper.

function stacked_tempering(rbms::NTuple{L,Any}, v0::AbstractArray; nsteps::Int = 1) where {L}
    vs, hs = sample_stack(rbms, v0)
    return stacked_tempering(rbms, vs, hs; nsteps)
end

function sample_stack(rbms::Tuple, v0::AbstractArray)
    h0 = sample_bottom_to_top(rbms, v0)
    vs = sample_v_from_h.(rbms, h0)
    hs = sample_h_from_v.(rbms, vs)
    return vs, hs
end

function stacked_tempering(rbms::NTuple{L,Any}, vs::NTuple{L,AbstractArray}, hs::NTuple{L,AbstractArray}; nsteps::Int = 1) where {L}
    for t in 1:nsteps
        if iseven(t)
            # attempt even swaps
            vs, hs = oftype((vs, hs), stacked_tempering_swaps_even(rbms, vs, hs))
        else
            # attempt odd swaps
            vs, hs = oftype((vs, hs), stacked_tempering_swaps_odd(rbms, vs, hs))
        end

        # resample RBMs internally
        hs = sample_h_from_v.(rbms, vs)
        vs = sample_v_from_h.(rbms, hs)
    end

    return vs, hs
end

function stacked_tempering_swaps_odd(rbms::NTuple{L,Any}, vs::NTuple{L,AbstractArray}, hs::NTuple{L,AbstractArray}) where {L}
    h1_new, v2_new = metropolis_swap(rbms[1], hs[1], rbms[2], vs[2])
    v1_new = sample_v_from_h(rbms[1], h1_new)
    h2_new = sample_h_from_v(rbms[2], v2_new)
    vs_tail, hs_tail = stacked_tempering_swaps_odd(tail2(rbms), tail2(vs), tail2(hs))
    vs_new = (v1_new, v2_new, vs_tail...)
    hs_new = (h1_new, h2_new, hs_tail...)
    return vs_new, hs_new
end

function stacked_tempering_swaps_even(rbms::NTuple{L,Any}, vs::NTuple{L,AbstractArray}, hs::NTuple{L,AbstractArray}) where {L}
    vs_tail, hs_tail = stacked_tempering_swaps_odd(tail(rbms), tail(vs), tail(hs))
    vs_new = (vs[1], vs_tail...)
    hs_new = (hs[1], hs_tail...)
    return vs_new, hs_new
end

stacked_tempering_swaps_odd(::Tuple{}, ::Tuple{}, ::Tuple{}) = ((), ())
stacked_tempering_swaps_even(::Tuple{}, ::Tuple{}, ::Tuple{}) = ((), ())

function stacked_tempering_swaps_odd(rbms::Tuple{Any}, vs::Tuple{AbstractArray}, hs::Tuple{AbstractArray})
    rbm, v, h = only(rbms), only(vs), only(hs)
    v_new = sample_v_from_h(rbm, h)
    @assert size(v) == size(v_new)
    return (v_new,), (h,)
end

function sample_bottom_to_top(rbms::NTuple{L,Any}, v_bottom::AbstractArray) where {L}
    h_top = sample_h_from_v(first(rbms), v_bottom)
    hs = sample_bottom_to_top(tail(rbms), h_top)
    return (h_top, hs...)
end

function sample_top_to_bottom(rbms::NTuple{L,Any}, h_top::AbstractArray) where {L}
    v_bottom = sample_v_from_h(last(rbms), h_top)
    vs = sample_top_to_bottom(front(rbms), v_bottom)
    return (vs..., v_bottom)
end

sample_top_to_bottom(::Tuple{}, ::AbstractArray) = ()
sample_bottom_to_top(::Tuple{}, ::AbstractArray) = ()
