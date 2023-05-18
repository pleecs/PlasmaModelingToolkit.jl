import PlasmaModelingToolkit.Models: FDTDModel
import PlasmaModelingToolkit.Problems: BoundaryValueProblem
import PlasmaModelingToolkit.Materials: Air, Metal, permittivity, permeability
import PlasmaModelingToolkit.Domains: AxisymmetricDomain
import PlasmaModelingToolkit.Geometry: Circle, Segment2D
import PlasmaModelingToolkit.Constants: η_0, ε_0
import PlasmaModelingToolkit.BoundaryConditions: PerfectMagneticConductor, PerfectElectricConductor, SurfaceImpedance
import PlasmaModelingToolkit.Units: MHz
import PlasmaModelingToolkit.Sources: WaveguidePort, TM01
import PlasmaModelingToolkit.TemporalFunctions: SineFunction

# simulation parameters
RADIUS  = 0.10            # radius along r-axis [m]
LENGTH  = 0.60            # lenght along z-axis [m]
FREQ    = 20MHz

obstacle = Circle(LENGTH/2, 0.0, RADIUS/3)

domain   = AxisymmetricDomain(LENGTH, RADIUS, Air())
domain[obstacle] = Metal()

axis   = Segment2D(LENGTH, 0, 0, 0)
side   = Segment2D(0, RADIUS, LENGTH, RADIUS)
input  = Segment2D(0, 0, 0, RADIUS)
output = Segment2D(LENGTH, RADIUS, LENGTH, 0)

ε = permittivity(Air())
μ = permeability(Air())
η = √(μ/ε)

problem = BoundaryValueProblem(domain)
problem[axis]   = PerfectMagneticConductor()
problem[side]   = PerfectElectricConductor()
problem[input]  = WaveguidePort(SineFunction{1.0, FREQ}(), TM01(), ε)
problem[output] = SurfaceImpedance(η, ε)

model = FDTDModel(problem, 601, 101)