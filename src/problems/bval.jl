import ..Geometry: Shape
import ..Domains: Domain, isboundary
import ..BoundaryConditions: BoundaryCondition, PeriodicBoundaryCondition
import Base: setindex!

struct BoundaryValueProblem{D,CS}
  domain :: Domain{D,CS}
  constraints :: Vector{Pair{Shape{D}, BoundaryCondition}}
  BoundaryValueProblem(domain::Domain{D,CS}) where {D,CS} = new{D,CS}(domain, [])
end

function setindex!(problem::BoundaryValueProblem{D}, constraint::BoundaryCondition, region::Shape{D}) where {D}
  push!(problem.constraints, region => constraint)
end

function setindex!(problem::BoundaryValueProblem{2}, constraint::PeriodicBoundaryCondition, region::Shape)
  @assert region isa Segment2D "PeriodicBoundaryCondition can be only added at Segment2D" 
  @assert isboundary(problem.domain, region) "PeriodicBoundaryCondition can be only added on domain boundaries"
  push!(problem.constraints, region => constraint)
end