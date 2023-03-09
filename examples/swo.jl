RADIUS = 0.05             # radius along r-axis [m]
LENGTH = 0.1925           # lenght along z-axis [m]

import PlasmaModelingToolkit.Domains: AxisymmetricDomain
import PlasmaModelingToolkit.Geometry: Rectangle, Circle, Segment, mm, Polygon
import PlasmaModelingToolkit.Constants: ε_0, μ_0, η_0
import PlasmaModelingToolkit.Materials: Air, Metal, PerfectlyMatchedLayer, PTFE, Vacuum
import PlasmaModelingToolkit.BoundaryConditions: SurfaceImpedance, PerfectElectricConductor, PerfectMagneticConductor
import PlasmaModelingToolkit.SVG: figure, save

domain = AxisymmetricDomain(0.5, 0.5, Air())

outer 	= Rectangle{0, 0, 171mm, RADIUS}()
outer  -= Rectangle{30mm, 0, 141mm, 48mm}()
outer  -= Rectangle{5mm, 0, 25mm, 23mm}()
outer  -= Circle{30mm, 23mm, 25mm}()
outer  += Circle{166mm, RADIUS-2mm, 10mm}()
outer  -= Rectangle{156mm, RADIUS-12mm, 20mm, 10mm}()
outer  -= Rectangle{171mm, RADIUS-2mm, 5mm, 10mm}()
outer  -= Rectangle{156mm, RADIUS, 5mm, 10mm}()

dielec  = Rectangle{5mm, 18mm, 170.5mm, 45.5mm}()
dielec -= Rectangle{9mm, 18mm, 21mm, 5mm}()
dielec -= Rectangle{30mm, 15mm, 145.5mm, 29mm}()
dielec -= Circle{30mm, 23mm, 21mm}()
dielec -= Rectangle{5mm, RADIUS, 166mm, 13.5mm}()
dielec -= outer

inner = Circle{30mm, 23mm, 21mm}()
inner += Rectangle{9mm, 0mm, 21mm, 23mm}()
inner += Rectangle{30mm, 0mm, 150.5mm, 44mm}()
inner += Circle{180.5mm, 39.5mm, 4.5mm}()
inner += Polygon([(180.5mm, 0mm), (192.5mm, 0mm), (192.5mm, 10mm), (180.5mm, 22mm)])

domain[dielec] = PTFE()
domain[outer] = Metal()
domain[inner] = Metal()

f = figure(domain; width=30, margin_top=2, margin_bottom=2, margin_right=2, margin_left=2, offset=2)

save(f, "swo.svg")