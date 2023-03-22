module BoundaryConditions
export BoundaryCondition
abstract type BoundaryCondition end
struct PeriodicBoundaryCondition <: BoundaryCondition end
struct PerfectElectricConductor  <: BoundaryCondition end
struct PerfectMagneticConductor  <: BoundaryCondition end
mutable struct SurfaceImpedance  <: BoundaryCondition
    η :: Float64
    ε :: Float64
end

end

module ParticleBoundaryConditions
export ParticleBoundaryCondition
abstract type ParticleBoundaryCondition end
end