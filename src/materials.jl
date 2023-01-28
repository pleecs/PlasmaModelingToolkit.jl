module Materials
import ..Constants: ε_0, μ_0

abstract type Medium{EPSILON, MU, SIGMA} end

struct Conductor end
struct Dielectric{EPSILON, MU, SIGMA} <: Medium{EPSILON, MU, SIGMA} 
  id :: UInt8
end

import Base: convert
convert(::Type{UInt8}, d::Dielectric) = d.id
convert(::Type{UInt8}, c::Conductor)  = 0x00

Metal  = Conductor()
Vacuum = Dielectric{ε_0, μ_0, 0.0}(0xff)
PTFE   = Dielectric{2.04ε_0, μ_0, 0.0}(0xfe)
Air    = Dielectric{1.0006ε_0, μ_0, 0.0}(0xae)

struct PerfectlyMatchedLayer{EPSILON, MU} <: Medium{EPSILON, MU, 0.0} 
  id :: UInt8
   σ :: Float64
   m :: Int64
end
end