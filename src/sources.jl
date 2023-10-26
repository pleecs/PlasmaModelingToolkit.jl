module Sources
import ..BoundaryConditions: BoundaryCondition
import ..Materials: Medium
import ..TemporalFunctions: TemporalFunction
import ..Distributions: PositionDistribution, VelocityDistribution, MaxwellBoltzmannDistribution
import ..Species: Particles, Fluid

abstract type WaveguideMode end
struct TM01 <: WaveguideMode end
struct TEM <: WaveguideMode end

struct CoaxialPort <: BoundaryCondition
  signal :: TemporalFunction
  ε :: Float64
end

struct WaveguidePort <: BoundaryCondition
  signal :: TemporalFunction
  mode :: WaveguideMode
  ε :: Float64
end

struct UniformPort <: BoundaryCondition
  signal :: TemporalFunction
  ε :: Float64
end

abstract type SpeciesSource end
abstract type SpeciesLoader end

struct ParticleSource <: SpeciesSource
  species :: Particles
  rate :: TemporalFunction
  x :: PositionDistribution
  v :: VelocityDistribution
  drift :: Vector{Pair{Symbol, Float64}}
end

struct ParticleLoader{T} <: SpeciesLoader
  species :: Particles
  value :: T
  x :: PositionDistribution
  v :: VelocityDistribution
  drift :: Vector{Pair{Symbol, Float64}}
end

struct FluidLoader <: SpeciesLoader
  species :: Fluid
  density :: Float64
  temperature :: Float64
end

ParticleSource(species::Particles, rate::TemporalFunction, x::PositionDistribution; drift=Vector{Pair{Symbol, Float64}}([])) = ParticleSource(species, rate, x, MaxwellBoltzmannDistribution{0.0, species.mass}(), drift)
ParticleSource(species::Particles, rate::TemporalFunction, x::PositionDistribution, v::VelocityDistribution; drift=Vector{Pair{Symbol, Float64}}([])) = ParticleSource(species, rate, x, v, drift)

ParticleLoader(species::Particles, value::Real, x::PositionDistribution; drift=Vector{Pair{Symbol, Float64}}([])) = ParticleLoader(species, value, x, MaxwellBoltzmannDistribution{0.0, 0.0}(), drift)
ParticleLoader(species::Particles, value::Real, x::PositionDistribution, v::VelocityDistribution; drift=Vector{Pair{Symbol, Float64}}([])) = ParticleLoader(species, value, x, v, drift)
end