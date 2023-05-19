import ..Domains: Domain
import ..Geometry: Shape, Segment2D, Rectangle, Point1D, Segment1D
import ..ParticleBoundaries: ParticleBoundary
import ..Sources: SpeciesSource, SpeciesLoader

struct ParticleProblem{D, CS}
  domain :: Domain{D,CS}
  boundaries :: Vector{Pair{Shape{D}, ParticleBoundary}}
  sources :: Vector{Pair{Shape{D}, SpeciesSource}}
  loaders :: Vector{Pair{Shape{D}, SpeciesLoader}} 
  ParticleProblem(domain::Domain{D,CS}) where {D,CS} = new{D,CS}(domain, [], [], [])
end

function setindex!(problem::ParticleProblem{2}, boundary::ParticleBoundary, segment::Segment2D)
  push!(problem.boundaries, segment => boundary)
end

function setindex!(problem::ParticleProblem{2}, source::SpeciesSource, rectangle::Rectangle)
  push!(problem.sources, rectangle => source)
end

function setindex!(problem::ParticleProblem{2}, loader::SpeciesLoader, rectangle::Rectangle)
  push!(problem.loaders, rectangle => loader)
end

function setindex!(problem::ParticleProblem{1}, boundary::ParticleBoundary, point::Point1D)
  xmin = problem.domain.xmin
  xmax = problem.domain.xmax
  x, = point.coords
  
  @assert x ≈ xmin || x ≈ xmax "In 1D Particle Boundary can be added only on the edges of the domain!"

  push!(problem.boundaries, point => boundary)
end

function setindex!(problem::ParticleProblem{1}, source::SpeciesSource, segment::Segment1D)
  push!(problem.sources, segment => source)
end

function setindex!(problem::ParticleProblem{1}, loader::SpeciesLoader, segment::Segment1D)
  push!(problem.loaders, segment => loader)
end