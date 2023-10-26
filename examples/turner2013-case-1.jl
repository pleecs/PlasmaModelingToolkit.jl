import PlasmaModelingToolkit.Materials: Vacuum
import PlasmaModelingToolkit.Domains: Domain1D
import PlasmaModelingToolkit.Geometry: Point1D, Segment1D
import PlasmaModelingToolkit.BoundaryConditions: DirichletBoundaryCondition
import PlasmaModelingToolkit.ParticleBoundaries: AbsorbingBoundary
import PlasmaModelingToolkit.Problems: BoundaryValueProblem, ParticleCollisionProblem
import PlasmaModelingToolkit.Models: FDMModel, PICModel, MCCModel
import PlasmaModelingToolkit.Species: Particles, Fluid
import PlasmaModelingToolkit.Sources: ParticleLoader, FluidLoader
import PlasmaModelingToolkit.TemporalFunctions: CosineFunction, ConstantFunction
import PlasmaModelingToolkit.Collisions: ElasticCollision, IonizationCollision, ExcitationCollision, IsotropicScattering, BackwardScattering
import PlasmaModelingToolkit.Distributions: UniformDistribution, MaxwellBoltzmannDistribution
import PlasmaModelingToolkit.Atoms: Helium
import PlasmaModelingToolkit.Units: MHz, cm
import PlasmaModelingToolkit.CrossSections: Biagi, Phelps

const X    = 6.7cm                    # electrode separation
const n_He = 9.64e20                  # neutral density
const T_He = 300.0                    # neutral temperature
const FREQ = 13.56MHz                 # RF frequency
const VOLT = 450.0                    # voltage

const n_0 = 2.56e14                   # plasma density
const T_e = 30_000.0                  # electron temperature
const N_C = 512                       # particles per cell

const NX = 128                        # number of cells
const WG = (n_0 * X) / (N_C * NX)     # weight

const Δt  = 1 / 400FREQ
const N_S = 512_000
const N_A =  12_800

domain = Domain1D(0.0, X, Vacuum())

cathode = Point1D(0.0)
anode   = Point1D(X)
whole   = Segment1D(0.0, X)

bvp = BoundaryValueProblem(domain)
bvp[cathode] = DirichletBoundaryCondition(CosineFunction{VOLT, FREQ}())
bvp[anode]   = DirichletBoundaryCondition(ConstantFunction{0.0}())

e   = Particles{:e}(-1.60217662e-19, 9.109e-31)
iHe = Particles{:iHe}(1.60217662e-19, 6.67e-27)
He  = Fluid{:He}(6.67e-27)

problem = ParticleCollisionProblem(domain, e, iHe, He)
problem[cathode] = AbsorbingBoundary(e, iHe)
problem[anode]   = AbsorbingBoundary(e, iHe)

problem[whole] = ParticleLoader(e, n_0,   UniformDistribution(), MaxwellBoltzmannDistribution{T_e, e.mass}())
problem[whole] = ParticleLoader(iHe, n_0, UniformDistribution(), MaxwellBoltzmannDistribution{T_He, iHe.mass}())
problem[whole] = FluidLoader(He, n_He, T_He)

problem += ElasticCollision(e, He, Biagi(version=7.1); scattering=:Isotropic)
problem += ExcitationCollision(e, He, Biagi(version=7.1); scattering=:Isotropic, ε_loss=19.82)
problem += ExcitationCollision(e, He, Biagi(version=7.1); scattering=:Isotropic, ε_loss=20.61)
problem += IonizationCollision(e, He, Biagi(version=7.1); scattering=:Isotropic, ε_loss=24.587, ions=iHe)

problem += ElasticCollision(iHe, He, Phelps(); scattering=:Isotropic)
problem += ElasticCollision(iHe, He, Phelps(); scattering=:Backward)

es  = FDMModel(bvp, NX + 1)
pic = PICModel(problem, NX + 1, maxcount = (e => 200_000, iHe => 200_000), weights = (e => WG, iHe => WG))
mcc = MCCModel(problem)
     