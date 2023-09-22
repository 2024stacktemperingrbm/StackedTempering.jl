import Aqua
import StackedTempering
using Test: @testset

@testset verbose = true "aqua" begin
    Aqua.test_all(StackedTempering; ambiguities = false)
end
