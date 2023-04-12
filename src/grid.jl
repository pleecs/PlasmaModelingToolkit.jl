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

function discretize!(m::Matrix{UInt8}, grid::AxisymmetricGrid{NZ, NR}, shape::Shape, v::UInt8) where {NZ, NR}
    for j=1:NR, i=1:NZ
        if (grid.z[i,j], grid.r[i,j]) ∈ shape
            m[i,j] = v
        end
    end
end

function discretize(m::Matrix{UInt8}, grid::AxisymmetricGrid{NZ, NR},
    segment::Segment{Z1, Z2, R1, R2}, v::UInt8) where {NZ, NR, Z1, Z2, R1, R2}
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
        for j=A:B, i=C
            m[i,j] = v
        end
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
        for j=C, i=A:B
            m[i,j] = v
        end
    end

    if !(ε ≈ 0) || !(ε₁ ≈ 0) || !(ε₂ ≈ 0)
        @warn """Inexact discretization of a Segment{$Z1, $R1, $Z2, $R2} to Edges!
        ($Z1, $R1) discretized to ($(grid.z[i₁, j₁]), $(grid.r[i₁, j₁]))
        ($Z2, $R2) discretized to ($(grid.z[i₂, j₂]), $(grid.r[i₂, j₂]))
        """
    end
end
end