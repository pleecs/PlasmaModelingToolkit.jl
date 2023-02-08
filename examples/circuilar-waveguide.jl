# simulation parameters
RADIUS  = 0.10            # radius along r-axis [m]
LENGTH  = 0.60            # lenght along z-axis [m]
NR      = 101             # number of grid points along radial direction [1]
NZ      = 601             # number of grid points along axial direction [1]

import PlasmaModelingToolkit.Materials: Air, Metal
import PlasmaModelingToolkit.Domains: AxisymmetricDomain
import PlasmaModelingToolkit.Geometry: Circle
domain = AxisymmetricDomain(LENGTH, RADIUS, Air, rmin=0.4)
circle = Circle{LENGTH/2, 0.0, RADIUS/3}()
domain[circle] = Metal

display(domain)