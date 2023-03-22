# COMSOL parameters
r_coax = 0.001
R_coax = 0.002
# simulation parameters
NR     = 401             # number of grid points along radial direction [1]
NZ     = 401             # number of grid points along axial direction [1]
RADIUS = 0.05            # radius along r-axis [m]
LENGTH = 0.05            # lenght along z-axis [m]

import PlasmaModelingToolkit.Domains: AxisymmetricDomain
import PlasmaModelingToolkit.Geometry: Rectangle, Circle, Segment, mm
import PlasmaModelingToolkit.Constants: ε_0, η_0
import PlasmaModelingToolkit.Materials: Air, Metal, PerfectlyMatchedLayer
import PlasmaModelingToolkit.BoundaryConditions: SurfaceImpedance, PerfectElectricConductor, PerfectMagneticConductor
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
input  = Segment{0, 0, 0, RADIUS}()
output = Segment{LENGTH, RADIUS, LENGTH, 0}()

domain[top]    = PerfectlyMatchedLayer(Air(), 0.7(0.02/π), 2)
domain[wall]   = PerfectlyMatchedLayer(Air(), 0.7(0.02/π), 2)
domain[ground] = Metal()
domain[dielec] = Air()
domain[inner]  = Metal()
domain[axis]   = PerfectMagneticConductor()
domain[side]   = PerfectElectricConductor()
domain[input]  = SurfaceImpedance(η_0, ε_0)
domain[output] = PerfectElectricConductor()

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