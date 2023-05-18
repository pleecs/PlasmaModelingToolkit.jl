module Geometry
export Rectangle, Circle, Segment2D, Polygon
import Base: +, -, ∈, ∩

abstract type Shape{D} end
const Shape1D = Shape{1}
const Shape2D = Shape{2}

struct Segment{D} <: Shape{D}
	p₁ :: NTuple{D, Float64}
	p₂ :: NTuple{D, Float64}
end

const Segment1D = Segment{1}
const Segment2D = Segment{2}
Segment1D(x₁::Float64, x₂::Float64) = Segment(tuple(x₁), tuple(x₂))
Segment2D(x₁, y₁, x₂, y₂) = Segment(tuple(float(x₁),float(y₁)), tuple(float(x₂),float(y₂)))

struct Point{D} <: Shape{D}
	coords :: NTuple{D, Float64}
end

const Point1D = Point{1}
Point1D(x::Float64) = Point(tuple(x))
			
struct Rectangle <: Shape2D 
	origin :: Tuple{Float64, Float64}
	width  :: Float64
	height :: Float64
end
Rectangle(x, y, w, h) = Rectangle((x, y), w, h)

struct Circle <: Shape2D 
	origin :: Tuple{Float64, Float64}
	radius :: Float64
end
Circle(x, y, r) = Circle((x, y), r)

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
		push!(segments, Segment2D(nodes[i]..., nodes[i+1]...))
	end
	push!(segments, Segment2D(nodes[end]..., nodes[1]...))
	return Polygon{length(segments)}(Tuple(segments))
end

struct Ray{D}
	origin :: NTuple{D, Float64}
	direction :: NTuple{D, Float64}
end

const Ray2D = Ray{2}
	
function ∈((x, y), rectangle::Rectangle)
	X, Y = rectangle.origin
	W = rectangle.width
	H = rectangle.height

	if (X <= x <= X + W) && (Y <= y <= Y + H)
		return true
	end
	return false
end

function ∈((x, y), circle::Circle)
	X, Y = circle.origin
	R = circle.radius

	r² = (x - X)^2 + (y - Y)^2
	if r² <= R^2
		return true
	end
	return false
end

function ∈((x, y), segment::Segment2D)
	x₁, y₁ = segment.p₁
	x₂, y₂ = segment.p₂
	d₁ = sqrt((x - x₁)^2 + (y - y₁)^2)
	d₂ = sqrt((x - x₂)^2 + (y - y₂)^2)
	d₃ = sqrt((x₁ - x₂)^2 + (y₁ - y₂)^2)
	return d₁ + d₂ ≈ d₃
end

function ∈((x,), segment::Segment1D)
	x₁, = segment.p₁
	x₂, = segment.p₂
	return min(x₁,x₂) <= x <= max(x₁,x₂)
end

function ∈((x, y), polygon::Polygon{N}) where {N}
	if any(s->((x,y) ∈ s), polygon.segments)
		return true
	end

	# θ = 2π * rand() 
	# d_x = sin(θ)/(sqrt(sin(θ)^2 + cos(θ)^2))
	# d_y = cos(θ)/(sqrt(sin(θ)^2 + cos(θ)^2))
	# ray = Ray((x,y),(d_x, d_y))

	ray = Ray((x,y),(1., 0.))

	n_crossings = 0
	for segment in polygon.segments
		if ∩(ray, segment, exclude_endpoints=(true,false))
			n_crossings += 1
		end
	end

	return (n_crossings % 2) == 1
end

×(v₁::Tuple{Float64,Float64}, v₂::Tuple{Float64,Float64}) = v₁[1] * v₂[2] - v₁[2] * v₂[1]
⋅(v₁::Tuple{Float64,Float64}, v₂::Tuple{Float64,Float64}) = v₁[1] * v₂[1] + v₁[2] * v₂[2]

function ∩(ray::Ray2D, segment::Segment2D; exclude_endpoints=(false, false))
	a = segment.p₁
	b = segment.p₂

	v₁ = ray.origin .- a
	v₂ = b .- a
	v₃ = reverse(ray.direction) .* (-1, 1)

	v₂v₃ = v₂ ⋅ v₃
	
	if v₂v₃ ≈ 0.0 return false end

	t₁ = (v₂ × v₁) / (v₂v₃)
	t₂ = (v₁ ⋅ v₃) / (v₂v₃)

	P = ray.origin .+ ray.direction .* t₁

	if (exclude_endpoints[1] && all(P .≈ a)) || (exclude_endpoints[2] && all(P .≈ b))
		return false
	end 

	return (t₁ >= 0) && (0 <= t₂ <= 1) 
end

+(A::Shape2D, B::Shape2D) = CompositeShape{+}(A, B)
-(A::Shape2D, B::Shape2D) = CompositeShape{-}(A, B)

∈(p, shape::CompositeShape{+}) = ∈(p, shape.A) ||  ∈(p, shape.B)
∈(p, shape::CompositeShape{-}) = ∈(p, shape.A) && !∈(p, shape.B)
end