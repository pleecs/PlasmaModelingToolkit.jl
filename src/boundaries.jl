module BoundaryConditions
import ..TemporalFunctions: TemporalFunction, ConstantFunction

abstract type BoundaryCondition end
struct NeumannBoundaryCondition  <: BoundaryCondition end
struct PeriodicBoundaryCondition <: BoundaryCondition end
struct DirichletBoundaryCondition <: BoundaryCondition
    α :: TemporalFunction
end

DirichletBoundaryCondition(α::Float64) = DirichletBoundaryCondition(ConstantFunction(α))

struct PerfectElectricConductor  <: BoundaryCondition end
struct PerfectMagneticConductor  <: BoundaryCondition end
mutable struct SurfaceImpedance  <: BoundaryCondition
    η :: Union{Float64, TemporalFunction}
    ε :: Float64
end
end

module ParticleBoundaries
import ..Species: Particles
abstract type ParticleBoundary end
struct ReflectingBoundary{N} <: ParticleBoundary
    particles :: NTuple{N, Particles}
    ReflectingBoundary() = new{0}(()) 
end

struct PeriodicBoundary{N} <: ParticleBoundary
    particles :: NTuple{N, Particles}
    PeriodicBoundary() = new{0}(())
end

struct AbsorbingBoundary{N} <: ParticleBoundary
    particles :: NTuple{N, Particles}
    AbsorbingBoundary() = new{0}(())
end
end
