module Collisions
import ..Species: Particles, Fluid
import ..CrossSections: CrossSection


struct Collision{PROCESS}
  source :: Particles
  target :: Fluid
  σ :: CrossSection
end

const ElasticCollision = Collision{:Elastic}
const IsotropicScatteringCollision = Collision{:IsotropicScattering}
const ExcitationCollision = Collision{:Excitation}
const BackwardScatteringCollision = Collision{:BackwardScattering}
const IonizationCollision = Collision{:Ionization}

function Collision{PROCESS}(source, target; σ_dataset::Symbol, ε=nothing) where {PROCESS}
  σ = CrossSection(σ_dataset, PROCESS, source, target, ε)
  return Collision{PROCESS}(source, target, σ)
end
end