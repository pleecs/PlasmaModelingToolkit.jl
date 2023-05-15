struct ParticleCollisionProblem{DOMAIN}
	particles :: ParticleProblem{DOMAIN}
	collisions :: Vector{Collision}
	loaders :: Vector{Pair{Rectangle, SpeciesLoader}}
	ParticleCollisionProblem(domain) = new{typeof(domain)}(ParticleProblem(domain), [], [])
end

function setindex!(problem::ParticleCollisionProblem, loader::SpeciesLoader, region)
	if loader.species isa Fluid
		push!(problem.loaders, region => loader)
	end

	if loader.species isa Particles
		problem.particles[region] = loader
	end
end

function setindex!(problem::ParticleCollisionProblem, boundary::ParticleBoundary, segment::Segment2D)
	problem.particles[segment] = boundary
end

function +(problem::ParticleCollisionProblem, collision::Collision)
	push!(problem.collisions, collision)
	return problem
end