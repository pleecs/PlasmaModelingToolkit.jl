import PlasmaModelingToolkit.Models: FDTDModel
import PlasmaModelingToolkit.Problems: BoundaryValueProblem
import PlasmaModelingToolkit.Domains: AxisymmetricDomain
import PlasmaModelingToolkit.Geometry: Rectangle, Circle, Segment
import PlasmaModelingToolkit.Constants: ε_0, η_0
import PlasmaModelingToolkit.Materials: Air, Metal, PerfectlyMatchedLayer, PTFE, permittivity
import PlasmaModelingToolkit.BoundaryConditions: SurfaceImpedance, PerfectElectricConductor, PerfectMagneticConductor
import PlasmaModelingToolkit.Sources: CoaxialPort
import PlasmaModelingToolkit.TemporalFunctions: SineFunction
import PlasmaModelingToolkit.Units: mm, GHz

r_coax = 0.001
R_coax = 0.002
RADIUS = 0.05            # radius along r-axis [m]
LENGTH = 0.05            # lenght along z-axis [m]
FREQ   = 50GHz

ground = Rectangle{0, 0, 15mm, RADIUS}()
dielec = Rectangle{0, 0, 15mm, R_coax}()
inner  = Rectangle{0, 0, 22mm, r_coax}()
inner += Circle{22mm, 0, r_coax}() 
top    = Rectangle{LENGTH - 1mm, 0mm, 1mm, RADIUS}()
wall   = Rectangle{0mm, RADIUS - 1mm, LENGTH, 1mm}()
obstacle = Circle{30mm, 14.9mm, 9mm}()
obstacle-= Circle{30mm, 14.9mm, 5mm}()

domain = AxisymmetricDomain(LENGTH, RADIUS, Air())
domain[top]    = PerfectlyMatchedLayer(Air(), 0.7(0.02/π), 2)
domain[wall]   = PerfectlyMatchedLayer(Air(), 0.7(0.02/π), 2)
domain[ground] = Metal()
domain[dielec] = PTFE()
domain[inner]  = Metal()
domain[obstacle] = PTFE()

axis   = Segment{LENGTH, 0, 0, 0}()
side   = Segment{0, RADIUS, LENGTH, RADIUS}()
input  = Segment{0, r_coax, 0, R_coax}()
output = Segment{LENGTH, RADIUS, LENGTH, 0}()

ε = permittivity(PTFE())

problem = BoundaryValueProblem(domain)
problem[axis]   = PerfectMagneticConductor()
problem[side]   = PerfectElectricConductor()
problem[input]  = CoaxialPort(SineFunction{1.0, FREQ}(), ε)
problem[output] = PerfectElectricConductor()

model = FDTDModel(problem, 101, 101)