module BoundaryConditions
import ..TemporalFunctions: TemporalFunction, ConstantFunction

abstract type BoundaryCondition end
struct NeumannBoundaryCondition  <: BoundaryCondition end

struct PeriodicBoundaryCondition{AXIS} <: BoundaryCondition 
  PeriodicBoundaryCondition(AXIS::Symbol) = PeriodicBoundaryCondition{AXIS}()
end


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
struct ReflectingBoundary <: ParticleBoundary
  particles :: Vector{Particles}
  ReflectingBoundary(particles...) = new([particles...]) 
end

struct PeriodicBoundary <: ParticleBoundary
  particles :: Vector{Particles}
  PeriodicBoundary(particles...) = new([particles...]) 
end

struct AbsorbingBoundary <: ParticleBoundary
  particles :: Vector{Particles}
  AbsorbingBoundary(particles...) = new([particles...]) 
end
end
