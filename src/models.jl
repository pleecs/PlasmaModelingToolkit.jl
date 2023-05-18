module Models
import ..BoundaryConditions: BoundaryCondition, NeumannBoundaryCondition, DirichletBoundaryCondition, PeriodicBoundaryCondition
import ..InterfaceConditions: InterfaceCondition
import ..Grids: AxisymmetricGrid, Grid
import ..Domains: AxisymmetricDomain, Domain1D
import ..Geometry: Shape2D, Segment2D, Rectangle, Segment1D, Point1D, Shape
import ..Materials: Material, Conductor, Dielectric, PerfectlyMatchedLayer
import ..Distributions: Distribution
import ..Problems: BoundaryValueProblem, ParticleProblem, ParticleCollisionProblem
import ..InterfaceConditions: detect_interface_z!, detect_interface_r!
import ..Grids: discretize, discretize!, snap
import ..Species: Particles, Fluid
import ..ParticleBoundaries: ParticleBoundary
import ..Sources: SpeciesSource, SpeciesLoader
import ..Collisions: Collision
import Base: setindex!

abstract type DiscretizedModel end

include("models/fdtd.jl")
include("models/fdm.jl")
include("models/pic.jl")
include("models/fem.jl")
include("models/mcc.jl")
end