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

function snap(node::Matrix{UInt8}, grid::AxisymmetricGrid, segment::Segment2D; extend=false)
  Z1, R1 = segment.p₁
  Z2, R2 = segment.p₂
  NZ = grid.nz
  NR = grid.nr

  if Z1 ≈ Z2
    ε, z = modf(Z1 / grid.dz - minimum(grid.z) / grid.dz)
    i₁ = i₂ = Int(z) + 1

    ε₁, r₁ = modf(R1 / grid.dr - minimum(grid.r) / grid.dr)
    j₁ = Int(r₁) + 1
    ε₂, r₂ = modf(R2 / grid.dr - minimum(grid.r) / grid.dr)
    j₂ = Int(r₂) + 1

    A = min(j₁, j₂)
    B = max(j₁, j₂)
    C = i₁

    if grid.z[C,A] ≉ min(Z1,Z2) || grid.r[C,A] ≉ min(R1,R2)
      @warn "Inexact discretization ($(min(Z1,Z2)),$(min(R1,R2)) discretized as ($(grid.z[C,A]), $(grid.r[C,A]))"
    end
    
    if grid.z[C,B] ≉ max(Z1,Z2) || grid.r[C,B] ≉ max(R1,R2)
      @warn "Inexact discretization ($(max(Z1,Z2)),$(max(R1,R2)) discretized as ($(grid.z[C,B]), $(grid.r[C,B]))"
    end

    if extend && A > 1 && node[C,A-1] < node[C,A]
      A += 1
    end
    if extend && B < NR && node[C,B+1] < node[C,B]
      B += 1
    end
    
    return C:C, A:B
  else
    ε, r = modf(R1 / grid.dr - minimum(grid.r) / grid.dr)
    j₁ = j₂ = Int(r) + 1

    ε₁, z₁ = modf(Z1 / grid.dz - minimum(grid.z) / grid.dz)
    i₁ = Int(z₁) + 1
    ε₂, z₂ = modf(Z2 / grid.dz - minimum(grid.z) / grid.dz)
    i₂ = Int(z₂) + 1

    A = min(i₁, i₂)
    B = max(i₁, i₂)
    C = j₁
    
    if grid.z[A,C] ≉ min(Z1,Z2) || grid.r[A,C] ≉ min(R1,R2)
      @warn "Inexact discretization ($(min(Z1,Z2)),$(min(R1,R2))) discretized as ($(grid.z[A,C]), $(grid.r[A,C]))"
    end
    
    if grid.z[B,C] ≉ max(Z1,Z2) || grid.r[B,C] ≉ max(R1,R2)
      @warn "Inexact discretization ($(max(Z1,Z2)),$(max(R1,R2)) discretized as ($(grid.z[B,C]), $(grid.r[B,C]))"
    end
    
    if extend && A > 1 && node[A-1,C] < node[A,C]
      A += 1
    end
    if extend && B < NZ && node[B+1,C] < node[B,C]
      B += 1
    end

    return A:B, C:C
  end
end