module Domains
	import ..Geometry: Shape2D, Rectangle, Segment2D, Segment1D, Shape, Shape1D
	import ..Materials: Material
	import PlasmaModelingToolkit: ++
	import Base: ∈, setindex!, getproperty

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

	include("domains/zr.jl")
	include("domains/1d.jl")

end