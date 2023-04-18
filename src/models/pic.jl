struct PICModel <: DiscretizedModel 
	grid :: AbstractGrid
	species :: Vector{KineticSpecies}
	gas :: FluidSpecies
	bcs :: Vector{Pair{Segment, ParticleBoundaryCondition}}
	sources :: Vector{Pair{Shape, ParticleSource}}
	loaders :: Vector{Pair{Shape, ParticleLoader}} 
end