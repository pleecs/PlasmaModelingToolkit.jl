import ..Domains: AxisymmetricDomain
import ..Geometry: Shape2D, Segment2D

const AxisymmetricGrid = Grid{2,:ZR}

function discretize(domain::AxisymmetricDomain, nz, nr)
  zs = range(domain.zmin, domain.zmax, length=nz)
  rs = range(domain.rmin, domain.rmax, length=nr)
  dz = step(zs)
  dr = step(rs)
  z  = repeat(zs,  1, nr)
  r  = repeat(rs', nz, 1)
  return AxisymmetricGrid((z, r), (dz, dr), (nz, nr))
end

function discretize!(node::Matrix{UInt8}, grid::AxisymmetricGrid, shape::Shape2D, v::UInt8)
  NR = grid.nr
  NZ = grid.nz
  for j=1:NR, i=1:NZ
    if (grid.z[i,j], grid.r[i,j]) ∈ shape
      node[i,j] = v
    end
  end
end

function snap_node(grid::AxisymmetricGrid, p::NTuple{2, Float64})
  z, r = p
  i = round(Int64, z / grid.dz - minimum(grid.z) / grid.dz) + 1
  j = round(Int64, r / grid.dr - minimum(grid.r) / grid.dr) + 1
  if grid.z[i,j] ≉ z || grid.r[i,j] ≉ r
    @warn "Inexact discretization ($(z), $(r)) discretized as ($(grid.z[i,j]), $(grid.r[i,j]))"
  end
  return i, j
end

function snap_boundary(edge_boundary, grid::AxisymmetricGrid, p::NTuple{2, Float64})

  function sqdist(a::NTuple{2, Float64}, b::NTuple{2, Float64})
    za, ra = a
    zb, rb = b
    return (za - zb)^2 + (ra - rb)^2
  end

  z, r  = p
  i = round(Int64, z / grid.dz - minimum(grid.z) / grid.dz) + 1
  j = round(Int64, r / grid.dr - minimum(grid.r) / grid.dr) + 1
  
  ij = NTuple{2, Int64}[]
  d² = Float64[]

  nz, nr = size(edge_boundary)
  if nz < grid.nz # r-edge
    for (ei, ej) in ((i,j), (i-1,j), (i,j-1), (i-1,j-1), (i,j+1), (i-1,j+1))
      if 1 <= (ei) <= nz && 1 <= (ej) <= nr
        e = (grid.z[ei,ej] + grid.dz/2, grid.r[ei,ej])
        push!(ij, (ei,ej))
        push!(d², sqdist(p, e))
      end
    end
  end
  if nr < grid.nr # z-edge
    for (ei, ej) in ((i,j), (i,j-1), (i-1,j), (i-1,j-1), (i+1,j), (i+1,j-1))
      if 1 <= (ei) <= nz && 1 <= (ej) <= nr
        e = (grid.z[ei,ej], grid.r[ei,ej] + grid.dr/2)
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