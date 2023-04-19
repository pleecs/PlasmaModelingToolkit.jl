module Models
import ..BoundaryConditions: BoundaryCondition, DirichletBoundaryCondition
import ..InterfaceConditions: InterfaceCondition
import ..Grid: AbstractGrid, AxisymmetricGrid
import ..Domains: AxisymmetricDomain
import ..Geometry: Shape, Segment
import ..Materials: Material, Conductor, Dielectric
import ..Problems: BoundaryValueProblem

import ..InterfaceConditions: detect_interface_z!, detect_interface_r!
import ..Grid: discretize, discretize!, snap
import Base: setindex!

abstract type DiscretizedModel end

include("models/fdtd.jl")
include("models/fdm.jl")
include("models/pic.jl")
include("models/fem.jl")
end