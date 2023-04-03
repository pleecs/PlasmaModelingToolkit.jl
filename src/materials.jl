module Materials
import ..Constants: ε_0, μ_0

abstract type Material end
abstract type Medium{EPSILON, MU, SIGMA} <: Material end

struct Conductor <: Material end
struct Dielectric{EPSILON, MU, SIGMA} <: Medium{EPSILON, MU, SIGMA} 
  id :: UInt8
end
struct PerfectlyMatchedLayer{EPSILON, MU, SIGMA} <: Medium{EPSILON, MU, SIGMA}
  dielectric :: Dielectric{EPSILON, MU, SIGMA}
  σ :: Float64
  m :: Int64
end

import Base: convert
convert(::Type{UInt8}, d::Dielectric) = d.id
convert(::Type{UInt8}, c::Conductor)  = 0x00
convert(::Type{UInt8}, p::PerfectlyMatchedLayer) = 0x80 + (p.dielectric.id)

Metal()  = Conductor()
Vacuum() = Dielectric{ε_0, μ_0, 0.0}(0x01)
PTFE()   = Dielectric{2.04ε_0, μ_0, 0.0}(0x02)
Air()    = Dielectric{1.0006ε_0, μ_0, 0.0}(0x03)
end
