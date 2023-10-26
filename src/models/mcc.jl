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
  particles = Set(problem.particles.particles)
  fluids = Set(problem.fluids)
  collisions = problem.collisions
  loaders = vcat(problem.loaders, problem.particles.loaders)
  return MCCModel{D,3,CS}(particles, fluids, collisions, loaders)
end