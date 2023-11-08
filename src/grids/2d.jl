import ..Domains: Domain2D
import ..Geometry: Shape2D, Segment2D

const Grid2D = Grid{2,:XY}

function discretize(domain::Domain2D, nx, ny)
  xs = range(domain.xmin, domain.xmax, length=nx)
  ys = range(domain.ymin, domain.ymax, length=ny)
  Δx = step(xs)
  Δy = step(ys)
  x  = repeat(xs,  1, ny)
  y  = repeat(ys', nx, 1)
  return Grid2D((x, y), (Δx, Δy), (nx, ny))
end

function discretize!(node::Matrix{UInt8}, grid::Grid2D, shape::Shape2D, v::UInt8)
  NX = grid.nx
  NY = grid.ny
  for j=1:NY, i=1:NX
    if (grid.x[i,j], grid.y[i,j]) ∈ shape
      node[i,j] = v
    end
  end
end

function snap_node(grid::Grid2D, p::NTuple{2, Float64})
  x, y = p
  i = round(Int64, x / grid.dx - minimum(grid.x) / grid.dx) + 1
  j = round(Int64, y / grid.dy - minimum(grid.y) / grid.dy) + 1
  if grid.x[i,j] ≉ x || grid.y[i,j] ≉ y
    @warn "Inexact discretization ($(x), $(y)) discretized as ($(grid.x[i,j]), $(grid.y[i,j]))"
  end
  return i, j
end

function snap_boundary(edge_boundary, grid::Grid2D, p::NTuple{2, Float64})

  function sqdist(a::NTuple{2, Float64}, b::NTuple{2, Float64})
    xa, ya = a
    xb, yb = b
    return (xa - xb)^2 + (ya - yb)^2
  end

  x, y  = p
  i = round(Int64, x / grid.dx - minimum(grid.x) / grid.dx) + 1
  j = round(Int64, y / grid.dy - minimum(grid.y) / grid.dy) + 1
  
  ij = NTuple{2, Int64}[]
  d² = Float64[]

  nx, ny = size(edge_boundary)
  if nx < grid.nx # y-edge
    for (ei, ej) in ((i,j), (i-1,j), (i,j-1), (i-1,j-1), (i,j+1), (i-1,j+1))
      if 1 <= (ei) <= nx && 1 <= (ej) <= ny
        e = (grid.x[ei,ej] + grid.dx/2, grid.y[ei,ej])
        push!(ij, (ei,ej))
        push!(d², sqdist(p, e))
      end
    end
  end
  if ny < grid.ny # x-edge
    for (ei, ej) in ((i,j), (i,j-1), (i-1,j), (i-1,j-1), (i+1,j), (i+1,j-1))
      if 1 <= (ei) <= nx && 1 <= (ej) <= ny
        e = (grid.x[ei,ej], grid.y[ei,ej] + grid.dy/2)
        push!(ij, (ei,ej))
        push!(d², sqdist(p, e))
      end
    end
  end
  
  order = sortperm(d²)
  for k in order
    i, j = ij[k]
    if edge_boundary[i, j] > 0x00
      return i, j
    end
  end

  if length(order) > 0
    closest = first(order)
    return ij[closest]
  else
    return (0, 0)
  end
end