import PlasmaModelingToolkit.Units: kHz
import PlasmaModelingToolkit.Constants: c_0

const n_0 = 1e24
const T_e = 300.0
const T_i = 0.0
const ν_drift = 1e7
const NR = 1
const NZ = 128
const FREQ = 9kHz

const ω  = 2π * FREQ * sqrt(2e-6n_0)
const Δs = 5e-3c_0 / ω
const Δt = 0.4Δs / ν_drift / √2

const Z = NZ * Δs
const R = NR * Δs

const WG = n_0 * Z * π * R^2 / (NZ * NR * 20)

import PlasmaModelingToolkit.Materials: Vacuum
import PlasmaModelingToolkit.Domains: AxisymmetricDomain
import PlasmaModelingToolkit.Geometry: Segment, Rectangle
import PlasmaModelingToolkit.BoundaryConditions: PeriodicBoundaryCondition, NeumannBoundaryCondition
import PlasmaModelingToolkit.ParticleBoundaries: PeriodicBoundary, ReflectingBoundary
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
problem[lower] = PeriodicBoundary()			#assumes its a full edge of a domain 
problem[upper] = PeriodicBoundary()			 #assumes its a full edge of a domain 


bvp = BoundaryValueProblem(domain)
bvp[axis] = NeumannBoundaryCondition()
bvp[side] = NeumannBoundaryCondition()
bvp[upper] = PeriodicBoundaryCondition()			#assumes its a full edge of a domain 
bvp[lower] = PeriodicBoundaryCondition()			#assumes its a full edge of a domain 

e   = electrons()
iHe = ions(Helium)

# ν_drift = (z, r, θ)
problem[whole] = SpeciesLoader(e, 0.5n_0, UniformDistribution(), MaxwellBoltzmannDistribution{T_e, e.mass}(), drift = (+ν_drift, 0.0, 0.0))
problem[whole] = SpeciesLoader(e, 0.5n_0, UniformDistribution(), MaxwellBoltzmannDistribution{T_e, e.mass}(), drift = (-ν_drift, 0.0, 0.0))

problem[whole] = SpeciesLoader(iHe, n_0, UniformDistribution(), MaxwellBoltzmannDistribution{T_i, iHe.mass}())

es  = FDMModel(bvp, NZ + 1, NR + 1)
pic = PICModel(problem, NZ + 1, NR + 1, Δt = 5, weight = (e => WG, iHe => WG), maxcount = (e => 20_000, iHe => 20_000))

# Hennel.j;
solver = Hennel.Solvers.create(pic, es)