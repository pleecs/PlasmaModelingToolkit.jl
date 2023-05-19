import PlasmaModelingToolkit.Materials: Vacuum
import PlasmaModelingToolkit.Domains: AxisymmetricDomain
import PlasmaModelingToolkit.Geometry: Segment2D, Rectangle
import PlasmaModelingToolkit.BoundaryConditions: PeriodicBoundaryCondition, NeumannBoundaryCondition
import PlasmaModelingToolkit.ParticleBoundaries: PeriodicBoundary, ReflectingBoundary
import PlasmaModelingToolkit.Problems: ParticleProblem, BoundaryValueProblem
import PlasmaModelingToolkit.Models: FDMModel, PICModel
import PlasmaModelingToolkit.Species: electrons, ions
import PlasmaModelingToolkit.Sources: SpeciesLoader
import PlasmaModelingToolkit.Distributions: UniformDistribution, MaxwellBoltzmannDistribution
import PlasmaModelingToolkit.Atoms: Helium
import PlasmaModelingToolkit.Units: kHz
import PlasmaModelingToolkit.Constants: c, q_e

const n_0 = 1e24
const T_e = 300.0
const T_i = 0.0
const ν_drift = 1e7
const NR = 1
const NZ = 128
const FREQ = 9kHz

const ω  = 2π * FREQ * sqrt(2e-6n_0)
const Δs = 5e-3c / ω
const Δt = 0.4Δs / ν_drift / √2

const Z = NZ * Δs
const R = NR * Δs

const WG = n_0 * Z * π * R^2 / (NZ * NR * 20)

domain = AxisymmetricDomain(Z, R, Vacuum())

axis  = Segment2D(Z, 0.0, 0.0, 0.0)
side  = Segment2D(0.0, R, Z, R)
lower = Segment2D(0.0, 0.0, 0.0, R)
upper = Segment2D(Z, R, Z, 0.0)
whole = Rectangle(0.0, 0.0, Z, R)

bvp = BoundaryValueProblem(domain)
bvp[axis] = NeumannBoundaryCondition()
bvp[side] = NeumannBoundaryCondition()
bvp[upper] = PeriodicBoundaryCondition()
bvp[lower] = PeriodicBoundaryCondition()

problem = ParticleProblem(domain)
problem[side] = ReflectingBoundary()
problem[lower] = PeriodicBoundary()
problem[upper] = PeriodicBoundary()

e   = electrons()
iHe = ions(Helium)

problem[whole] = SpeciesLoader(e, 0.5n_0, UniformDistribution(), MaxwellBoltzmannDistribution{T_e, e.mass}(), drift = [:z => +ν_drift])
problem[whole] = SpeciesLoader(e, 0.5n_0, UniformDistribution(), MaxwellBoltzmannDistribution{T_e, e.mass}(), drift = [:z => -ν_drift])
problem[whole] = SpeciesLoader(iHe, n_0, UniformDistribution(), MaxwellBoltzmannDistribution{T_i, iHe.mass}())

es  = FDMModel(bvp, NZ + 1, NR + 1)
pic = PICModel(problem, NZ + 1, NR + 1, weights = (e => WG, iHe => WG), maxcount = (e => 20_000, iHe => 20_000))