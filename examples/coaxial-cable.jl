# COMSOL parameters
r_coax = 0.001
R_coax = 0.002
L_coax = 0.040

import PlasmaModelingToolkit.Materials: Air
import PlasmaModelingToolkit.Domains: AxisymmetricDomain
import PlasmaModelingToolkit.Geometry: Segment
import PlasmaModelingToolkit.Constants: η_0
import PlasmaModelingToolkit.BoundaryConditions: SurfaceImpedance, PerfectElectricConductor, PerfectMagneticConductor
import PlasmaModelingToolkit.Sources: CoaxialPort
import PlasmaModelingToolkit.SVG: Figure, save, svg

domain = AxisymmetricDomain((0, L_coax), (r_coax, R_coax), Air())

inner  = Segment{0.0, r_coax, L_coax, r_coax}()
outer  = Segment{0.0, R_coax, L_coax, R_coax}()
input  = Segment{0.0, r_coax, 0.0, R_coax}()
output = Segment{L_coax, R_coax, L_coax, r_coax}()

domain[inner]  = PerfectElectricConductor()
domain[outer]  = PerfectElectricConductor()
domain[output] = SurfaceImpedance(η_0)
domain[input]  = CoaxialPort(1.0, 20e9)

f = Figure(domain; 
	width=30)

save(f, "coaxial-cable.svg")