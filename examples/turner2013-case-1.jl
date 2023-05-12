import PlasmaModelingToolkit.Materials: Vacuum
import PlasmaModelingToolkit.Domains: AxisymmetricDomain
import PlasmaModelingToolkit.Geometry: Segment, Rectangle
import PlasmaModelingToolkit.BoundaryConditions: DirichletBoundaryCondition, NeumannBoundaryCondition
import PlasmaModelingToolkit.ParticleBoundaries: AbsorbingBoundary, ReflectingBoundary
import PlasmaModelingToolkit.Problems: ParticleProblem, BoundaryValueProblem, ParticleCollisionProblem
import PlasmaModelingToolkit.Models: FDMModel, PICModel
import PlasmaModelingToolkit.Species: electrons, ions, gas
import PlasmaModelingToolkit.Sources: SpeciesLoader
import PlasmaModelingToolkit.TemporalFunctions: SineFunction, ConstantFunction
import PlasmaModelingToolkit.Collisions: IsotropicScatteringCollision, IonizationCollision, ExcitationCollision, BackwardScatteringCollision
import PlasmaModelingToolkit.Distributions: UniformDistribution, MaxwellBoltzmannDistribution
import PlasmaModelingToolkit.Atoms: Helium
import PlasmaModelingToolkit.Units: MHz, cm
import PlasmaModelingToolkit.CrossSections: Biagi
import PlasmaModelingToolkit.Constants: ω_He

const Z    = 6.7cm				# electrode separation
const R    = √(1/π)				# electrode radius
const n_He = 9.64e20			# neutral density
const T_He = 300.0 				# neutral temperature
const FREQ = 13.56MHz 			# RF frequency
const VOLT = 450.0 				# voltage

const n_0 = 2.56e14 			# plasma density
const T_e = 30_000.0 			# electron temperature
const T_i = 300.0 				# ion temperature
const N_C = 512 				# particles per cell

const NZ = 128 					# number of cells in z-axis
const NR = 1 					# number of cells in r-axis
const WG = (n_0 * Z * π * R^2) / (N_C * NZ * NR) # weight

const Δt  = 1 / 400FREQ
const N_S = 512_000
const N_A =  12_800

domain = AxisymmetricDomain(Z, R, Vacuum())

axis  = Segment{Z, 0.0, 0.0, 0.0}()
side  = Segment{0.0, R, Z, R}()
lower = Segment{0.0, 0.0, 0.0, R}()
upper = Segment{Z, R, Z, 0.0}()
whole = Rectangle{0.0, 0.0, Z, R}()

bvp = BoundaryValueProblem(domain)
bvp[axis] = NeumannBoundaryCondition()
bvp[side] = NeumannBoundaryCondition()
bvp[upper] = DirichletBoundaryCondition(SineFunction{VOLT, FREQ}())
bvp[lower] = DirichletBoundaryCondition(ConstantFunction{0.0}())

e   = electrons()
iHe = ions(Helium)
He  = gas(Helium)

problem = ParticleCollisionProblem(domain)
problem[side] = ReflectingBoundary(e, iHe)
problem[lower] = AbsorbingBoundary(e, iHe)
problem[upper] = AbsorbingBoundary(e, iHe)

problem[whole] = SpeciesLoader(e, n_0,   UniformDistribution(), MaxwellBoltzmannDistribution{T_e, e.mass}())
problem[whole] = SpeciesLoader(iHe, n_0, UniformDistribution(), MaxwellBoltzmannDistribution{T_i, iHe.mass}())
problem[whole] = SpeciesLoader(He, n_He, UniformDistribution(), MaxwellBoltzmannDistribution{T_He, He.mass}())

problem += IsotropicScatteringCollision(e, He, σ=Biagi(:elastic))
problem += IonizationCollision(e, He, σ=Biagi(:ionization), ω=ω_He)
problem += ExcitationCollision(e, He, σ=Biagi(:excitation))

problem += IsotropicScatteringCollision(iHe, He, σ=Biagi(:excitation))
problem += BackwardScatteringCollision(iHe, He, σ=Biagi(:excitation))

es  = FDMModel(bvp, NZ + 1, NR + 1)
pic = PICModel{2,3}(problem, NZ + 1, NR + 1, maxcount = (e => 200_000, iHe => 200_000), weights = (e => WG, iHe => WG))
# mcc = MCCModel{2,3}(problem)