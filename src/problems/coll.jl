struct ParticleCollisionProblem{D, CS}
	particles :: ParticleProblem{D, CS}
	collisions :: Vector{Collision}
	loaders :: Vector{Pair{Shape{D}, SpeciesLoader}}
	ParticleCollisionProblem(domain::Domain{D,CS}) where {D,CS} = new{D,CS}(ParticleProblem(domain), [], [])
end

function setindex!(problem::ParticleCollisionProblem{2}, loader::SpeciesLoader, region::Rectangle)
	if loader.species isa Fluid
		push!(problem.loaders, region => loader)
	end

	if loader.species isa Particles
		problem.particles[region] = loader
	end
end

function setindex!(problem::ParticleCollisionProblem{2}, boundary::ParticleBoundary, segment::Segment2D)
	problem.particles[segment] = boundary
end

function setindex!(problem::ParticleCollisionProblem{1}, boundary::ParticleBoundary, point::Point1D)
	problem.particles[point] = boundary
end

function setindex!(problem::ParticleCollisionProblem{1}, loader::SpeciesLoader, region::Segment1D)
	if loader.species isa Fluid
		push!(problem.loaders, region => loader)
	end

	if loader.species isa Particles
		problem.particles[region] = loader
	end
end

function +(problem::ParticleCollisionProblem, collision::Collision)
	push!(problem.collisions, collision)
	return problem
end