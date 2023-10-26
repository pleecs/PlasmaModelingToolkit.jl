import PlasmaModelingToolkit.Domains: OneDimensionalDomain
import PlasmaModelingToolkit.Models: FDMModel, PICModel, MCCModel
import PlasmaModelingToolkit.Problems: BoundaryValueProblem, ParticleCollisionProblem
import PlasmaModelingToolkit.BoundaryConditions: DirichletBoundaryCondition
import PlasmaModelingToolkit.ParticleBoundaries: AbsorbingBoundary
import PlasmaModelingToolkit.Distributions: UniformDistribution, MaxwellBoltzmannDistribution
import PlasmaModelingToolkit.Collisions: Collision
import PlasmaModelingToolkit.CrossSections: Biagi
import PlasmaModelingToolkit.Collisions: ElasticCollision, IonizationCollision, ExcitationCollision
import PlasmaModelingToolkit.Sources: ParticleLoader, FluidLoader
import PlasmaModelingToolkit.Geometry: Segment1D, Point1D
import PlasmaModelingToolkit.Materials: Vacuum
import PlasmaModelingToolkit.Species: electrons, ions, gas
import PlasmaModelingToolkit.Units: ps, torr, Td, cm
import PlasmaModelingToolkit.Atoms: Helium
import PlasmaModelingToolkit.Constants: ε_0, kB

V = 160.0               # voltage (V)
T = 300.0               # temperature (K)
P = 21.2torr            # pressure (Pa)
E = 212e3               # electric field (V/m)
n_0 = P / (T * kB)      # number density (1/m^3)
N_e = 100_000           # number of electrons
L = V / E               # domain length
n_e = N_e * 1000/L      # electron density in source
N = 129                 # grid points

domain = OneDimensionalDomain(0.0, L, Vacuum())

anode = Point1D(0.0)
cathode = Point1D(L)
whole = Segment1D(0, L)
source = Segment1D(0, L/1000)

bvp = BoundaryValueProblem(domain)
bvp[anode] = DirichletBoundaryCondition(0)
bvp[cathode] = DirichletBoundaryCondition(V)

e   = electrons()
He  = gas(Helium)
iHe = ions(Helium)

problem = ParticleCollisionProblem(domain, e, He, iHe)

problem[anode] = AbsorbingBoundary()
problem[cathode] = AbsorbingBoundary()

problem[source] = ParticleLoader(e, N_e, UniformDistribution())
problem[whole] = FluidLoader(He, n_0, T)

problem += ElasticCollision(e, He, Biagi(version=8.97); scattering=:Vahedi)
problem += ExcitationCollision(e, He, Biagi(version=8.97); ε_loss=19.82, scattering=:Isotropic)
problem += ExcitationCollision(e, He, Biagi(version=8.97); ε_loss=20.62, scattering=:Isotropic)
problem += ExcitationCollision(e, He, Biagi(version=8.97); ε_loss=20.96, scattering=:Isotropic)
problem += ExcitationCollision(e, He, Biagi(version=8.97); ε_loss=21.22, scattering=:Isotropic)
problem += ExcitationCollision(e, He, Biagi(version=8.97); ε_loss=23.087, scattering=:Isotropic)
problem += IonizationCollision(e, He, Biagi(version=8.97); ε_loss=24.5874, scattering=:Opal, ions=iHe)

fdm = FDMModel(bvp, N)
pic = PICModel(problem, N;
    weights=tuple(e => 1.0, iHe => 1.0),
    maxcount=tuple(e => 5N_e, iHe => 4N_e));
mcc = MCCModel(problem);