import PlasmaModelingToolkit.Units: MHz, cm
import PlasmaModelingToolkit.Constants: c_0

const Z    = 6.7cm				# electrode separation
const R    = √(1/π)				#
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

import PlasmaModelingToolkit.Materials: Vacuum
import PlasmaModelingToolkit.Domains: AxisymmetricDomain
import PlasmaModelingToolkit.Geometry: Segment, Rectangle
import PlasmaModelingToolkit.BoundaryConditions: DirichletBoundaryCondition, NeumannBoundaryCondition
import PlasmaModelingToolkit.BoundaryConditions: AbsorbingBoundary, ReflectingBoundary
import PlasmaModelingToolkit.Problems: ParticleProblem, BoundaryValueProblem
import PlasmaModelingToolkit.Models: FDMModel, PICModel
import PlasmaModelingToolkit.Species: electrons, ions
import PlasmaModelingToolkit.Sources: ParticleLoader
import PlasmaModelingToolkit.Distributions: UniformDistribution, MaxwellBoltzmannDistribution
import PlasmaModelingToolkit.Atoms: Helium

domain = AxisymmetricDomain(Z, R, Vacuum())

axis  = Segment{Z, 0.0, 0.0, 0.0}()
side  = Segment{0.0, R, Z, R}()
lower = Segment{0.0, 0.0, 0.0, R}()
upper = Segment{Z, R, Z, 0.0}()
whole = Rectangle{0.0, 0.0, Z, R}()

problem = ParticleProblem{2,3}(domain)
problem[side] = ReflectingBoundary()
problem[lower] = AbsorbingBoundary()
problem[upper] = AbsorbingBoundary()

bvp = BoundaryValueProblem(domain)
bvp[axis] = NeumannBoundaryCondition()
bvp[side] = NeumannBoundaryCondition()
bvp[upper] = DirichletBoundaryCondition(SineFunction{VOLT, FREQ}())
bvp[lower] = DirichletBoundaryCondition(ConstantFunction{0.0}())

e   = electrons()
iHe = ions(Helium)
He  = gas(Helium)

# ν_drift = (z, r, θ)
problem[whole] = SpeciesLoader(e, n_0,   UniformDistribution(), MaxwellBoltzmannDistribution{T_e, e.mass}())
problem[whole] = SpeciesLoader(iHe, n_0, UniformDistribution(), MaxwellBoltzmannDistribution{T_i, iHe.mass}())
problem[whole] = SpeciesLoader(He, n_He, UniformDistribution(), MaxwellBoltzmannDistribution{T_He, He.mass}())

es  = FDMModel(bvp, NZ + 1, NR + 1)
pic = PICModel(problem, NZ + 1, NR + 1, Δt = Δt, maxcount = (e => 200_000, iHe => 200_000))

# Hennel.j;
solver = Hennel.Solvers.create(pic, es)