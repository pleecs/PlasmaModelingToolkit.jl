module Domains
import ..Geometry: Shape, Segment
import ..Materials: Material
import PlasmaModelingToolkit: ++
import Base: getproperty

struct Domain{D, CS}
  mins :: NTuple{D, Float64}
  maxs :: NTuple{D, Float64}
  materials :: Vector{Pair{Shape{D}, Material}}
end

@generated function getproperty(domain::Domain{D, CS}, sym::Symbol) where {D, CS}
  coords = lowercase.(collect(string(CS)))

  code = Expr(:block)
  expr = Expr(:if)
  code ++ expr

  for (i, coord) in enumerate(coords)
    if i != 1
      expr ++ Expr(:elseif)
      expr = expr.args[end]
    end

    expr ++ :(sym === $(Expr(:quote, Symbol(coord * "min"))))
    expr ++ :(return domain.mins[$i])

    expr ++ Expr(:elseif)
    expr = expr.args[end]
    expr ++ :(sym === $(Expr(:quote, Symbol(coord * "max"))))
    expr ++ :(return domain.maxs[$i])
  end

  expr ++ :(return getfield(domain, sym))

  return code
end

≲(a::Number, b::Number) = (a < b || a ≈ b) 

function isboundary(domain::Domain{D}, segment::Segment{D}) where D
  p₁, p₂ = segment.p₁, segment.p₂

  on_boundary = false

  for dim₁ in 1:D
    min_val = domain.mins[dim₁]
    max_val = domain.maxs[dim₁]

    if(p₁[dim₁] == min_val && p₂[dim₁] == min_val) || (p₁[dim₁] == max_val && p₂[dim₁] == max_val)
      on_boundary = true
      for dim₂ in 1:D
        if dim₂ == dim₁
          continue
        end

        if !(domain.mins[dim₂] ≲ p₁[dim₂] ≲ domain.maxs[dim₂] && domain.mins[dim₂] ≲ p₂[dim₂] ≲ domain.maxs[dim₂])
          on_boundary = false
          break
        end
      end
    end
  end
  return on_boundary
end


include("domains/zr.jl")
include("domains/1d.jl")
include("domains/2d.jl")
end