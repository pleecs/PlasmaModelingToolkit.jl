import ..Geometry: Rectangle, Segment2D, Shape, Point1D, Segment1D
import ..ParticleBoundaries: ParticleBoundary
import ..Sources: FluidLoader
import ..Collisions: Collision
import Base: setindex!, +

struct ParticleCollisionProblem{D, CS}
  particles :: ParticleProblem{D, CS}
  fluids :: Vector{Fluid}
  collisions :: Vector{Collision}
  loaders :: Vector{Pair{Shape{D}, FluidLoader}}  
end

function ParticleCollisionProblem(domain::Domain{D,CS}, species...) where {D,CS}
  particles = filter(x->(x isa Particles), species)
  fluids = filter(x->(x isa Fluid), species)

  return ParticleCollisionProblem{D, CS}(
    ParticleProblem(domain, particles...),
    collect(fluids),
    [],
    [])
end

function +(problem::ParticleCollisionProblem, collision::Collision)
  @assert collision.source in problem.particles.particles "You have to add $(collision.source) to a problem before using it as a collision source"
  @assert collision.target in problem.fluids "You have to add $(collision.target) to a problem before using it as a collision target" 
  push!(problem.collisions, collision)
  return problem
end

function setindex!(problem::ParticleCollisionProblem{2}, loader::FluidLoader, region::Rectangle)
  @assert loader.species in problem.fluids "You have to add $(loader.species) to a problem first before adding a loader for it"  
  push!(problem.loaders, region => loader)
end

function setindex!(problem::ParticleCollisionProblem{1}, loader::FluidLoader, region::Segment1D)
  @assert loader.species in problem.fluids "You have to add $(loader.species) to a problem first before adding a loader for it"
  push!(problem.loaders, region => loader)
end

function setindex!(problem::ParticleCollisionProblem, value, key)
  problem.particles[key] = value
end
