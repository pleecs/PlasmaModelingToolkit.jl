module Distributions
abstract type AbstractPositionDistribution end
abstract type AbstractVelocityDistribution end

struct UniformDistribution <: AbstractPositionDistribution end
struct GaussianSeedDistribution <: AbstractPositionDistribution end
struct MaxwellBoltzmannDistribution{T, M} <: AbstractVelocityDistribution end

struct FunctionDistribution
  f :: Function
end

const PositionDistribution = Union{AbstractPositionDistribution, FunctionDistribution}
const VelocityDistribution = Union{AbstractVelocityDistribution, FunctionDistribution}

end
