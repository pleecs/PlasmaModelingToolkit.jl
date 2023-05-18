import PlasmaModelingToolkit.Materials: Air, PTFE, Metal, permittivity, permeability
import PlasmaModelingToolkit.Domains: AxisymmetricDomain
import PlasmaModelingToolkit.Geometry: Segment2D, Rectangle, Circle
import PlasmaModelingToolkit.Constants: η_0, ε_0
import PlasmaModelingToolkit.BoundaryConditions: SurfaceImpedance, PerfectElectricConductor, PerfectMagneticConductor
import PlasmaModelingToolkit.Sources: CoaxialPort, UniformPort
import PlasmaModelingToolkit.TemporalFunctions: GeneralizedLogisticFunction, GaussianWavePacket
import PlasmaModelingToolkit.Models: FDTDModel
import PlasmaModelingToolkit.Problems: BoundaryValueProblem

R_coax = 0.048    # outer radius [m]
r_coax = 0.044    # inner radius [m]
KNEE   = 0.050    # bent radius [m]
RADIUS = 0.050    # radius along r-axis [m]
LENGTH = 0.342    # lenght along z-axis [m]
FREQ   = 50e8     # Excitation frequency [Hz]

inner  = Rectangle(0.0, 0.0, LENGTH, r_coax)
inner -= Rectangle(LENGTH - KNEE, 0.0, KNEE, R_coax)
inner += Circle(LENGTH - KNEE, 0.0, r_coax)
outer  = Rectangle(0.0, R_coax, LENGTH, RADIUS)
outer += Rectangle(LENGTH - KNEE, 0.0, KNEE, R_coax)
outer -= Circle(LENGTH - KNEE, 0.0, R_coax)

domain = AxisymmetricDomain((0, LENGTH), (0, RADIUS), PTFE())

domain[inner]  = Metal()
domain[outer]  = Metal()

input  = Segment2D(0.0, r_coax, 0.0, R_coax)
output = Segment2D(LENGTH, RADIUS, LENGTH, 0.0)
axis   = Segment2D(LENGTH - KNEE + R_coax, 0.0, LENGTH - KNEE + r_coax, 0.0)

ε = permittivity(PTFE())
μ = permeability(PTFE())
η = √(μ/ε)

source = GeneralizedLogisticFunction(η, 30η, 13e-9, 1e9)
spark  = GeneralizedLogisticFunction(1e5, 1e-3, 100e-9, 1e11)
signal = GeneralizedLogisticFunction(0.0, 1.0, 2e-9, 1e9)

problem = BoundaryValueProblem(domain)

problem[output] = PerfectMagneticConductor()
problem[input]  = SurfaceImpedance(source, ε)
problem[input]  = CoaxialPort(signal, ε)
problem[axis]   = SurfaceImpedance(spark, ε)

model = FDTDModel(problem, 685, 101)