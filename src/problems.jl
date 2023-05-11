module Problems
import ..Geometry: Rectangle, Segment, Shape
import ..ParticleBoundaries: ParticleBoundary
import ..BoundaryConditions: BoundaryCondition
import ..Sources: SpeciesSource, SpeciesLoader
import ..Collisions: Collision
import Base: setindex!, +

include("problems/bval.jl")
include("problems/part.jl")
include("problems/coll.jl")
end