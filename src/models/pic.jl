struct PICModel{D,V,CS} <: DiscretizedModel 
      grid :: Grid{D,CS}
 particles :: Set{Particles}
   weights :: Dict{Particles, Float64}
  maxcount :: Dict{Particles, UInt64}
boundaries :: Vector{Pair{Shape{D}, ParticleBoundary}}
   sources :: Vector{Pair{Shape{D}, SpeciesSource}}
   loaders :: Vector{Pair{Shape{D}, SpeciesLoader}} 
end

function PICModel(problem::ParticleProblem{D,CS}, args...; maxcount, weights) where {D,CS}
  @assert length(args) == D

  grid = discretize(problem.domain, args...)
  particles = Set{Particles}()
  weights = Dict(weights...)
  maxcount = Dict(maxcount...)
  boundaries = problem.boundaries
  sources = problem.sources
  loaders = problem.loaders

  for (_, source) in sources
    if source.species isa Particles
      push!(particles, source.species)
    end
  end

  for (_, loader) in loaders
    if loader.species isa Particles
      push!(particles, loader.species)
    end
  end

  return PICModel{D,3,CS}(grid, particles, weights, maxcount, boundaries, sources, loaders)
end

function PICModel(problem::ParticleCollisionProblem{D,CS}, args...; maxcount, weights) where{D,CS}
  @assert length(args) == D
  return PICModel(problem.particles, args..., maxcount=maxcount, weights=weights)
end
