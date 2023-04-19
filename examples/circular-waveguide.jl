# simulation parameters
RADIUS  = 0.10            # radius along r-axis [m]
LENGTH  = 0.60            # lenght along z-axis [m]

import PlasmaModelingToolkit.Models: FDTDModel
import PlasmaModelingToolkit.Problems: BoundaryValueProblem
import PlasmaModelingToolkit.Materials: Air, Metal
import PlasmaModelingToolkit.Domains: AxisymmetricDomain
import PlasmaModelingToolkit.Geometry: Circle, Segment
import PlasmaModelingToolkit.Constants: η_0, ε_0
import PlasmaModelingToolkit.BoundaryConditions: PerfectMagneticConductor, PerfectElectricConductor, SurfaceImpedance
import PlasmaModelingToolkit.Units: MHz
import PlasmaModelingToolkit.Sources: WaveguidePort, TM01
import PlasmaModelingToolkit.TemporalFunctions: SineFunction

obstacle = Circle{LENGTH/2, 0.0, RADIUS/3}()

domain   = AxisymmetricDomain(LENGTH, RADIUS, Air())
domain[obstacle] = Metal()

axis   = Segment{LENGTH, 0, 0, 0}()
side   = Segment{0, RADIUS, LENGTH, RADIUS}()
input  = Segment{0, 0, 0, RADIUS}()
output = Segment{LENGTH, RADIUS, LENGTH, 0}()

problem = BoundaryValueProblem(domain)
problem[axis]   = PerfectMagneticConductor()
problem[side]   = PerfectElectricConductor()
problem[input]  = WaveguidePort(SineFunction{1.0, 20MHz}(), TM01(), ε_0)
problem[output] = SurfaceImpedance(η_0, ε_0)

model = FDTDModel(problem, 601, 101)