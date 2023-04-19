module Models
import ..BoundaryConditions: BoundaryCondition, DirichletBoundaryCondition
import ..InterfaceConditions: InterfaceCondition
import ..Grid: AbstractGrid, AxisymmetricGrid
import ..Domains: AxisymmetricDomain
import ..Geometry: Shape, Segment
import ..Materials: Material, Conductor, Dielectric

import ..InterfaceConditions: detect_interface_z!, detect_interface_r!
import ..Grid: discretize, discretize!, snap
import Base: setindex!

struct Model{D}
	domain :: D
	constraints :: Vector{Pair{Any, Any}}
	Model(domain) = new{typeof(domain)}(domain, [])
end

function setindex!(model::Model, constraint, region)
    push!(model.constraints, region => constraint)
end

abstract type DiscretizedModel end

include("models/fdtd.jl")
include("models/fdm.jl")
include("models/pic.jl")
include("models/fem.jl")
end