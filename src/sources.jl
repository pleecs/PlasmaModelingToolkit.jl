module Sources
import ..BoundaryConditions: BoundaryCondition
import ..Materials: Medium
import ..TemporalFunctions: TemporalFunction
import ..Distributions: Distribution
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
	x :: Distribution
	v :: Distribution
end

struct SpeciesLoader
	species :: AbstractSpecies
	density :: Float64
	x :: Distribution
	v :: Distribution
	drift :: Vector{Pair{Symbol, Float64}}
end

SpeciesLoader(species::AbstractSpecies, density::Float64, x::Distribution, v::Distribution) = SpeciesLoader(species, density, x, v, [])
SpeciesLoader(species, density, x, v; drift)= SpeciesLoader(species, density, x, v, drift)

end