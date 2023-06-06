import ..Domains: Domain1D
import ..Geometry: Shape1D, Segment1D, Point1D

const Grid1D = Grid{1, :X} 
const OneDimensionalGrid = Grid{1, :X}

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

function snap_node(grid::Grid1D, p::Point1D)
  snap_node(grid, p.coords)
end

function snap_node(grid::Grid1D, p::NTuple{1, Float64})
  x, = p
  i  = round(Int64, x / grid.Δx - minimum(grid.x) / grid.Δx) + 1
  if grid.x[i] ≉ x
    @warn "Inexact discretization ($(x) discretized as $(grid.x[i]))"
  end
  return i
end