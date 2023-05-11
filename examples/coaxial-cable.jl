import PlasmaModelingToolkit.Models: FDTDModel
import PlasmaModelingToolkit.Problems: BoundaryValueProblem
import PlasmaModelingToolkit.Materials: Air, permittivity, permeability
import PlasmaModelingToolkit.Domains: AxisymmetricDomain
import PlasmaModelingToolkit.Geometry: Segment
import PlasmaModelingToolkit.Constants: η_0, ε_0
import PlasmaModelingToolkit.BoundaryConditions: SurfaceImpedance, PerfectElectricConductor, PerfectMagneticConductor
import PlasmaModelingToolkit.Sources: CoaxialPort
import PlasmaModelingToolkit.TemporalFunctions: SineFunction
import PlasmaModelingToolkit.Units: MHz

r_coax = 0.001
R_coax = 0.002
L_coax = 0.040
FREQ   = 20MHz

domain = AxisymmetricDomain((0, L_coax), (r_coax, R_coax), Air())

inner  = Segment{L_coax, r_coax, 0.0, r_coax}()
outer  = Segment{0.0, R_coax, L_coax, R_coax}()
input  = Segment{0.0, r_coax, 0.0, R_coax}()
output = Segment{L_coax, R_coax, L_coax, r_coax}()

ε = permittivity(Air())
μ = permeability(Air())
η = √(μ/ε)

problem = BoundaryValueProblem(domain)
problem[inner]  = PerfectElectricConductor()
problem[outer]  = PerfectElectricConductor()
problem[input]  = CoaxialPort(SineFunction{1.0, FREQ}(), ε)
problem[output] = SurfaceImpedance(η, ε)

model = FDTDModel(problem, 321, 9)