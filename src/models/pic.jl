struct PICModel{D,V} <: DiscretizedModel 
      grid :: AbstractGrid{D}
  timestep :: Float64
    fluids :: Vector{Fluid}
 particles :: Vector{Particles}
   weights :: Dict{Particles, Float64}
  maxcount :: Dict{Particles, UInt64}
boundaries :: Vector{Pair{Segment, ParticleBoundary}}
   sources :: Vector{Pair{Rectangle, SpeciesSource}}
   loaders :: Vector{Pair{Rectangle, SpeciesLoader}} 
end