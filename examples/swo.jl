import PlasmaModelingToolkit.Models: FDTDModel
import PlasmaModelingToolkit.Problems: BoundaryValueProblem
import PlasmaModelingToolkit.Domains: AxisymmetricDomain
import PlasmaModelingToolkit.Geometry: Rectangle, Circle, Segment2D, Polygon
import PlasmaModelingToolkit.Constants: ε_0, μ_0, η_0
import PlasmaModelingToolkit.Materials: Air, Metal, PerfectlyMatchedLayer, PTFE, Vacuum, permittivity, permeability
import PlasmaModelingToolkit.BoundaryConditions: SurfaceImpedance, PerfectElectricConductor, PerfectMagneticConductor
import PlasmaModelingToolkit.Sources: CoaxialPort
import PlasmaModelingToolkit.TemporalFunctions: GeneralizedLogisticFunction
import PlasmaModelingToolkit.Units: mm

RADIUS = 0.05             # radius along r-axis [m]
LENGTH = 0.1925           # lenght along z-axis [m]
D_RADIUS = 0.5            # domain lenght along z-axis [m]
D_LENGTH = 0.5            # domain lenght along z-axis [m]

outer 	= Rectangle(0, 0, 171mm, RADIUS)
outer  -= Rectangle(30mm, 0, 141mm, 48mm)
outer  -= Rectangle(5mm, 0, 25mm, 23mm)
outer  -= Circle(30mm, 23mm, 25mm)
ring    = Circle(166mm, RADIUS-2mm, 10mm)
ring   -= Rectangle(156mm, RADIUS-12mm, 20mm, 10mm)
ring   -= Rectangle(171mm, RADIUS-2mm, 5mm, 10mm)
ring   -= Rectangle(156mm, RADIUS-2mm, 5mm, 10mm)
outer  += ring

dielec  = Rectangle(5mm, 18mm, 170.5mm, 45.5mm)
dielec -= Rectangle(9mm, 18mm, 21mm, 5mm)
dielec -= Rectangle(30mm, 15mm, 145.5mm, 29mm)
dielec -= Circle(30mm, 23mm, 21mm)
dielec -= Rectangle(5mm, RADIUS, 166mm, 13.5mm)
dielec -= outer

inner  = Circle(30mm, 23mm, 21mm)
inner += Rectangle(9mm, 0mm, 21mm, 23mm)
inner += Rectangle(30mm, 0mm, 150.5mm, 44mm)
inner += Circle(180.5mm, 39.5mm, 4.5mm)
inner += Polygon([(180.5mm, 0mm), (192.5mm, 0mm), (192.5mm, 10mm), (180.5mm, 22mm)])

PML_th     = 0.01
top_pml    = Rectangle(D_LENGTH - PML_th, 0mm, PML_th, D_RADIUS)
side_pml   = Rectangle(0mm, D_RADIUS - PML_th, D_LENGTH, PML_th)
bottom_pml = Rectangle(0mm, RADIUS, PML_th, D_RADIUS - RADIUS)

domain = AxisymmetricDomain(D_LENGTH, D_RADIUS, Air())
domain[dielec] = PTFE()
domain[outer]  = Metal()
domain[inner]  = Metal()
domain[top_pml]	= PerfectlyMatchedLayer(Air(), 0.7(0.02/π), 2)
domain[side_pml] = PerfectlyMatchedLayer(Air(), 0.7(0.02/π), 2)
domain[bottom_pml] = PerfectlyMatchedLayer(Air(), 0.7(0.02/π), 2)

axis     = Segment2D(D_LENGTH, 0.0, 192.5mm, 0.0)
input    = Segment2D(171mm, 48mm, 171mm, 44mm)
sparkgap = Segment2D(9mm, 0.0, 5mm, 0.0)

ε₁ = permittivity(Air())
ε₂ = permittivity(PTFE())

μ = permeability(Air())
η = √(μ/ε₁)

problem = BoundaryValueProblem(domain)
problem[axis] = PerfectMagneticConductor()
problem[input] = CoaxialPort(GeneralizedLogisticFunction(0.0, 1.0, 1e-9, 1e5), ε₂)
problem[sparkgap] = SurfaceImpedance(GeneralizedLogisticFunction(η, 1e-2, 20e-9, 1e5), ε₁)

model = FDTDModel(problem, 401, 401)