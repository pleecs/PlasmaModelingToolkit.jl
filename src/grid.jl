module Grids
import PlasmaModelingToolkit: ++
import Base: getproperty

struct Grid{D, CS}
  coords :: NTuple{D, Array{Float64,D}}
  Δs :: NTuple{D, Float64}
  n :: NTuple{D, Int64}
end

@generated function getproperty(grid::Grid{D,CS}, sym::Symbol) where {D,CS}
  coords = lowercase.(collect(string(CS)))

  code = Expr(:block)
  expr = Expr(:if)
  code ++ expr

  for (i, coord) in enumerate(coords)
    if i != 1
      expr ++ Expr(:elseif)
      expr = expr.args[end]
    end

    expr ++ :(sym === $(Expr(:quote, Symbol(coord))))
    expr ++ :(return grid.coords[$i])

    expr ++ Expr(:elseif)
    expr = expr.args[end]
    expr ++ :(sym === $(Expr(:quote, Symbol("n" * coord))))
    expr ++ :(return grid.n[$i])
    
    expr ++ Expr(:elseif)
    expr = expr.args[end]
    expr ++ :(sym === $(Expr(:quote, Symbol("Δ" * coord))))
    expr ++ :(return grid.Δs[$i])

    expr ++ Expr(:elseif)
    expr = expr.args[end]
    expr ++ :(sym === $(Expr(:quote, Symbol("d" * coord))))
    expr ++ :(return grid.Δs[$i])
  end

  expr ++ :(return getfield(grid, sym))

  return code
end

include("grids/zr.jl")
include("grids/1d.jl")

end