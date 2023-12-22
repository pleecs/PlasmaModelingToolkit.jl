module Materials
import ..Constants: ε_0, μ_0

abstract type Material end
abstract type Conductor <: Material end
abstract type Medium{EPSILON, MU, SIGMA} <: Material end

struct IdealConductor <: Conductor end
struct LossyConductor{MU, SIGMA} <: Conductor end
struct Dielectric{EPSILON, MU, SIGMA} <: Medium{EPSILON, MU, SIGMA} end
struct PerfectlyMatchedLayer{EPSILON, MU, SIGMA} <: Medium{EPSILON, MU, SIGMA}
  dielectric :: Dielectric{EPSILON, MU, SIGMA}
  σ :: Float64
  m :: Int64
end

Metal()  = IdealConductor()
Copper() = LossyConductor{μ_0, 5.80e7}()
Vacuum() = Dielectric{ε_0, μ_0, 0.0}()
PTFE()   = Dielectric{2.04ε_0, μ_0, 0.0}()
Air()    = Dielectric{1.0006ε_0, μ_0, 0.0}()

permittivity(::Medium{EPSILON, MU, SIGMA}) where {EPSILON, MU, SIGMA} = EPSILON
conductivity(::Medium{EPSILON, MU, SIGMA}) where {EPSILON, MU, SIGMA} = SIGMA
permeability(::Medium{EPSILON, MU, SIGMA}) where {EPSILON, MU, SIGMA} = MU

skindepth(frequency, ::IdealConductor) = 0.0
skindepth(frequency, ::LossyConductor{MU, SIGMA}) where {MU, SIGMA} = sqrt(1 / MU / SIGMA / π) / sqrt(frequency)
end
