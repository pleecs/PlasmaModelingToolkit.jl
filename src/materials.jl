module Materials
import ..Constants: ε_0, μ_0

abstract type Material end
abstract type Medium{EPSILON, MU, SIGMA} <: Material end

struct Conductor <: Material end
struct Dielectric{EPSILON, MU, SIGMA} <: Medium{EPSILON, MU, SIGMA} 
  id :: UInt8
end
struct PerfectlyMatchedLayer{EPSILON, MU, 0.0} <: Medium{EPSILON, MU}
  dielectric :: Dielectric{EPSILON, MU, 0.0}
  σ :: Float64
  m :: Int64
end

import Base: convert
convert(::Type{UInt8}, d::Dielectric) = d.id
convert(::Type{UInt8}, c::Conductor)  = 0x00
convert(::Type{UInt8}, p::PerfectlyMatchedLayer) where T =
  convert(UInt8, p.dielectric)

Metal()  = Conductor()
Vacuum() = Dielectric{ε_0, μ_0, 0.0}(0xff)
PTFE()   = Dielectric{2.04ε_0, μ_0, 0.0}(0xfe)
Air()    = Dielectric{1.0006ε_0, μ_0, 0.0}(0xae)
end
