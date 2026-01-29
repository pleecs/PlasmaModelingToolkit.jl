module Distributions
abstract type PositionDistribution end
abstract type VelocityDistribution end

struct UniformDistribution <: PositionDistribution end
struct GaussianSeedDistribution <: PositionDistribution end
struct MaxwellBoltzmannDistribution{T, M} <: VelocityDistribution end

abstract type SamplingMode end
struct RejectionSampling <: SamplingMode end
struct QuietStartSampling <: SamplingMode end

struct FunctionDistribution <: PositionDistribution
  f :: Function
  sampling :: SamplingMode
end

FunctionDistribution(f; sampling=RejectionSampling()) = FunctionDistribution(f, sampling)

end
