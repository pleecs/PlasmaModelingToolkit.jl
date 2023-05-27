module Distributions
abstract type PositionDistribution end
abstract type VelocityDistribution end

struct UniformDistribution <: PositionDistribution end
struct MaxwellBoltzmannDistribution{T, M} <: VelocityDistribution end

end