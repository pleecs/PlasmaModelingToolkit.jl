import ..Domains: Domain
import ..Geometry: Shape, Segment2D, Rectangle, Point1D, Segment1D
import ..ParticleBoundaries: ParticleBoundary
import ..Sources: ParticleSource, ParticleLoader
import ..Species: Particles, Fluid

struct ParticleProblem{D, CS}
  domain :: Domain{D,CS}
  particles :: Set{Particles}
  boundaries :: Vector{Pair{Shape{D}, ParticleBoundary}}
  sources :: Vector{Pair{Shape{D}, ParticleSource}}
  loaders :: Vector{Pair{Shape{D}, ParticleLoader}} 
end

function ParticleProblem(domain::Domain{D,CS}, species...) where {D,CS} 
  particles = Set{Particles}()
  for element in species
    @assert element isa Particles "You can only add Particles to a ParticleProblem"
      push!(particles, element)
  end
  return ParticleProblem{D,CS}(
    domain,
    particles,
    [],
    [],
    [])
end

function setindex!(problem::ParticleProblem{2}, boundary::ParticleBoundary, segment::Segment2D)
  if isempty(boundary.particles)
    for species in problem.particles
      push!(boundary.particles, species)
    end
  end
  @assert all(x->(x in problem.particles), boundary.particles) "You have to add $(boundary.particles) to a problem first before adding a boundary for it"
  push!(problem.boundaries, segment => boundary)
end

function setindex!(problem::ParticleProblem{2}, source::ParticleSource, rectangle::Rectangle)
  @assert source.species in problem.particles "You have to add $(source.species) to a problem first before adding a source for it"
  push!(problem.sources, rectangle => source)
end

function setindex!(problem::ParticleProblem{2}, loader::ParticleLoader, rectangle::Rectangle)
  @assert loader.species in problem.particles "You have to add $(loader.species) to a problem first before adding a loader for it"
  push!(problem.loaders, rectangle => loader)
end

function setindex!(problem::ParticleProblem{1}, boundary::ParticleBoundary, point::Point1D)
  if isempty(boundary.particles)
    for species in problem.particles
      push!(boundary.particles, species)
    end
  end
  @assert all(x->(x in problem.particles), boundary.particles) "You have to add $(boundary.particles) to a problem first before adding a boundary for it"
  xmin = problem.domain.xmin
  xmax = problem.domain.xmax
  x, = point.coords
  
  @assert x ≈ xmin || x ≈ xmax "In 1D Particle Boundary can be added only on the edges of the domain!"

  push!(problem.boundaries, point => boundary)
end

function setindex!(problem::ParticleProblem{1}, source::ParticleSource, segment::Segment1D)
  @assert source.species in problem.particles "You have to add $(source.species) to a problem first before adding a source for it"
  push!(problem.sources, segment => source)
end

function setindex!(problem::ParticleProblem{1}, loader::ParticleLoader, segment::Segment1D)
  @assert loader.species in problem.particles "You have to add $(loader.species) to a problem first before adding a loader for it"
  push!(problem.loaders, segment => loader)
end