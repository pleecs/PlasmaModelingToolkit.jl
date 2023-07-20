module Collisions
import ..Species: Particles, Fluid
import ..CrossSections: CrossSection
import ..Constants

abstract type Collision end

struct Scattering{TYPE} 
  sym :: TYPE
end

IsotropicScattering() = Scattering(:Isotropic)
BackwardScattering() = Scattering(:Backward)

struct ElasticCollision <: Collision
  source :: Particles
  target :: Fluid
  σ :: Matrix{Float64}
  scattering :: Scattering
end

function ElasticCollision(source, target, dataset; scattering=nothing) 
  cs  = CrossSection(dataset, :Elastic, source, target; scattering)
  σ = cs.data
  if isnothing(scattering)
    @assert "scattering" in cs.attributes "There is no scattering specification in dataset, you have to provide one"
    scattering = Scattering{cs.attributes["scattering"]}
  end
  return ElasticCollision(source, target, σ, scattering)
end

struct ExcitationCollision <: Collision
  source :: Particles
  target :: Fluid
  ε_loss :: Float64
  σ :: Matrix{Float64}  
  scattering :: Scattering
end

function ExcitationCollision(source, target, dataset; ε_loss, scattering=nothing) 
  cs = CrossSection(dataset, :Excitation, source, target; ε_loss, scattering)
  σ = cs.data
  if isnothing(scattering)
    @assert "scattering" in cs.attributes "There is no scattering specification in dataset, you have to provide one"
    scattering = Scattering{cs.attributes["scattering"]}
  end
  return ExcitationCollision(source, target, ε_loss, σ, scattering)
end

struct IonizationCollision <: Collision
  source :: Particles
  target :: Fluid
  ions :: Particles
  ω :: Float64
  ε_loss :: Float64
  σ :: Matrix{Float64}
  scattering :: Scattering
end

function IonizationCollision(source, target::Fluid{TARGET}, dataset; ε_loss, ions, scattering=nothing, ω=NaN) where {TARGET}
  if isnan(ω) && TARGET in keys(Constants.ω)
    ω = Constants.ω[TARGET]
  end
  cs = CrossSection(dataset, :Ionization, source, target; scattering, ε_loss)
  σ = cs.data
  if isnothing(scattering)
    @assert "scattering" in cs.attributes "There is no scattering specification in dataset, you have to provide one"
    scattering = Scattering(cs.attributes["scattering"])
  end
  return IonizationCollision(source, target, ions, ω, ε_loss, σ, scattering)
end
end