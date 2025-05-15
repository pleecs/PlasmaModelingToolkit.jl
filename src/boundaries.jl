module BoundaryConditions
import ..TemporalFunctions: TemporalFunction, ConstantFunction

abstract type BoundaryCondition end
struct NeumannBoundaryCondition  <: BoundaryCondition end
struct PeriodicBoundaryCondition{AXIS} <: BoundaryCondition end
struct DirichletBoundaryCondition <: BoundaryCondition
  α :: TemporalFunction
end

DirichletBoundaryCondition(α::Real) = DirichletBoundaryCondition(ConstantFunction{float(α)}())

struct PerfectElectricConductor  <: BoundaryCondition end
struct PerfectMagneticConductor  <: BoundaryCondition end
struct AbsorbingBoundaryCondition <: BoundaryCondition end
struct SurfaceImpedance  <: BoundaryCondition
  η :: TemporalFunction
end

SurfaceImpedance(η::Float64) = SurfaceImpedance(ConstantFunction{η}()) 

end

module ParticleBoundaries
import ..Species: Particles
abstract type ParticleBoundary end
struct ReflectingBoundary{AXIS} <: ParticleBoundary
  particles :: Vector{Particles}
end
ReflectingBoundary{AXIS}(particles...) where {AXIS} = ReflectingBoundary{AXIS}([particles...])

struct PeriodicBoundary{AXIS} <: ParticleBoundary
  particles :: Vector{Particles}
end
PeriodicBoundary{AXIS}(particles...) where {AXIS} = PeriodicBoundary{AXIS}([particles...])

struct AbsorbingBoundary{AXIS} <: ParticleBoundary
  particles :: Vector{Particles}
end
AbsorbingBoundary{AXIS}(particles...) where {AXIS} = AbsorbingBoundary{AXIS}([particles...])
end
