import ..Grids: Grid
import ..Geometry: Shape
import ..Problems: ParticleProblem, ParticleCollisionProblem
import ..Grids: discretize
import ..Species: Particles
import ..ParticleBoundaries: ParticleBoundary
import ..Sources: ParticleSource, ParticleLoader

struct PICModel{D,V,CS}
      grid :: Grid{D,CS}
 particles :: Set{Particles}
   weights :: Dict{Particles, Float64}
  maxcount :: Dict{Particles, UInt64}
boundaries :: Vector{Pair{Shape{D}, ParticleBoundary}}
   sources :: Vector{Pair{Shape{D}, ParticleSource}}
   loaders :: Vector{Pair{Shape{D}, ParticleLoader}} 
end

function PICModel(problem::ParticleProblem{D,CS}, args...; maxcount, weights) where {D,CS}
  @assert length(args) == D

  @assert all(x->(x in problem.particles), first.(maxcount)) "Unknown particles in \"maxcount\" definition"
  @assert all(x->(x in first.(maxcount)), problem.particles) "Missing definition of \"maxcount\" for some particles"

  @assert all(x->(x in problem.particles), first.(weights)) "Unknown particles in \"weights\" definition"
  @assert all(x->(x in first.(weights)), problem.particles) "Missing definition of \"weights\" for some particles"

  grid = discretize(problem.domain, args...)
  particles = problem.particles
  weights = Dict(weights...)
  maxcount = Dict(maxcount...)
  boundaries = problem.boundaries
  sources = problem.sources
  loaders = problem.loaders

  return PICModel{D,3,CS}(grid, particles, weights, maxcount, boundaries, sources, loaders)
end

function PICModel(problem::ParticleCollisionProblem{D,CS}, args...; maxcount, weights) where{D,CS}
  @assert length(args) == D
  return PICModel(problem.particles, args..., maxcount=maxcount, weights=weights)
end
