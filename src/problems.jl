module Problems
import ..Geometry: Rectangle
import ..Boundaries: ParticleBoundary
import ..BoundaryConditions: BoundaryCondition
import ..Sources: SpeciesSource, SpeciesLoader
import Base: setindex!

struct ParticleProblem{D}
	domain :: D
	boundaries :: Vector{Pair{Any, ParticleBoundary}}
	sources :: Vector{Pair{Rectangle, SpeciesSource}}
	loaders :: Vector{Pair{Rectangle, SpeciesLoader}} 
	ParticleProblem(domain) = new{typeof(domain)}(domain, [], [], [])
end

function setindex!(problem::ParticleProblem, phenomenon, region)
	if phenomenon isa ParticleBoundary
    	push!(model.boundaries, region => phenomenon)
    elseif phenomenon isa SpeciesSource
    	push!(model.sources, region => phenomenon)
	elseif phenomenon isa SpeciesLoader
		push!(model.loaders, region => phenomenon)
	end
end

struct BoundaryValueProblem{D}
	domain :: D
	constraints :: Vector{Pair{Any, BoundaryCondition}}
	BoundaryValueProblem(domain) = new{typeof(domain)}(domain, [])
end

function setindex!(problem::BoundaryValueProblem, constraint::BoundaryCondition, region)
    push!(problem.constraints, region => constraint)
end
end