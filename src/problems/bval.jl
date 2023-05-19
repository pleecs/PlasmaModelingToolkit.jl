import ..Geometry: Shape
import ..Domains: Domain
import ..BoundaryConditions: BoundaryCondition
import Base: setindex!

struct BoundaryValueProblem{D,CS}
  domain :: Domain{D,CS}
  constraints :: Vector{Pair{Shape{D}, BoundaryCondition}}
  BoundaryValueProblem(domain::Domain{D,CS}) where {D,CS} = new{D,CS}(domain, [])
end

function setindex!(problem::BoundaryValueProblem{D}, constraint::BoundaryCondition, region::Shape{D}) where {D}
  push!(problem.constraints, region => constraint)
end