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

bvp[left] = PeriodicBoundaryCondition()
bvp[right] = PeriodicBoundaryCondition()
bvp[top] = PeriodicBoundaryCondition()
bvp[bottom] = PeriodicBoundaryCondition()


fdm = FDMModel(bvp, NX, NY)