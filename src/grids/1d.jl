import ..Domains: Domain1D
import ..Geometry: Shape1D, Segment1D, Point1D

const Grid1D = Grid{1, :X} 

function discretize(domain::Domain1D, nx)
  zx = range(domain.xmin, domain.xmax, length=nx)
  dx = step(zx)
  x = collect(zx)
  return Grid1D(tuple(x), tuple(dx), tuple(nx))
end

function discretize!(node::Vector{UInt8}, grid::Grid1D, shape::Shape1D, v::UInt8)
  nx = grid.nx
  x, = grid.x
  for i=1:nx
    if (x,) ∈ shape
      node[i] = v
    end
  end
end

function snap(node::Vector{UInt8}, grid::Grid1D, segment::Segment1D)
  x₁, = segment.p₁
  x₂, = segment.p₂
  Δx, = grid.Δs

  ε₁, i₁ = modf(x₁ / Δx - minimum(grid.coords) / Δx)
  i₁ = Int(i₁) + 1

  ε₂, i₂ = modf(x₂ / Δx - minimum(grid.coords) / Δx)
  i₂ = Int(i₂) + 1

  A = min(i₁, i₂)
  B = max(i₁, i₂)

  if ε₁ ≉ 0.0 || ε₂ ≉ 0.0
    @warn "Inexact discretization ($(min(x₁, x₂)),$(max(x₁, x₂)) discretized as ($(grid.coords[A]), $(grid.coords[B]))"
  end

  return A:B
end

function snap(node::Vector{UInt8}, grid::Grid1D, point::Point1D)
  x₁, = point.coords
  x = grid.x
  Δx = grid.Δx

  ε, i = modf(x₁ / Δx - minimum(x) / Δx)
  A = Int(i) + 1

  if ε ≉ 0.0
    @warn "Inexact discretization ($(x) discretized as $(grid.x[A]))"
  end

  return A
end