struct BoundaryValueProblem{DOMAIN}
	domain :: DOMAIN
	constraints :: Vector{Pair{Shape, BoundaryCondition}}
	BoundaryValueProblem(domain) = new{typeof(domain)}(domain, [])
end

function setindex!(problem::BoundaryValueProblem, constraint::BoundaryCondition, region::Shape)
    push!(problem.constraints, region => constraint)
end