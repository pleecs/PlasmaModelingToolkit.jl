import PlasmaModelingToolkit.Domains: Domain2D
import PlasmaModelingToolkit.Models: FDMModel, PICModel
import PlasmaModelingToolkit.Problems: BoundaryValueProblem, ParticleProblem
import PlasmaModelingToolkit.BoundaryConditions: PeriodicBoundaryCondition
import PlasmaModelingToolkit.ParticleBoundaries: PeriodicBoundary
import PlasmaModelingToolkit.Distributions: UniformDistribution, MaxwellBoltzmannDistribution
import PlasmaModelingToolkit.Sources: ParticleLoader
import PlasmaModelingToolkit.Geometry: Segment2D, Rectangle
import PlasmaModelingToolkit.Materials: Vacuum
import PlasmaModelingToolkit.Species: electrons, ions
import PlasmaModelingToolkit.Units: cm, ns
import PlasmaModelingToolkit.Atoms: Helium
import PlasmaModelingToolkit.Constants: ε_0

W = 200cm
H = 50cm
NX = 200
NY = 50
domain = Domain2D(W, H, Vacuum())

bvp = BoundaryValueProblem(domain)
left = Segment2D(0.0, 0.0, 0.0, H)
right = Segment2D(W, 0.0, W, H)
top = Segment2D(0.0, H, W, H)
bottom = Segment2D(0.0, 0.0, W, 0.0)
whole = Rectangle(0.0, 0.0, W, H)

bvp[left] = PeriodicBoundaryCondition{:X}()
bvp[right] = PeriodicBoundaryCondition{:X}()
bvp[top] = PeriodicBoundaryCondition{:Y}()
bvp[bottom] = PeriodicBoundaryCondition{:Y}()

fdm = FDMModel(bvp, NX, NY)

e   = electrons()
iHe = ions(Helium)

n_e = 4.5e9
M_s = 2.197265625e6
N_s = n_e * W * H / M_s
ν_d = 5e5

part = ParticleProblem(domain, e, iHe)

part[left] = PeriodicBoundary{:X}()
part[right] = PeriodicBoundary{:X}()

part[whole] = ParticleLoader(e, Int(.5N_s), UniformDistribution(); drift=[:x => +ν_d])
part[whole] = ParticleLoader(e, Int(.5N_s), UniformDistribution(); drift=[:x => -ν_d])
part[whole] = ParticleLoader(iHe, Int(N_s), UniformDistribution(); drift=[:x => 0.0])