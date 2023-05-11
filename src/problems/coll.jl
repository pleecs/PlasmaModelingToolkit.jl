struct CollisionProblem{DOMAIN}
	domain :: DOMAIN
	loaders :: Vector{Pair{Rectangle, SpeciesLoader}}
	collisions :: Vector{Collision}
	CollisionProblem(domain) = new{typeof(domain)}(domain, [], [])
end

function setindex!(problem::CollisionProblem, loader::SpeciesLoader, region)
    push!(problem.loaders, region => loader)
end

function +(problem::CollisionProblem, collision::Collision)
	push!(problem.collisions, collision)
	return problem
end