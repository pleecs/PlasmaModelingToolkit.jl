# simulation parameters
RADIUS  = 0.10            # radius along r-axis [m]
LENGTH  = 0.60            # lenght along z-axis [m]

import PlasmaModelingToolkit.Materials: Air, Metal
import PlasmaModelingToolkit.Domains: AxisymmetricDomain
import PlasmaModelingToolkit.Geometry: Circle, Segment
import PlasmaModelingToolkit.Constants: η_0, ε_0
import PlasmaModelingToolkit.BoundaryConditions: PerfectMagneticConductor, PerfectElectricConductor, SurfaceImpedance
import PlasmaModelingToolkit.SVG: Figure, save, svg
import PlasmaModelingToolkit.Units: MHz
import PlasmaModelingToolkit.Sources: WaveguidePort, HarmonicSignal, TM01

domain   = AxisymmetricDomain(LENGTH, RADIUS, Air())
obstacle = Circle{LENGTH/2, 0.0, RADIUS/3}()

domain[obstacle] = Metal()

model  = FDTDModel(domain)
axis   = Segment{LENGTH, 0, 0, 0}()
side   = Segment{0, RADIUS, LENGTH, RADIUS}()
input  = Segment{0, 0, 0, RADIUS}()
output = Segment{LENGTH, RADIUS, LENGTH, 0}()

model[axis]   = PerfectMagneticConductor()
model[side]   = PerfectElectricConductor()
model[input]  = WaveguidePort(SineFunction{1.0, 20MHz}(), TM01(), ε_0)
model[input]  = SurfaceImpedance(η_0, ε_0)
model[output] = SurfaceImpedance(η_0, ε_0)

f = Figure(model; width=25)
f.margin["right"]  = 15.5
f.margin["left"]   = 3.5
f.margin["bottom"] = 3

f.x_axis["ticks"] = [0.0 RADIUS]

f.x_axis["label"] = "r-coordinate [m]"

f.y_axis["ticks"] = [0.0 LENGTH/2-RADIUS/3 LENGTH/2 LENGTH/2+RADIUS/3 LENGTH]
f.y_axis["tick_labels_max_digits"] = 4

f.y_axis["label"] = "z-coordinate [m]"
f.y_axis["label_offset"] = 2

save(svg(f), "circular-waveguide.svg")