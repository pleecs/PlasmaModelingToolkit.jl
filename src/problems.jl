module Problems
import ..Geometry: Rectangle, Segment2D, Shape2D, Shape, Point1D, Segment, Segment1D
import ..Domains: Domain
import ..ParticleBoundaries: ParticleBoundary
import ..BoundaryConditions: BoundaryCondition
import ..Sources: SpeciesSource, SpeciesLoader
import ..Collisions: Collision
import ..Species: Particles, Fluid
import Base: setindex!, +

include("problems/bval.jl")
include("problems/part.jl")
include("problems/coll.jl")
end