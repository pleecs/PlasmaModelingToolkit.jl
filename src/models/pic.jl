struct PICModel{D,V} <: DiscretizedModel 
      grid :: AbstractGrid{D}
 particles :: Set{Particles}
   weights :: Dict{Particles, Float64}
  maxcount :: Dict{Particles, UInt64}
boundaries :: Vector{Pair{Segment2D, ParticleBoundary}}
   sources :: Vector{Pair{Rectangle, SpeciesSource}}
   loaders :: Vector{Pair{Rectangle, SpeciesLoader}} 
end

# pic = PICModel(problem, NZ + 1, NR + 1, maxcount = (e => 200_000, iHe => 200_000))
function PICModel{2,3}(problem::ParticleProblem{AxisymmetricDomain}, nz, nr; maxcount, weights)
  grid = discretize(problem.domain, nz, nr)
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

  return PICModel{2,3}(grid, particles, weights, maxcount, boundaries, sources, loaders)
end

function PICModel{2,3}(problem::ParticleCollisionProblem{AxisymmetricDomain}, nz, nr; maxcount, weights)
  return PICModel{2,3}(problem.particles, nz, nr, maxcount=maxcount, weights=weights)
end