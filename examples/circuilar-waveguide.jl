# simulation parameters
RADIUS  = 0.10            # radius along r-axis [m]
LENGTH  = 0.60            # lenght along z-axis [m]

import PlasmaModelingToolkit.Materials: Air, Metal
import PlasmaModelingToolkit.Domains: AxisymmetricDomain
import PlasmaModelingToolkit.Geometry: Circle, Segment
import PlasmaModelingToolkit.Constants: η_0
import PlasmaModelingToolkit.BoundaryConditions: PerfectMagneticConductor, PerfectElectricConductor, SurfaceImpedance

domain = AxisymmetricDomain(LENGTH, RADIUS, Air())

circle = Circle{LENGTH/2, 0.0, RADIUS/3}()
axis   = Segment{LENGTH, 0, 0, 0}()
side   = Segment{0, RADIUS, LENGTH, RADIUS}()
input  = Segment{0, 0, 0, RADIUS}()
output = Segment{LENGTH, RADIUS, LENGTH, 0}()

domain[circle] = Metal()
domain[axis] = PerfectMagneticConductor()
domain[side] = PerfectElectricConductor()
domain[input] = SurfaceImpedance(η_0)
domain[output] = SurfaceImpedance(η_0)

display(domain)