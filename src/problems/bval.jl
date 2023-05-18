struct BoundaryValueProblem{D,CS}
	domain :: Domain{D}
	constraints :: Vector{Pair{Shape{D}, BoundaryCondition}}
	BoundaryValueProblem(domain::Domain{D,CS}) where {D,CS} = new{D,CS}(domain, [])
end

function setindex!(problem::BoundaryValueProblem{D,CS}, constraint::BoundaryCondition, region::Shape{D}) where {D,CS}
    push!(problem.constraints, region => constraint)
end