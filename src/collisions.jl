module Collisions
import ..Species: Particles, Fluid
import ..CrossSections: CrossSection
import ..Constants

abstract type Collision end
abstract type Scattering end
struct IsotropicScattering <: Scattering end
struct BackwardScattering <: Scattering end
struct VahediScattering <: Scattering end
struct OpalScattering <: Scattering
  Ē :: Float64
end

symbol(::Fluid{SYM}) where {SYM} = SYM

function Scattering(sym::Symbol, target::Fluid)
  if sym == :Isotropic
    scattering =  IsotropicScattering()
  elseif sym == :Backward
    scattering =  BackwardScattering()
  elseif sym == :Vahedi
    scattering =  VahediScattering()
  elseif sym == :Opal
    @assert symbol(target) in keys(Constants.Ē) "Missing value of ejected electron spectrum shape parameter (Ē) parameter for $(string(symbol(target))) background gas."
    if symbol(target) in [:Ar, :Kr, :Xe]
      @warn "Value of shape parameter Ē for $(string(symbol(target))) might be inaccurate (see: https://doi.org/10.1063/1.1676707)"
    end
    Ē = Constants.Ē[symbol(target)]
    scattering = OpalScattering(Ē)
  end
  return scattering
end

struct ElasticCollision <: Collision
  source :: Particles
  target :: Fluid
  σ :: Matrix{Float64}
  scattering :: Scattering
end

function ElasticCollision(source, target, dataset; scattering=nothing)
  @assert scattering != :Opal "Opal scattering can be defined only for ionization collision"

  cs  = CrossSection(dataset, :Elastic, source, target; scattering)

  if isnothing(scattering)
    @assert "scattering" in keys(cs.attributes) "There is no scattering specification in dataset, you have to provide one"
    scattering = Scattering(cs.attributes["scattering"], target)
  else
    scattering = Scattering(scattering, target)
  end

  return ElasticCollision(source, target, cs.data, scattering)
end

struct ExcitationCollision <: Collision
  source :: Particles
  target :: Fluid
  ε_loss :: Float64
  σ :: Matrix{Float64}  
  scattering :: Scattering
  excited_state :: Symbol
end

function ExcitationCollision(source, target, dataset; ε_loss, scattering=nothing, excited_state=nothing)
  @assert scattering != :Opal "Opal scattering can be defined only for ionization collision"

  cs = CrossSection(dataset, :Excitation, source, target; ε_loss, scattering, excited_state)
  
  if isnothing(scattering)
    @assert "scattering" in keys(cs.attributes) "There is no scattering specification in dataset, you have to provide one"
    scattering = Scattering(cs.attributes["scattering"], target)
  else
    scattering = Scattering(scattering, target)
  end

  if isnothing(excited_state)
    excited_state = Symbol("_")
  else
    excited_state = Symbol(excited_state)
  end

  return ExcitationCollision(source, target, ε_loss, cs.data, scattering, excited_state)
end

struct IonizationCollision <: Collision
  source :: Particles
  target :: Fluid
  ions :: Particles
  ε_loss :: Float64
  σ :: Matrix{Float64}
  scattering :: Scattering
end

function IonizationCollision(source, target, dataset; ε_loss, ions, scattering=nothing)
  cs = CrossSection(dataset, :Ionization, source, target; scattering, ε_loss)

  if isnothing(scattering)
    @assert "scattering" in keys(cs.attributes) "There is no scattering specification in dataset, you have to provide one"
    scattering = Scattering(cs.attributes["scattering"], target)
  else
    scattering = Scattering(scattering, target)
  end

  return IonizationCollision(source, target, ions, ε_loss, cs.data, scattering)
end
end