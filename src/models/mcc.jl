struct MCCModel{D,V,CS}
	particles :: Set{Particles}
	fluids :: Set{Fluid}
	collisions :: Vector{Collision}
	loaders :: Vector{Pair{Shape{D}, SpeciesLoader}}
end

function MCCModel(problem::ParticleCollisionProblem{1,:X})
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
	return MCCModel{1,3,:X}(particles, fluids, collisions, loaders)
end