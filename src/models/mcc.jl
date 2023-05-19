import ..Geometry: Shape
import ..Problems: ParticleCollisionProblem
import ..Species: Particles, Fluid
import ..ParticleBoundaries: ParticleBoundary
import ..Sources: SpeciesSource, SpeciesLoader
import ..Collisions: Collision

struct MCCModel{D,V,CS}
   particles :: Set{Particles}
      fluids :: Set{Fluid}
  collisions :: Vector{Collision}
     loaders :: Vector{Pair{Shape{D}, SpeciesLoader}}
end

function MCCModel(problem::ParticleCollisionProblem{D,CS}) where {D,CS}
  particles = Set{Particles}()
  fluids = Set{Fluid}()
  collisions = problem.collisions
  loaders = problem.loaders
  for collision in collisions
    if collision.source isa Particles
      push!(particles, collision.source)
    end
    if collision.target isa Fluid
      push!(fluids, collision.target)
    end
  end
  return MCCModel{D,3,CS}(particles, fluids, collisions, loaders)
end