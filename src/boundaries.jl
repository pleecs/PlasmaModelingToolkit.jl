module BoundaryConditions
import ..TemporalFunctions: TemporalFunction

abstract type BoundaryCondition end
struct PeriodicBoundaryCondition <: BoundaryCondition end
struct PerfectElectricConductor  <: BoundaryCondition end
struct PerfectMagneticConductor  <: BoundaryCondition end
mutable struct SurfaceImpedance  <: BoundaryCondition
    η :: Union{Float64, TemporalFunction}
    ε :: Float64
end
end

module ParticleBoundaryConditions
abstract type ParticleBoundaryCondition end
end