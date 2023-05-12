struct MCCModel{D,V}
	particles :: Set{Particles}
	fluids :: Set{Fluid}
	collisions :: Vector{Collision}
	loaders :: Vector{Pair{Rectangle, SpeciesLoader}}
end

function MCCModel{2,3}(problem::ParticleCollisionProblem)
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
	return MCCModel{2,3}(particles, fluids, collisions, loaders)
end