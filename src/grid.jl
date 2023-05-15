module Grid
import ..Domains: AxisymmetricDomain
import ..Geometry: Shape2D, Segment2D

abstract type AbstractGrid{D} end

include("grids/zr.jl")
include("grids/1d.jl")

end