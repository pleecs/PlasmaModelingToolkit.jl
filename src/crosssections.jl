module CrossSections
import ..Species: Particles, Fluid
import JLD2: load
import DelimitedFiles: readdlm
import PlasmaModelingToolkit


abstract type AbstractCrossSections end
struct Biagi{SYM} <: AbstractCrossSections end
Biagi(sym::Symbol) = Biagi{sym}()

Biagi(;version) = load("$(pkgdir(PlasmaModelingToolkit))/data/Biagi-$(string(version)).jld2")
Phelps() = load("$(pkgdir(PlasmaModelingToolkit))/data/Phelps.jld2")

function lxcatread(path::String, name::String)
  data = Dict()
  f = open(path, "r")
  
  while true
    # read raw
    _ = readuntil(f, "SPECIES: ")
    species = readuntil(f, "\n")
    _ = readuntil(f, "PROCESS: ")
    process = readuntil(f, "\n")
    _ = readuntil(f, "PARAM.: ")
    params = readuntil(f, "\n")
    _ = readuntil(f, "-----------------------------")
    σ = readuntil(f, "-----------------------------")

    if eof(f)
      break
    end

    # postprocess
    row = Dict{String, Any}()

    m = match(r"(?P<participants>[a-zA-Z\+ ]+) -> (?P<products>[a-zA-Z0-9\(\)\.\+\* ]+)?, (?P<process>[a-zA-Z]+)", process)
    @assert !isnothing(m) "Error while parsing LXCat file: Could not parse process description ($(process)) in $(name) dataset"
    process = Symbol(m[:process])
    if process == :Backscat
      process = :Elastic
      row["scattering"] = :Backward
    elseif process == :Isotropic
      process = :Elastic
      row["scattering"] = :Isotropic
    end    
    products = m[:products]

    m = match(r"(?P<source>[a-zA-Z]+)(?P<ision>(\^\+)?) / (?P<target>[a-zA-Z]+)", species)
    @assert !isnothing(m) "Error while parsing LXCat file: Could not parse species description ($(species)) for $(string(process)) collision in $(name) dataset"
    if isempty(m[:ision])
      source = Symbol(m[:source])
    else
      source = Symbol("i" * m[:source])
    end
    target = Symbol(m[:target]) 
    
    if process == :Excitation
      m = match(r"(?P<source>[a-zA-Z]+) \+ (?P<target>[a-zA-Z]+)(\()?(?P<state>([a-zA-Z0-9]+|\*))(\))?", products)
      @assert !isnothing(m) "Error while parsing LXCat file: Could not parse process products description ($(products)) for $(string(process)) collision in $(name) dataset"
      row["excited_state"] = m[:state]
    end

    if process == :Excitation || process == :Ionization
      m = match(r"E = (?P<energy>[0-9\.]+)", params)
      @assert !isnothing(m) "Error while parsing LXCat file: Could not parse params description ($(params)) for $(string(process)) collision in $(name) dataset"
      row["ε_loss"] = parse(Float64, m[:energy])
    end

    σ = readdlm(IOBuffer(σ))
    row["data"] = σ

    # fillup
    if !haskey(data,                 source)  data[source] = Dict() end
    if !haskey(data[source],         target)  data[source][target] = Dict() end
    if !haskey(data[source][target], process) data[source][target][process] = Vector() end

    push!(data[source][target][process], row)
    @debug "Parsed $(string(source)) -> $(string(target)) process: $(string(process))"
  end
  return Dict{String, typeof(data)}(name => data)
end

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


function CrossSection(dataset, type::Symbol, source::Particles{SOURCE}, target::Fluid{TARGET}; ε_loss=nothing, scattering=nothing, excited_state=nothing) where {SOURCE, TARGET}
  dataset_name = first(keys(dataset))

  processes = dataset[dataset_name][SOURCE][TARGET][type]
  
  if !isnothing(ε_loss)
    filter!(process->process["ε_loss"] == ε_loss, processes)
    @assert length(processes) > 0 "In $(dataset_name) dataset there is no data for $(string(type)) collision between $(string(source)) and $(string(target)) with specified energy level ($ε_loss)"
  end


  if !isnothing(excited_state)
    filter!(process->process["excited_state"] == excited_state, processes)
    @assert length(processes) > 0 "In $(dataset_name) dataset there is no data for $(string(type)) collision between $(string(source)) and $(string(target)) with specified excited state ($excited_state)"
  end

  
  if !isnothing(scattering)
    specified = filter(process->haskey(process, "scattering"), processes)
    filter!(process->process["scattering"] == scattering, specified)

    if length(specified) == 0
      filter!(process->!haskey(process,"scattering"), processes)
    else
      processes = specified
    end
    @assert length(processes) > 0 "In $(dataset_name) dataset there is no data for $(string(type)) collision between $(string(source)) and $(string(target)) with specified scattering type ($scattering) (nor universal one)"
  end

  @assert length(processes) == 1 "In $(dataset_name) dataset there more than one entry for $(string(type)) collision with specified attributes, please provide more information"

  process = first(processes)
  data = process["data"]
  attributes = Dict{String, Any}()

  if haskey(process, "ε_loss")
    attributes["ε_loss"] = process["ε_loss"]
  end

  if haskey(process, "excited_state")
    attributes["excited_state"] = process["excited_state"]
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