# COMSOL parameters
r_coax = 0.001
R_coax = 0.002
L_coax = 0.040


import PlasmaModelingToolkit.Materials: Air
import PlasmaModelingToolkit.Domains: AxisymmetricDomain
import PlasmaModelingToolkit.Geometry: Segment

domain = AxisymmetricDomain(L_coax, R_coax, Air, rmin=r_coax)
domain = AxisymmetricDomain((0, L_coax), (r_coax, R_coax), Air)
inner  = Segment{0.0, 0.0, L_coax, 0.0}()
outer  = Segment{0.0, R_coax, L_coax, R_coax}()
input  = Segment{0.0, r_coax, 0.0, R_coax}()
output = Segment{L_coax, R_coax, L_coax, 0.0}()

display(domain)