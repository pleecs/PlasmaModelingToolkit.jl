module Sources
import ..BoundaryConditions: BoundaryCondition
import ..Materials: Medium
import ..TemporalFunctions: TemporalFunction

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

struct ParticleSource 
	rate :: TemporalFunction
	x :: Distribution
	v :: Distribution
end

struct ParticleLoader
	init :: Int64
	x :: Distribution
	v :: Distribution
end
end