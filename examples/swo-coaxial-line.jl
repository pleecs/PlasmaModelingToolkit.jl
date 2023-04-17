R_coax = 0.048    # outer radius [m]
r_coax = 0.044    # inner radius [m]
KNEE   = 0.050    # bent radius [m]
RADIUS = 0.050    # radius along r-axis [m]
LENGTH = 0.342    # lenght along z-axis [m]
FREQ   = 50e8     # Excitation frequency [Hz]
NR     = 101      # number of grid points along radial direction [1]
NZ     = 685      # number of grid points along axial direction [1]

import PlasmaModelingToolkit.Materials: Air, PTFE, Metal
import PlasmaModelingToolkit.Domains: AxisymmetricDomain
import PlasmaModelingToolkit.Geometry: Segment, Rectangle, Circle
import PlasmaModelingToolkit.Constants: η_0, ε_0
import PlasmaModelingToolkit.BoundaryConditions: SurfaceImpedance, PerfectElectricConductor, PerfectMagneticConductor
import PlasmaModelingToolkit.Sources: CoaxialPort, UniformPort
import PlasmaModelingToolkit.TemporalFunctions: GeneralizedLogisticFunction, GaussianWavePacket
import PlasmaModelingToolkit.Models: FDTDModel, Model

inner  = Rectangle{0.0,    0.0, LENGTH, r_coax}()
inner -= Rectangle{LENGTH-KNEE, 0.0, KNEE, R_coax}()
inner += Circle{LENGTH-KNEE, 0.0, r_coax}()
outer  = Rectangle{0.0, R_coax, LENGTH, RADIUS}()
outer += Rectangle{LENGTH-KNEE, 0.0, KNEE, R_coax}()
outer -= Circle{LENGTH-KNEE, 0.0, R_coax}()

domain = AxisymmetricDomain((0, LENGTH), (0, RADIUS), PTFE())

domain[inner]  = Metal()
domain[outer]  = Metal()

input  = Segment{0.0, r_coax, 0.0, R_coax}()
output = Segment{LENGTH, RADIUS, LENGTH, 0.0}()
axis   = Segment{LENGTH-KNEE+R_coax, 0.0, LENGTH-KNEE+r_coax, 0.0}()

source = GeneralizedLogisticFunction(η_0/√(2.04), 30η_0/√(2.04), 13e-9, 1e9)
spark  = GeneralizedLogisticFunction(1e5, 1e-3, 100e-9, 1e11)
signal = GeneralizedLogisticFunction(0.0, 1.0, 2e-9, 1e9)

model = Model(domain)

#model[output] = PerfectElectricConductor()
#model[input]  = SurfaceImpedance(η_0, ε_0)
#model[axis]   = UniformPort(GaussianWavePacket{1.0, 0.5/FREQ, FREQ}(), 2.04ε_0)
model[output] = PerfectMagneticConductor()
model[input]  = SurfaceImpedance(source, 2.04ε_0)
model[input]  = CoaxialPort(signal, 2.04ε_0)
model[axis]   = SurfaceImpedance(spark, 2.04ε_0)

fdtd = FDTDModel(model, NZ, NR)