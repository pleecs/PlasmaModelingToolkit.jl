# COMSOL parameters
r_coax = 0.001
R_coax = 0.002
# simulation parameters
NR     = 401             # number of grid points along radial direction [1]
NZ     = 401             # number of grid points along axial direction [1]
RADIUS = 0.05            # radius along r-axis [m]
LENGTH = 0.05            # lenght along z-axis [m]

import PlasmaModelingToolkit.Domains: AxisymmetricDomain
import PlasmaModelingToolkit.Geometry: mm
import PlasmaModelingToolkit.Geometry: Rectangle, Circle
import PlasmaModelingToolkit.Constants: ε_0, μ_0
import PlasmaModelingToolkit.Materials: Air, Metal, PerfectlyMatchedLayer

domain = AxisymmetricDomain(LENGTH, RADIUS, Air())

ground = Rectangle{0, 0, 15mm, RADIUS}()
dielec = Rectangle{0, 0, 15mm, R_coax}()
inner  = Rectangle{0, 0, 22mm, r_coax}()
inner += Circle{22mm, 0, r_coax}() 
top    = Rectangle{LENGTH - 1mm, 0mm, 1mm, RADIUS}()
wall   = Rectangle{0mm, RADIUS - 1mm, LENGTH, 1mm}()

domain[top]    =  PerfectlyMatchedLayer{ε_0, μ_0}(0x01, 0.7(0.02/π), 2)
domain[wall]   =  PerfectlyMatchedLayer{ε_0, μ_0}(0x01, 0.7(0.02/π), 2)
domain[ground] =  Metal()
domain[dielec] =  Air()
domain[inner]  =  Metal()

display(domain)