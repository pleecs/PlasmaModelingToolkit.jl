module Grid
import ..Domains: AxisymmetricDomain
import ..Geometry: Shape, Segment

abstract type AbstractGrid end
struct AxisymmetricGrid{ZN, RN}
	z  :: Matrix{Float64}
    r  :: Matrix{Float64}
    dz :: Float64
    dr :: Float64
end

function discretize(domain::AxisymmetricDomain, nz, nr)
    zs = range(domain.zmin, domain.zmax, length=nz)
    rs = range(domain.rmin, domain.rmax, length=nr)
    dz = step(zs)
    dr = step(rs)
    z  = repeat(zs,  1, nr)
    r  = repeat(rs', nz, 1)
    return AxisymmetricGrid{nz, nr}(z, r, dz, dr)
end

function discretize!(node::Matrix{UInt8}, grid::AxisymmetricGrid{NZ, NR},
    shape::Shape, v::UInt8) where {NZ, NR}
    for j=1:NR, i=1:NZ
        if (grid.z[i,j], grid.r[i,j]) ∈ shape
            node[i,j] = v
        end
    end
end

function snap(node::Matrix{UInt8}, grid::AxisymmetricGrid{NZ, NR},
    segment::Segment{Z1, Z2, R1, R2}; extend=false) where {NZ, NR, Z1, Z2, R1, R2}
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
        if grid.z[C,A] ≉ Z1 || grid.r[C,A] ≉ R1 @warn "Inexact discretization ($Z1,$R1) discretized as ($(grid.r[C,A]), $(grid.z[C,A]))" end
        if grid.z[C,B] ≉ Z2 || grid.r[C,B] ≉ R2 @warn "Inexact discretization ($Z2,$R2) discretized as ($(grid.r[C,B]), $(grid.z[C,B]))" end

        id = node[C,A]
        for j=A:B, i=C
            if node[i,j] != id
                @error "Segment defined over nodes with multiple materials"
            end
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
        if grid.z[A,C] ≉ Z1 || grid.r[A,C] ≉ R1 @warn "Inexact discretization ($Z1,$R1) discretized as ($(grid.r[A,C]), $(grid.z[A,C]))" end
        if grid.z[B,C] ≉ Z2 || grid.r[B,C] ≉ R2 @warn "Inexact discretization ($Z2,$R2) discretized as ($(grid.r[B,C]), $(grid.z[B,C]))" end
        
        id = node[A,C]
        for j=A:B, i=C
            if node[i,j] != id
                @error "Segment defined over nodes with multiple materials"
            end
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
end