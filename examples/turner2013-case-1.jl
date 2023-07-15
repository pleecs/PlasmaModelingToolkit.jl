import PlasmaModelingToolkit.Materials: Vacuum
import PlasmaModelingToolkit.Domains: Domain1D
import PlasmaModelingToolkit.Geometry: Point1D, Segment1D
import PlasmaModelingToolkit.BoundaryConditions: DirichletBoundaryCondition
import PlasmaModelingToolkit.ParticleBoundaries: AbsorbingBoundary
import PlasmaModelingToolkit.Problems: BoundaryValueProblem, ParticleCollisionProblem
import PlasmaModelingToolkit.Models: FDMModel, PICModel, MCCModel
import PlasmaModelingToolkit.Species: electrons, ions, gas
import PlasmaModelingToolkit.Sources: SpeciesLoader
import PlasmaModelingToolkit.TemporalFunctions: SineFunction, ConstantFunction
import PlasmaModelingToolkit.Collisions: IsotropicScatteringCollision, IonizationCollision, ExcitationCollision, BackwardScatteringCollision, ElasticCollision
import PlasmaModelingToolkit.Distributions: UniformDistribution, MaxwellBoltzmannDistribution
import PlasmaModelingToolkit.Atoms: Helium
import PlasmaModelingToolkit.Units: MHz, cm
import PlasmaModelingToolkit.Constants: ω_He

const X    = 6.7cm                    # electrode separation
const R    = √(1/π)                   # electrode radius
const n_He = 9.64e20                  # neutral density
const T_He = 300.0                    # neutral temperature
const FREQ = 13.56MHz                 # RF frequency
const VOLT = 450.0                    # voltage

const n_0 = 2.56e14                   # plasma density
const T_e = 30_000.0                  # electron temperature
const T_i = 300.0                     # ion temperature
const N_C = 512                       # particles per cell

const NX = 128                        # number of cells
const WG = (n_0 * X * π * R^2) / 
       (N_C * NX)                     # weight

const Δt  = 1 / 400FREQ
const N_S = 512_000
const N_A =  12_800

domain = Domain1D(0.0, X, Vacuum())

cathode = Point1D(0.0)
anode   = Point1D(X)
whole   = Segment1D(0.0, X)

bvp = BoundaryValueProblem(domain)
bvp[cathode] = DirichletBoundaryCondition(SineFunction{VOLT, FREQ}())
bvp[anode]   = DirichletBoundaryCondition(ConstantFunction{0.0}())

e   = electrons()
iHe = ions(Helium)
He  = gas(Helium)

problem = ParticleCollisionProblem(domain)
problem[cathode] = AbsorbingBoundary(e, iHe)
problem[anode]   = AbsorbingBoundary(e, iHe)

problem[whole] = SpeciesLoader(e, n_0,   UniformDistribution(), MaxwellBoltzmannDistribution{T_e, e.mass}())
problem[whole] = SpeciesLoader(iHe, n_0, UniformDistribution(), MaxwellBoltzmannDistribution{T_i, iHe.mass}())
problem[whole] = SpeciesLoader(He, n_He, UniformDistribution(), MaxwellBoltzmannDistribution{T_He, He.mass}())

problem += ElasticCollision(e, He, σ_dataset=:Biagi)
problem += IonizationCollision(e, He, σ_dataset=:Biagi)
problem += ExcitationCollision(e, He, σ_dataset=:Biagi, ε=19.82)
problem += ExcitationCollision(e, He, σ_dataset=:Biagi, ε=20.61)

problem += IsotropicScatteringCollision(iHe, He, σ_dataset=:Phelps)
problem += BackwardScatteringCollision(iHe, He, σ_dataset=:Phelps)

es  = FDMModel(bvp, NX + 1)
pic = PICModel(problem, NX + 1, maxcount = (e => 200_000, iHe => 200_000), weights = (e => WG, iHe => WG))
mcc = MCCModel(problem)