struct ParticleProblem{D, CS}
	domain :: Domain{D,CS}
	boundaries :: Vector{Pair{Shape{D}, ParticleBoundary}}
	sources :: Vector{Pair{Shape{D}, SpeciesSource}}
	loaders :: Vector{Pair{Shape{D}, SpeciesLoader}} 
	ParticleProblem(domain::Domain{D,CS}) where {D,CS} = new{D,CS}(domain, [], [], [])
end

function setindex!(problem::ParticleProblem{2, CS}, boundary::ParticleBoundary, segment::Segment2D) where {CS}
	push!(problem.boundaries, segment => boundary)
end

function setindex!(problem::ParticleProblem{2, CS}, source::SpeciesSource, rectangle::Rectangle) where {CS}
	push!(problem.sources, rectangle => source)
end

function setindex!(problem::ParticleProblem{2, CS}, loader::SpeciesLoader, rectangle::Rectangle) where {CS}
	push!(problem.loaders, rectangle => loader)
end

function setindex!(problem::ParticleProblem{1, CS}, boundary::ParticleBoundary, point::Point1D) where {CS}
	xmin = problem.domain.xmin
	xmax = problem.domain.xmax
	x, = point.coords
	
	@assert x ≈ xmin || x ≈ xmax "In 1D Particle Boundary can be added only on the edges of the domain!"

	push!(problem.boundaries, point => boundary)
end

function setindex!(problem::ParticleProblem{1, CS}, source::SpeciesSource, point::Point1D) where {CS}
	push!(problem.sources, point => source)
end

function setindex!(problem::ParticleProblem{1, CS}, loader::SpeciesLoader, point::Point1D) where {CS}
	push!(problem.loaders, point => loader)
end

function setindex!(problem::ParticleProblem{1, CS}, source::SpeciesSource, segment::Segment1D) where {CS}
	push!(problem.sources, segment => source)
end

function setindex!(problem::ParticleProblem{1, CS}, loader::SpeciesLoader, segment::Segment1D) where {CS}
	push!(problem.loaders, segment => loader)
end