module Geometry
export Rectangle, Circle, Segment2D, Polygon
import Base: +, -, ∈, ∩

const mm = 1e-3 # unit conversion ratio [mm/m]
const cm = 1e-2 # unit conversion ratio [cm/m]

abstract type Shape2D end

struct Segment1D{X1, X2} <: Shape2D end 	
struct Segment2D{X1, Y1, X2, Y2} <: Shape2D end # by default Segment2D has its normal vector oriented to the left  				
struct Rectangle{X, Y, W, H} <: Shape2D end
struct Circle{X, Y, R} <: Shape2D end
struct CompositeShape{OPERATOR}  <: Shape2D
	A :: Shape2D
	B :: Shape2D 
end
struct Polygon{N} <: Shape2D
	segments :: NTuple{N, Segment2D}
end

function Polygon(nodes::Vector{NTuple{2, Float64}})
	segments = Vector{Segment2D}()
	for i=1:(length(nodes) - 1)
		push!(segments, Segment2D{nodes[i]..., nodes[i+1]...}())
	end
	push!(segments, Segment2D{nodes[end]..., nodes[1]...}())
	return Polygon{length(segments)}(Tuple(segments))
end

struct Ray
	origin :: NTuple{2, Float64}
	direction :: NTuple{2, Float64}
end
	
function ∈((x, y), ::Rectangle{X, Y, W, H}) where {X, Y, W, H}
	if (X <= x <= X + W) && (Y <= y <= Y + H)
		return true
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

function ∈((x, y), ::Segment2D{X1, Y1, X2, Y2}) where {X1, Y1, X2, Y2}
	d₁ = sqrt((x - X1)^2 + (y - Y1)^2)
	d₂ = sqrt((x - X2)^2 + (y - Y2)^2)
	d₃ = sqrt((X1 - X2)^2 + (Y1 - Y2)^2)
	return d₁ + d₂ ≈ d₃
end

function ∈(x, ::Segment1D{X1, X2}) where {X1, X2}
	return min(X1,X2) <= x <= max(X1,X2)
end

function ∈((x, y), polygon::Polygon{N}) where {N}

	if any(s->((x,y) ∈ s), polygon.segments)
		return true
	end

	# θ = 2π * rand() 
	# d_x = sin(θ)/(sqrt(sin(θ)^2 + cos(θ)^2))
	# d_y = cos(θ)/(sqrt(sin(θ)^2 + cos(θ)^2))
	# ray = Ray((x,y),(d_x, d_y))

	ray = Ray((x,y),(1., 1.)) # diagonal ray

	n_crossings = 0
	for segment in polygon.segments
		if ray ∩ segment
			n_crossings += 1
		end
	end

	return (n_crossings % 2) == 1
end

×(v₁::Tuple{Float64,Float64}, v₂::Tuple{Float64,Float64}) = v₁[1] * v₂[2] - v₁[2] * v₂[1]
⋅(v₁::Tuple{Float64,Float64}, v₂::Tuple{Float64,Float64}) = v₁[1] * v₂[1] + v₁[2] * v₂[2]

function ∩(ray::Ray, segment::Segment2D{X1, Y1, X2, Y2}) where {X1, Y1, X2, Y2}
	a = (X1, Y1)
	b = (X2, Y2)

	v₁ = ray.origin .- a
	v₂ = b .- a
	v₃ = reverse(ray.direction) .* (-1, 1)

	v₂v₃ = v₂ ⋅ v₃
	
	if v₂v₃ ≈ 0.0 return false end

	t₁ = (v₂ × v₁) / (v₂v₃)
	t₂ = (v₁ ⋅ v₃) / (v₂v₃)

	return (t₁ >= 0) && (0 <= t₂ <= 1)
end

+(A::Shape2D, B::Shape2D) = CompositeShape{+}(A, B)
-(A::Shape2D, B::Shape2D) = CompositeShape{-}(A, B)

∈(p, shape::CompositeShape{+}) = ∈(p, shape.A) ||  ∈(p, shape.B)
∈(p, shape::CompositeShape{-}) = ∈(p, shape.A) && !∈(p, shape.B)
end