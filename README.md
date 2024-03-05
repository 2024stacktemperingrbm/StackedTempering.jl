# StackedTempering

Julia code accompanying the paper "Accelerated sampling with stacked restricted boltzmann machines" by Jorge Fernandez-de-Cossio-Diaz, Clément Roussel, Simona Cocco, and Rémi Monasson.

## Usage

The main function is `stacked_tempering`, which samples the stack of RBMs exchanging configurations between neighboring layers, while respecting the Metropolis rule.

Example:

```julia
using RestrictedBoltzmannMachines: BinaryRBM
using StackedTempering: sample_bottom_to_top
using StackedTempering: sample_top_to_bottom
using StackedTempering: stacked_tempering

# Create stack of RBMs
rbms = (
    BinaryRBM(randn(7), randn(5), randn(7,5)),
    BinaryRBM(randn(5), randn(3), randn(5,3)),
    BinaryRBM(randn(3), randn(2), randn(3,2))
)

# Sample the stack of RBMs, bottom to top
hs = sample_bottom_to_top(rbms, falses(7, 10))

# Sample the stack of RBMs, top to bottom
vs = sample_top_to_bottom(rbms, falses(2, 10))

# sample the stack of RBMs, respecting Metropolis transitions between the layers
stacked_tempering(rbms, vs, hs)
```

## Citation

If you use this code in a publication, please cite:

> Jorge Fernandez-de-Cossio-Diaz, Clément Roussel, Simona Cocco, and Remi Monasson.
> "Accelerated sampling with stacked restricted boltzmann machines."
> [The Twelfth International Conference on Learning Representations (2024)](https://openreview.net/forum?id=kXNJ48Hvw1).

Or you can use the included [CITATION.bib](https://github.com/2024stacktemperingrbm/StackedTempering.jl/blob/master/CITATION.bib).