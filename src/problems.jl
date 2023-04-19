module Problems
import Base: setindex!

struct ParticleProblem
end

struct BoundaryValueProblem{D}
	domain :: D
	constraints :: Vector{Pair{Any, Any}}
	BoundaryValueProblem(domain) = new{typeof(domain)}(domain, [])
end

function setindex!(model::BoundaryValueProblem, constraint, region)
    push!(model.constraints, region => constraint)
end
end