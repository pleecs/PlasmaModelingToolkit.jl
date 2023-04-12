module Grid
abstract type AbstractGrid end
struct AxisymmetricGrid{ZN, RN}
	z  :: Matrix{Float64}
    r  :: Matrix{Float64}
    dz :: Float64
    dr :: Float64
end
end