module Materials
import ..Constants: ε_0, μ_0

abstract type Material end
abstract type Medium{EPSILON, MU, SIGMA} <: Material end

struct Conductor <: Material end
struct Dielectric{EPSILON, MU, SIGMA} <: Medium{EPSILON, MU, SIGMA} end
struct PerfectlyMatchedLayer{EPSILON, MU, SIGMA} <: Medium{EPSILON, MU, SIGMA}
  dielectric :: Dielectric{EPSILON, MU, SIGMA}
  σ :: Float64
  m :: Int64
end

Metal()  = Conductor()
Vacuum() = Dielectric{ε_0, μ_0, 0.0}()
PTFE()   = Dielectric{2.04ε_0, μ_0, 0.0}()
Air()    = Dielectric{1.0006ε_0, μ_0, 0.0}()
end
