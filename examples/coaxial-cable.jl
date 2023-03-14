# COMSOL parameters
r_coax = 0.001
R_coax = 0.002
L_coax = 0.040

import PlasmaModelingToolkit.Materials: Air
import PlasmaModelingToolkit.Domains: AxisymmetricDomain
import PlasmaModelingToolkit.Geometry: Segment
import PlasmaModelingToolkit.Constants: η_0
import PlasmaModelingToolkit.BoundaryConditions: SurfaceImpedance, PerfectElectricConductor, PerfectMagneticConductor
import PlasmaModelingToolkit.Sources: CoaxialPort, HarmonicSignal
import PlasmaModelingToolkit.SVG: Figure, save, svg

domain = AxisymmetricDomain((0, L_coax), (r_coax, R_coax), Air())

inner  = Segment{0.0, r_coax, L_coax, r_coax}()
outer  = Segment{0.0, R_coax, L_coax, R_coax}()
input  = Segment{0.0, r_coax, 0.0, R_coax}()
output = Segment{L_coax, R_coax, L_coax, r_coax}()

domain[inner]  = PerfectElectricConductor()
domain[outer]  = PerfectElectricConductor()
domain[output] = SurfaceImpedance(η_0)
domain[input]  = CoaxialPort{HarmonicSignal{1.0, 20e6}}(Air())

f = Figure(domain; 
	width=25)
f.margin["right"]  = 20.5
f.margin["left"]   = 2
f.margin["bottom"] = 3

f.x_axis["ticks"] = [0.0 0.001 0.002]
f.x_axis["tick_labels_angle"] = -45

f.x_axis["label"] = "r-coordinate [m]"
f.x_axis["label_offset"] = 2.5

f.y_axis["ticks"] = [0.0 0.040]

f.y_axis["label"] = "z-coordinate [m]"
f.y_axis["label_offset"] = 1.2

save(svg(f), "coaxial-cable.svg")