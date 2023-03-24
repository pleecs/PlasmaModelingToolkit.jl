# COMSOL parameters
r_coax = 0.001
R_coax = 0.002
# simulation parameters
RADIUS = 0.05            # radius along r-axis [m]
LENGTH = 0.05            # lenght along z-axis [m]
FREQ   = 50e9            # Excitation frequency [Hz]

import PlasmaModelingToolkit.Domains: AxisymmetricDomain
import PlasmaModelingToolkit.Geometry: Rectangle, Circle, Segment, mm
import PlasmaModelingToolkit.Constants: ε_0, η_0
import PlasmaModelingToolkit.Materials: Air, Metal, PerfectlyMatchedLayer, PTFE
import PlasmaModelingToolkit.BoundaryConditions: SurfaceImpedance, PerfectElectricConductor, PerfectMagneticConductor
import PlasmaModelingToolkit.Sources: CoaxialPort, HarmonicSignal
import PlasmaModelingToolkit.SVG: Figure, save, svg

domain = AxisymmetricDomain(LENGTH, RADIUS, Air())

ground = Rectangle{0, 0, 15mm, RADIUS}()
dielec = Rectangle{0, 0, 15mm, R_coax}()
inner  = Rectangle{0, 0, 22mm, r_coax}()
inner += Circle{22mm, 0, r_coax}() 
top    = Rectangle{LENGTH - 1mm, 0mm, 1mm, RADIUS}()
wall   = Rectangle{0mm, RADIUS - 1mm, LENGTH, 1mm}()
axis   = Segment{LENGTH, 0, 0, 0}()
side   = Segment{0, RADIUS, LENGTH, RADIUS}()
input  = Segment{0, r_coax, 0, R_coax}()
output = Segment{LENGTH, RADIUS, LENGTH, 0}()

obstacle = Circle{30mm, 14.9mm, 9mm}()
obstacle-= Circle{30mm, 14.9mm, 5mm}()

domain[top]    = PerfectlyMatchedLayer(Air(), 0.7(0.02/π), 2)
domain[wall]   = PerfectlyMatchedLayer(Air(), 0.7(0.02/π), 2)
domain[ground] = Metal()
domain[dielec] = PTFE()
domain[inner]  = Metal()
domain[axis]   = PerfectMagneticConductor()
domain[side]   = PerfectElectricConductor()
domain[input]  = SurfaceImpedance(2.04η_0, 2.04ε_0)
domain[input]  = CoaxialPort(HarmonicSignal{1.0, FREQ}(), 2.04ε_0)
domain[output] = PerfectElectricConductor()

domain[obstacle] = PTFE()

f = Figure(domain; width=25)
f.margin            = 1
f.margin["bottom"]  = 2 
f.margin["left"]    = 3.5

f.offset            = 0.5
f.offset["right"]   = 2

f.x_axis["ticks"]   = [0.0 r_coax R_coax RADIUS]
f.x_axis["tick_labels_angle"] = -90
f.x_axis["label"]   = "r-coordinate [m]"
f.x_axis["start_from_zero"] = true

f.y_axis["ticks"]   = [0.0 0.015 0.023 LENGTH]
f.y_axis["label"]   = "z-coordinate [m]"
f.y_axis["start_from_zero"] = true

f.font["size"] = 12

save(svg(f), "dipole-antenna.svg")