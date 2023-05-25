import PlasmaModelingToolkit.Models: FDTDModel, FDMModel
import PlasmaModelingToolkit.Problems: BoundaryValueProblem
import PlasmaModelingToolkit.Domains: AxisymmetricDomain
import PlasmaModelingToolkit.Geometry: Rectangle, Circle, Segment2D, Polygon
import PlasmaModelingToolkit.Constants: ε_0, μ_0, η_0
import PlasmaModelingToolkit.Materials: Air, Metal, PerfectlyMatchedLayer, PTFE, Vacuum, permittivity, permeability
import PlasmaModelingToolkit.BoundaryConditions: SurfaceImpedance, PerfectElectricConductor, PerfectMagneticConductor
import PlasmaModelingToolkit.BoundaryConditions: DirichletBoundaryCondition, NeumannBoundaryCondition
import PlasmaModelingToolkit.Sources: CoaxialPort
import PlasmaModelingToolkit.TemporalFunctions: SineFunction, GeneralizedLogisticFunction
import PlasmaModelingToolkit.Units: mm, GHz

RADIUS   = 56mm   # radius along r-axis [m]
LENGTH   = 0.1925 # lenght along z-axis [m]
D_RADIUS = 1.2    # domain lenght along z-axis [m]
D_LENGTH = 1.2    # domain lenght along z-axis [m]

outer   = Rectangle(0, 0, 171mm, D_RADIUS)
outer  -= Rectangle(30mm, 0, 141mm, 48mm)
outer  -= Rectangle(5mm, 0, 25mm, 23mm)
outer  -= Circle(30mm, 23mm, 25mm)
outer  += Circle(171mm, 52mm, 3mm)

dielec  = Rectangle(2mm, 18mm, 165mm, RADIUS-15mm)

inner  = Circle(30mm, 23mm, 21mm)
inner += Rectangle(9mm, 0mm, 21mm, 23mm)
inner += Rectangle(30mm, 0mm, 150.5mm, 44mm)
inner += Circle(180.5mm, 39.5mm, 4.5mm)
inner += Polygon([(180.5mm, 0mm), (192.5mm, 0mm), (192.5mm, 10mm), (180.5mm, 22mm)])
inner += Rectangle(192.5mm, 0mm, 230mm, 10mm)
inner += Circle(422.5mm, 0mm, 10mm)

domain = AxisymmetricDomain(D_LENGTH, D_RADIUS, Air())
domain[dielec] = PTFE()
domain[inner] = Metal()
domain[outer] = Metal()

side  = Segment2D(0, D_RADIUS, D_LENGTH, D_RADIUS)
axis  = Segment2D(D_LENGTH, 0, 0, 0)
upper = Segment2D(D_LENGTH, D_RADIUS, D_LENGTH, 0)
lower = Segment2D(0, 0, 0, D_RADIUS)
spark = Segment2D(9mm, 0, 4.9mm, 0)

ε₁ = permittivity(Air())
ε₂ = permittivity(PTFE())

μ = permeability(Air())
η = √(μ/ε₁)

problem = BoundaryValueProblem(domain)
problem[axis]  = PerfectMagneticConductor()
problem[side]  = SurfaceImpedance(η, ε₁)
problem[upper] = SurfaceImpedance(η, ε₁)
problem[lower] = PerfectElectricConductor()
problem[spark] = SurfaceImpedance(GeneralizedLogisticFunction(1e12, 1e-7, 10e-9, 1e9), ε₁)

fdtd = FDTDModel(problem, 601, 601)

problem = BoundaryValueProblem(domain)
problem[axis]   = NeumannBoundaryCondition()
problem[side]   = NeumannBoundaryCondition()
problem[upper]  = NeumannBoundaryCondition()
problem[inner]  = DirichletBoundaryCondition(1.0)
problem[outer]  = DirichletBoundaryCondition(0.0)
fdm = FDMModel(problem, 601, 601)