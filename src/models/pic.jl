import ..Grids: Grid
import ..Geometry: Shape
import ..Problems: ParticleProblem, ParticleCollisionProblem
import ..Grids: discretize
import ..Species: Particles
import ..ParticleBoundaries: ParticleBoundary
import ..Sources: SpeciesSource, SpeciesLoader

struct PICModel{D,V,CS}
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
  
  for (species, _) in maxcount
    if species in particles
      @warn "Repeated $(species) in maxcount definition. The last value applies."
    elseif species isa Particles
      push!(particles, species)
    end
  end

  for (species, _) in weights
    if species in particles
      continue
    elseif species isa Particles
      @error "Unknown species $(species) (no maxcount defined for it)"
    end
  end
  
  weights = Dict(weights...)
  maxcount = Dict(maxcount...)
  boundaries = problem.boundaries
  sources = problem.sources
  loaders = problem.loaders

  for (_, source) in sources
    if source.species in particles
      continue
    elseif source.species isa Particles
      @error "Unknown species $(source.species) (no maxcount defined for it)"
    end
  end

  for (_, loader) in loaders
    if loader.species in particles
      continue
    elseif loader.species isa Particles
      @error "Unknown species $(loader.species) (no maxcount defined for it)"
    end
  end

  return PICModel{D,3,CS}(grid, particles, weights, maxcount, boundaries, sources, loaders)
end

function PICModel(problem::ParticleCollisionProblem{D,CS}, args...; maxcount, weights) where{D,CS}
  @assert length(args) == D
  return PICModel(problem.particles, args..., maxcount=maxcount, weights=weights)
end
