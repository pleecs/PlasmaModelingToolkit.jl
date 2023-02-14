module Geometry
export Rectangle, Circle, Segment, Polygon
import Base: +, -, ∈
import LinearAlgebra: norm, ⋅

const mm = 1e-3 # unit conversion ratio [mm/m]
const cm = 1e-2 # unit conversion ratio [cm/m]

abstract type Shape end

# by default Segment has its normal vector oriented to the left 
struct Segment{X1, Y1, X2, Y2} <: Shape end 				
struct Rectangle{X, Y, W, H} <: Shape end
struct Circle{X, Y, R} <: Shape end
struct CompositeShape{OPERATOR, A, B}  <: Shape end
struct Polygon{N} <: Shape
	segments :: NTuple{N, Segment}
end
struct Ray
	origin :: NTuple{2, Float64}
	direction :: NTuple{2, Float64}
end

function Polygon(nodes::Vector{NTuple{2, Float64}})
	segments = Vector{Segment}()
	for i=1:(length(nodes) - 1)
		push!(segments, Segment{nodes[i]..., nodes[i+1]...}())
	end
	push!(segments, Segment{nodes[end]..., nodes[1]...}())
	return Polygon{length(segments)}(Tuple(segments))
end
	
function ∈((x, y), ::Rectangle{X, Y, W, H}) where {X, Y, W, H}
	if X <= x <= X + W
		if Y <= y <= Y + H
			return true
		end
	end

	return false
end

function ∈((x, y), ::Circle{X, Y, R}) where {X, Y, R}
	r² = (x - X)^2 + (y - Y)^2
	if r² <= R^2
	return true
	end

	return false
end

function ∈((x, y), polygon::Polygon{N}) where {N}
	θ = 2π * rand() 
	ray = Ray((x,y),(sin(θ),cos(θ)))
	n_crossings = 0
	for segment in polygon.segments
		if ray ∩ segment
			n_crossings += 1
		end
	end
	@info "$n_crossings"
	@info "$ray"
	return (n_crossings % 2) == 1
end

×(v1::Tuple{Float64,Float64}, v2::Tuple{Float64,Float64}) = v1[1] * v2[2] - v1[2] * v2[1]

function ∩(ray::Ray, segment::Segment{X1, Y1, X2, Y2}) where {X1, Y1, X2, Y2}
	a = (X1, Y1)
	b = (X2, Y2)

	v₁ = ray.origin .- a
	v₂ = b .- a
	v₃ = ray.direction .* (-1, 1)

	t₁ = norm(v₂ × v₁) ./ (v₂ ⋅ v₃)
	t₂ = (v₁ ⋅ v₃) ./ (v₂ ⋅ v₃)

	return (t₁ >= 0) && (0 <= t₂ <= 1)
end

+(A::Shape, B::Shape) = CompositeShape{+, A, B}()
-(A::Shape, B::Shape) = CompositeShape{-, A, B}()

∈(p, ::CompositeShape{+, A, B}) where {A, B} = ∈(p, A) ||  ∈(p, B)
∈(p, ::CompositeShape{-, A, B}) where {A, B} = ∈(p, A) && !∈(p, B)
end