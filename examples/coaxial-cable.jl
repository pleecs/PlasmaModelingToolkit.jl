# COMSOL parameters
r_coax = 0.001
R_coax = 0.002
L_coax = 0.040

import PlasmaModelingToolkit.Models: FDTDModel
import PlasmaModelingToolkit.Materials: Air
import PlasmaModelingToolkit.Domains: AxisymmetricDomain
import PlasmaModelingToolkit.Geometry: Segment
import PlasmaModelingToolkit.Constants: η_0, ε_0
import PlasmaModelingToolkit.BoundaryConditions: SurfaceImpedance, PerfectElectricConductor, PerfectMagneticConductor
import PlasmaModelingToolkit.Sources: CoaxialPort
import PlasmaModelingToolkit.TemporalFunctions: SineFunction
import PlasmaModelingToolkit.Units: MHz

domain = AxisymmetricDomain((0, L_coax), (r_coax, R_coax), Air())

inner  = Segment{L_coax, r_coax, 0.0, r_coax}()
outer  = Segment{0.0, R_coax, L_coax, R_coax}()
input  = Segment{0.0, r_coax, 0.0, R_coax}()
output = Segment{L_coax, R_coax, L_coax, r_coax}()

model = FDTDModel(domain, 321, 9)
model[inner]  = PerfectElectricConductor()
model[outer]  = PerfectElectricConductor()
model[input]  = CoaxialPort(SineFunction{1.0, 20MHz}(), ε_0)
model[output] = SurfaceImpedance(η_0, ε_0)