module Problems
import ..Geometry: Rectangle, Segment
import ..Boundaries: ParticleBoundary
import ..BoundaryConditions: BoundaryCondition
import ..Sources: SpeciesSource, SpeciesLoader
import Base: setindex!

struct ParticleProblem{D}
	domain :: D
	boundaries :: Vector{Pair{Segment, ParticleBoundary}}
	sources :: Vector{Pair{Rectangle, SpeciesSource}}
	loaders :: Vector{Pair{Rectangle, SpeciesLoader}} 
	ParticleProblem(domain) = new{typeof(domain)}(domain, [], [], [])
end

function setindex!(problem::ParticleProblem, boundary::ParticleBoundary, segment::Segment)
	push!(model.boundaries, segment => boundary)
end

function setindex!(problem::ParticleProblem, source::SpeciesSource, rectangle::Rectangle) 
	push!(model.sources, rectangle => source)
end

function setindex!(problem::ParticleProblem, loader::SpeciesLoader, rectangle::Rectangle)
	push!(model.loaders, rectangle => loader)
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