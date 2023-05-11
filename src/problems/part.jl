struct ParticleProblem{DOMAIN}
	domain :: DOMAIN
	boundaries :: Vector{Pair{Segment, ParticleBoundary}}
	sources :: Vector{Pair{Rectangle, SpeciesSource}}
	loaders :: Vector{Pair{Rectangle, SpeciesLoader}} 
	ParticleProblem(domain) = new{typeof(domain)}(domain, [], [], [])
end

function setindex!(problem::ParticleProblem, boundary::ParticleBoundary, segment::Segment)
	push!(problem.boundaries, segment => boundary)
end

function setindex!(problem::ParticleProblem, source::SpeciesSource, rectangle::Rectangle) 
	push!(problem.sources, rectangle => source)
end

function setindex!(problem::ParticleProblem, loader::SpeciesLoader, rectangle::Rectangle)
	push!(problem.loaders, rectangle => loader)
end