module Distributions
abstract type Distribution end

struct UniformDistribution <: Distribution end
struct MaxwellBoltzmannDistribution{T, M} <: Distribution end
end