module Domains
export Patch, Segment
export AxisymmetricGrid

struct Patch{Z1, Z2, R1, R2} end
struct Segment{A, B, C, U, V} end

struct AxisymmetricGrid{ZN, RN}
    z  :: Matrix{Float64}
    r  :: Matrix{Float64}
    dz :: Float64
    dr :: Float64
    id :: Matrix{UInt8}
end

function AxisymmetricGrid(zs, rs)
    dr = step(rs)
    dz = step(zs)
    nz = length(zs)
    nr = length(rs)
    z  = repeat(zs,  1, nr)
    r  = repeat(rs', nz, 1)
    id = zeros(UInt8, nz, nr)
    AxisymmetricGrid{nz, nr}(z, r, dz, dr, id)
end

# TODO: add CartesianGrid
end