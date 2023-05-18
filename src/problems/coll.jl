struct ParticleCollisionProblem{D, CS}
	particles :: ParticleProblem{D, CS}
	collisions :: Vector{Collision}
	loaders :: Vector{Pair{Shape{D}, SpeciesLoader}}
	ParticleCollisionProblem(domain::Domain{D,CS}) where {D,CS} = new{D,CS}(ParticleProblem(domain), [], [])
end

function setindex!(problem::ParticleCollisionProblem{2,CS}, loader::SpeciesLoader, region::Rectangle) where {CS}
	if loader.species isa Fluid
		push!(problem.loaders, region => loader)
	end

	if loader.species isa Particles
		problem.particles[region] = loader
	end
end

function setindex!(problem::ParticleCollisionProblem{2,CS}, boundary::ParticleBoundary, segment::Segment2D) where {CS}
	problem.particles[segment] = boundary
end

function setindex!(problem::ParticleCollisionProblem{1, CS}, boundary::ParticleBoundary, point::Point1D) where {CS}
	problem.particles[point] = boundary
end

function setindex!(problem::ParticleCollisionProblem{1,CS}, loader::SpeciesLoader, region::Segment1D) where {CS}
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