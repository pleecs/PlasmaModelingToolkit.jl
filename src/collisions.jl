module Collisions
import ..Species: Particles, Fluid
import ..CrossSections: AbstractCrossSections

abstract type Collision end

struct IsotropicScatteringCollision <: Collision
	source :: Particles
	target :: Fluid
	σ :: AbstractCrossSections
end
IsotropicScatteringCollision(s, t; σ) = IsotropicScatteringCollision(s, t, σ)

struct IonizationCollision <: Collision
	source :: Particles
	target :: Fluid
	σ :: AbstractCrossSections
	ω :: Float64
end
IonizationCollision(s, t; σ, ω) = IonizationCollision(s, t, σ, ω)

struct ExcitationCollision <: Collision
	source :: Particles
	target :: Fluid
	σ :: AbstractCrossSections
end
ExcitationCollision(s, t; σ) = ExcitationCollision(s, t, σ)

struct BackwardScatteringCollision <: Collision
	source :: Particles
	target :: Fluid
	σ :: AbstractCrossSections
end
BackwardScatteringCollision(s, t; σ) = BackwardScatteringCollision(s, t, σ)
end