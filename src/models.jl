module Models
import ..BoundaryConditions: BoundaryCondition, NeumannBoundaryCondition, DirichletBoundaryCondition, PeriodicBoundaryCondition
import ..InterfaceConditions: InterfaceCondition
import ..Grid: AbstractGrid, AxisymmetricGrid
import ..Domains: AxisymmetricDomain
import ..Geometry: Shape, Segment, Rectangle
import ..Materials: Material, Conductor, Dielectric, PerfectlyMatchedLayer
import ..Distributions: Distribution
import ..Problems: BoundaryValueProblem, ParticleProblem, ParticleCollisionProblem
import ..InterfaceConditions: detect_interface_z!, detect_interface_r!
import ..Grid: discretize, discretize!, snap
import ..Species: Particles, Fluid
import ..ParticleBoundaries: ParticleBoundary
import ..Sources: SpeciesSource, SpeciesLoader
import Base: setindex!

abstract type DiscretizedModel end

include("models/fdtd.jl")
include("models/fdm.jl")
include("models/pic.jl")
include("models/fem.jl")
end