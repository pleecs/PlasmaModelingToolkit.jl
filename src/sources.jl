module Sources
import ..BoundaryConditions: BoundaryCondition
import ..Materials: Medium
import ..TemporalFunctions: TemporalFunction
import ..Distributions: PositionDistribution, VelocityDistribution
import ..Species: AbstractSpecies

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

struct SpeciesSource
  species :: AbstractSpecies
  rate :: TemporalFunction
  x :: PositionDistribution
  v :: VelocityDistribution
  drift :: Vector{Pair{Symbol, Float64}}
end

struct SpeciesLoader
  species :: AbstractSpecies
  density :: Float64
  x :: PositionDistribution
  v :: VelocityDistribution
  drift :: Vector{Pair{Symbol, Float64}}
end

SpeciesSource(species::AbstractSpecies, rate, x::PositionDistribution, v::VelocityDistribution) = SpeciesSource(species, rate, x, v, [])
SpeciesSource(species, rate, x, v; drift)= SpeciesSource(species, rate, x, v, drift)
SpeciesLoader(species::AbstractSpecies, density::Float64, x::PositionDistribution, v::VelocityDistribution) = SpeciesLoader(species, density, x, v, [])
SpeciesLoader(species, density, x, v; drift)= SpeciesLoader(species, density, x, v, drift)

end