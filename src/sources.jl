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
	rate :: TemporalFunction
	x :: Distribution
	v :: Distribution
end

struct SpeciesLoader{V}
	species :: AbstractSpecies
	η :: Float64
	x :: Distribution
	v :: Distribution
	drift :: NTuple{V, Float64}
end

SpeciesLoader(species::AbstractSpecies, η::Float64, x::Distribution, v::Distribution) = SpeciesLoader{3}(species, η, x, v, (0.0, 0.0, 0.0)) # FIXME: how to resolve problem of a drift length?
SpeciesLoader(species, η, x, v; drift::NTuple{V, Float64}) where {V} = SpeciesLoader{V}(species, η, x, v, drift)

end