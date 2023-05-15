module Domains
	import ..Geometry: Shape2D, Rectangle, Segment2D, Segment1D
	import ..Materials: Material
	export AxisymmetricDomain
	import Base: ∈, setindex!

	abstract type AbstractDomain end

	include("domains/zr.jl")

end