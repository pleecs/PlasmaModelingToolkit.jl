struct BoundaryValueProblem{DOMAIN}
	domain :: DOMAIN
	constraints :: Vector{Pair{Shape2D, BoundaryCondition}}
	BoundaryValueProblem(domain) = new{typeof(domain)}(domain, [])
end

function setindex!(problem::BoundaryValueProblem, constraint::BoundaryCondition, region::Shape2D)
    push!(problem.constraints, region => constraint)
end