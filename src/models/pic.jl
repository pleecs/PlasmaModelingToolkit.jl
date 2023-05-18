struct PICModel{D,V,CS} <: DiscretizedModel 
      grid :: Grid{D,CS}
 particles :: Set{Particles}
   weights :: Dict{Particles, Float64}
  maxcount :: Dict{Particles, UInt64}
boundaries :: Vector{Pair{Shape{D}, ParticleBoundary}}
   sources :: Vector{Pair{Shape{D}, SpeciesSource}}
   loaders :: Vector{Pair{Shape{D}, SpeciesLoader}} 
end

function PICModel(problem::ParticleProblem{2,:ZR}, nz, nr; maxcount, weights)
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

  return PICModel{2,3,:ZR}(grid, particles, weights, maxcount, boundaries, sources, loaders)
end

function PICModel(problem::ParticleCollisionProblem{2,:ZR}, nz, nr; maxcount, weights)
  return PICModel(problem.particles, nz, nr, maxcount=maxcount, weights=weights)
end

function PICModel(problem::ParticleProblem{1, :X}, nx; maxcount, weights)
  grid = discretize(problem.domain, nx)
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
  return PICModel{1,3,:X}(grid, particles, weights, maxcount, boundaries, sources, loaders)
end

function PICModel(problem::ParticleCollisionProblem{1,:X}, nx; maxcount, weights)
  return PICModel(problem.particles, nx, maxcount=maxcount, weights=weights)
end

function setindex!(model::PICModel, bc::ParticleBoundary, point::Point1D)
  # TODO: add this
  return nothing
end