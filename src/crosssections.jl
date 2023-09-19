module CrossSections
import ..Species: Particles, Fluid
import JLD2: load

abstract type AbstractCrossSections end
struct Biagi{SYM} <: AbstractCrossSections end
Biagi(sym::Symbol) = Biagi{sym}()

Biagi(;version) = load("$(Main.DATASET_PATH)/Biagi-$(string(version)).jld2")#, "Biagi-7.1")
Phelps() = load("$(Main.DATASET_PATH)/Phelps.jld2")#, "Phelps")

struct CrossSection
  data :: Matrix{Float64}
  attributes :: Dict{String, Any}
end

function resample(data::Matrix{Float64}, n=1000, Δε=nothing, min=nothing, max=nothing)
  min = isnothing(min) ? min(data[:,1]) : min
  max = isnothing(max) ? max(data[:,1]) : max

  interp = LinearInterpolation(data[:,1], data[:,2], extrapolation_bc=Flat())
  ε = collect(isnothing(Δε) ? range(min, max, length=n) : range(min, max, step=Δε))
  σ = broadcast(interp, ε)
  return hcat(ε, σ)
end


function CrossSection(dataset, type::Symbol, source::Particles{SOURCE}, target::Fluid{TARGET}; ε_loss=nothing, scattering=nothing) where {SOURCE, TARGET}
  dataset_name = first(keys(dataset))

  processes = dataset[dataset_name][SOURCE][TARGET][type]
  
  if !isnothing(ε_loss)
    filter!(process->process["ε_loss"] == ε_loss, processes)
  end

  @assert length(processes) > 0 "In $(dataset_name) dataset there is no data for $(string(type)) collision between $(string(source)) and $(string(target)) with specified energy level ($ε_loss)"

  if !isnothing(scattering)
    specified = filter(process->haskey(process,"scattering"), processes)
    filter!(process->process["scattering"] == scattering.sym, specified)

    if length(specified) == 0
      filter!(process->!haskey(process,"scattering"), processes)
    else
      processes = specified
    end
  end

  @assert length(processes) > 0 "In $(dataset_name) dataset there is no data for $(string(type)) collision with specified scattering type (nor universal one)"
  @assert length(processes) == 1 "In $(dataset_name) dataset there more than one entry for $(string(type)) collision with specified attributes, please provide more information"

  process = first(processes)
  data = process["data"]
  attributes = Dict{String, Any}()

  if haskey(process, "ε_loss")
    attributes["ε_loss"] = process["ε_loss"]
  end

  if haskey(process, "approximation")
    attributes["approximation"] = process["approximation"]
  end

  if haskey(process, "scattering")
    attributes["scattering"] = process["scattering"]
  else
    attributes["scattering"] = scattering
  end

  return CrossSection(data, attributes)
end
end