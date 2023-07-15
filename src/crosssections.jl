module CrossSections
import ..Species: Particles, Fluid
import JLD2: load

struct CrossSection{DT}
  data :: DT
end

function resample(data::Matrix{Float64}, n=1000, Δε=nothing, min=nothing, max=nothing)
  min = isnothing(min) ? min(data[:,1]) : min
  max = isnothing(max) ? max(data[:,1]) : max

  interp = LinearInterpolation(data[:,1], data[:,2], extrapolation_bc=Flat())
  ε = collect(isnothing(Δε) ? range(min, max, length=n) : range(min, max, step=Δε))
  σ = broadcast(interp, ε)
  return hcat(ε, σ)
end

process_name(particles::Symbol, gas::Symbol, process::Symbol, ε::Nothing) = join(string.([particles, gas, process]),"_")
process_name(particles::Symbol, gas::Symbol, process::Symbol, ε::Float64) = join(string.([particles, gas, process]),"_") * "_" * replace(string(ε), "." => "_") * "eV"
dataset_name(dataset::Symbol) = string(dataset) * ".jld2"

function CrossSection(dataset::Symbol, process::Symbol, particles::Particles{PARTICLES}, gas::Fluid{FLUID}, ε) where {PARTICLES, FLUID}
  σ = load("data/" * dataset_name(dataset), process_name(PARTICLES, FLUID, process, ε))
  return CrossSection(σ)
end

CrossSection(dataset_name::String, process_name::String) = CrossSection(load(dataset_name, process_name))
end