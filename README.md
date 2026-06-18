# PlasmaModelingToolkit.jl

PlasmaModelingToolkit.jl is a Julia toolbox for building plasma simulation setups by composing geometry, materials, boundary conditions, particle species, and numerical models. The package is organized into focused submodules, each representing a physical concept or a numerical building block.

This README provides a detailed, module-by-module reference with the key types, constructors, helpers, and how each piece connects to the rest of the toolkit.

## Top-level structure

The root module is `PlasmaModelingToolkit`, defined in `src/PlasmaModelingToolkit.jl`. It includes the submodules below in a fixed order, which also reflects dependency direction (lower-level physical abstractions first, then problems/models/plots).

## Submodules

**Units** (`src/units.jl`)
- **Purpose** Defines common unit scalars for time, length, frequency, resistance, voltage, current, and pressure.
- **Constants** `ms`, `us`, `ns`, `ps`, `cm`, `mm`, `nm`, `Hz`, `kHz`, `MHz`, `GHz`, `Ohm`, `mOhm`, `kOhm`, `MOhm`, `V`, `kV`, `MV`, `A`, `mA`, `kA`, `Td`, `Pa`, `atm`, `torr`.
- **Notes** These are numeric scale factors to keep examples readable; there is no unit checking or dimensional analysis.

**Constants** (`src/constants.jl`)
- **Purpose** Physical and derived constants used across models and collision physics.
- **Physical constants** `q_e`, `m_e`, `Da`, `epsilon_0`, `mu_0`, `kB`, `c`, `chi_01`.
- **Derived constants** `eta_0` (free-space impedance), `c2` (speed of light squared).
- **Collision support** `Ebar` dictionary for Opal scattering parameters by gas species.
- **Notes** The `Ebar` table is required when selecting Opal scattering in ionization collisions.

**Atoms** (`src/atoms.jl`)
- **Purpose** Minimal atom definition for creating species.
- **Types** `Atom` with fields `sym` and `mass`.
- **Built-ins** `Helium`, `Argon`.
- **Notes** Masses are given in kilograms using `Da` from `Constants`.

**Species** (`src/species.jl`)
- **Purpose** Represent charged and neutral species for particles and fluids.
- **Types** `AbstractSpecies`, `Particles{SYM}` (charge, mass), `Fluid{SYM}` (mass).
- **Constructors** `electrons()`, `ions(atom, n)`, `particles(atom)`, `gas(atom)`.
- **Notes** The particle symbol encodes charge state in the type parameter for ions.

**CrossSections** (`src/crosssections.jl`)
- **Purpose** Load, parse, and select cross section data for collisions.
- **Dataset loaders** `Biagi(version=...)` and `Phelps()` read JLD2 datasets under `data/`.
- **LXCat parser** `lxcatread(path, name)` loads text-format LXCat datasets into nested dictionaries indexed by source, target, and process.
- **Selection API** `CrossSection(dataset, type, source, target; eps_loss, scattering, excited_state)` filters to a single dataset row and attaches attributes.
- **Utilities** `resample(data; n, dE, min, max)` interpolates cross sections to a uniform energy grid.
- **Notes** Selection validates that exactly one process entry matches the provided attributes.

**Geometry** (`src/geometry.jl`)
- **Purpose** Core geometric primitives and predicates for domains, constraints, and boundary selection.
- **Types** `Shape{D}`, `Segment{D}`, `Point{D}`, `Rectangle`, `Circle`, `Polygon`, `Ray`, `CompositeShape` (union and subtraction).
- **Operators** `in` for point-in-shape tests, `intersect` for ray-segment intersection, `plus` and `minus` for composite shapes.
- **Helpers** axis-parallel checks for segments, polygon builder from nodes, and tuple-level approximate equality.
- **Notes** Polygon containment uses a randomized ray crossing test to handle boundary cases.

**TemporalFunctions** (`src/temporal.jl`)
- **Purpose** Type-level representations of time-varying signals used by sources and boundary conditions.
- **Types** Constant, generalized logistic, logistic, sine, cosine, Gaussian pulses, Gaussian wave packets, double exponential pulse, and ramp functions.
- **Usage** These are currently type tags with parameters encoded at the type level; they do not implement evaluation by themselves.

**Materials** (`src/materials.jl`)
- **Purpose** Represent conductors and media for domain composition and boundary detection.
- **Types** `Material`, `Conductor`, `Medium`, `IdealConductor`, `LossyConductor`, `Dielectric`, `PerfectlyMatchedLayer`.
- **Constructors** `Metal`, `Copper`, `Vacuum`, `PTFE`, `Air`.
- **Accessors** `permittivity`, `permeability`, `conductivity`.
- **Utilities** `skindepth(frequency, material)` for conductors.
- **Notes** `PerfectlyMatchedLayer` wraps a dielectric and adds PML parameters.

**BoundaryConditions** (`src/boundaries.jl`)
- **Purpose** Field boundary condition types.
- **Types** Neumann, Dirichlet (parameterized by a temporal function), periodic, PEC, PMC, absorbing, and surface impedance.
- **Constructors** `DirichletBoundaryCondition(value)` and `SurfaceImpedance(value)` wrap scalars as constant temporal functions.
- **Notes** Periodic boundary conditions are validated against the problem domain in `BoundaryValueProblem`.

**ParticleBoundaries** (`src/boundaries.jl`)
- **Purpose** Particle boundary behaviors applied per axis for selected species.
- **Types** Reflecting, periodic, absorbing, and emitting boundaries with `particles` lists and optional `product` for emission.
- **Constructors** Each boundary accepts `particles...` and expands to a vector; empty lists are auto-filled by `ParticleProblem` when assigned.

**Collisions** (`src/collisions.jl`)
- **Purpose** Encode particle-fluid collision processes and scattering models.
- **Scattering types** Isotropic, backward, Vahedi, Opal.
- **Collision types** Elastic, excitation, ionization, charge-transfer.
- **Factory functions** `ElasticCollision`, `ExcitationCollision`, `IonizationCollision`, `ChargeTransferCollision` build collisions from datasets and enforce process-specific rules.
- **Notes** Opal scattering is restricted to ionization and requires `Constants.Ebar` for the target fluid.

**Distributions** (`src/distributions.jl`)
- **Purpose** Position and velocity distribution tags for particle seeding.
- **Velocity** `MaxwellBoltzmannDistribution{T,M}`.
- **Position tags** `UniformDistribution`, `GaussianSeedDistribution`.
- **FunctionDistribution** `FunctionDistribution(f; sampling=RejectionSampling())` seeds positions from an arbitrary density `f`, with `sampling` selecting `RejectionSampling` or `QuietStartSampling` (subtypes of `SamplingMode`).
- **PrecomputedPositions** `PrecomputedPositions(x)` carries an explicit `Vector{Float64}` of positions for deterministic loading.

**InterfaceConditions** (`src/interfaces.jl`)
- **Purpose** Interface conditions and detection for dielectric boundaries on axisymmetric grids.
- **Types** `DielectricInterface{EPS1,EPS2,SIG}`.
- **Functions** `interface(mat1, mat2)` produces an interface condition; `detect_interface_z!` and `detect_interface_r!` scan material grids to label interface edges.
- **Notes** If two adjacent materials are not both known dielectrics, edges are labeled as PEC.

**Sources** (`src/sources.jl`)
- **Purpose** Field sources, ports, and particle injection/initialization.
- **Ports** `CoaxialPort`, `WaveguidePort` (with `TM01` and `TEM` modes), `UniformPort`, `CurrentSource`.
- **Species sources** `ParticleSource` and `ParticleLoader` with position and velocity distributions plus drift vectors.
- **Fluid loader** `FluidLoader` for uniform density/temperature initialization.
- **Notes** Constructors default to Maxwell-Boltzmann velocity distributions when only a position distribution is provided. A `ParticleLoader` seeded with `PrecomputedPositions` asserts that the position count matches `count`.

**Circuit** (`src/circuit.jl`)
- **Purpose** Lumped circuit elements as boundary conditions and ports.
- **Types** `LumpedElement{T}` for `R`, `L`, `C` and `LumpedPort` for terminals and optional excitation.
- **Constructors** `Resistor`, `Inductor`, `Capacitor`, and `LumpedPort`.

**Domains** (`src/domains.jl`, `src/domains/1d.jl`, `src/domains/2d.jl`, `src/domains/zr.jl`)
- **Purpose** Define spatial extents and material layouts.
- **Core type** `Domain{D,CS}` with `mins`, `maxs`, and `materials` (shape to material pairs).
- **Dynamic accessors** `xmin`, `xmax`, `ymin`, `ymax`, `zmin`, `zmax`, `rmin`, `rmax` via `getproperty`.
- **Boundary check** `isboundary(domain, segment)` tests if a segment lies on the outer domain boundary.
- **Domain1D** `Domain1D(xmin, xmax, material)` builds a 1D segment region and supports material assignment via `setindex!`.
- **Domain2D** `Domain2D(xmax, ymax, material; xmin=0, ymin=0)` builds a cartesian rectangle; includes an alternate constructor for explicit min/max tuples.
- **AxisymmetricDomain** `AxisymmetricDomain(zmax, rmax, material; zmin=0, rmin=0)` builds a ZR rectangle and supports segment containment checks for constraints.

**Grids** (`src/grid.jl`, `src/grids/1d.jl`, `src/grids/2d.jl`, `src/grids/zr.jl`)
- **Purpose** Discretize domains and provide coordinate grids for models.
- **Core type** `Grid{D,CS}` stores coordinate arrays, spacings, and node counts.
- **Dynamic accessors** `x`, `y`, `z`, `r`, `nx`, `ny`, `nz`, `nr`, `dx`, `dy`, `dz`, `dr` via `getproperty`.
- **Grid1D** `discretize(domain, nx)` builds a 1D grid; `snap_node` maps a point to the nearest grid index.
- **Grid2D** `discretize(domain, nx, ny)` builds cartesian grids; `discretize!` tags nodes by shapes; `snap_node` and `snap_boundary` find the closest nodes/edges.
- **AxisymmetricGrid** `discretize(domain, nz, nr)` builds ZR grids; `snap_node` and `snap_boundary` are specialized for axisymmetric coordinates.

**Problems** (`src/problems.jl`, `src/problems/bval.jl`, `src/problems/part.jl`, `src/problems/coll.jl`)
- **Purpose** High-level problem definitions that connect domains with constraints, species, and sources.
- **BoundaryValueProblem** Stores a domain and boundary constraints; validates periodic constraints only on domain boundaries.
- **ParticleProblem** Stores a domain, particle set, particle boundaries, sources, and loaders; enforces that only registered species are used.
- **ParticleCollisionProblem** Combines particle and fluid species with collisions and fluid loaders; defines `+` to add collision processes.

**Models** (`src/models.jl`, `src/models/fdtd.jl`, `src/models/fdm.jl`, `src/models/pic.jl`, `src/models/fem.jl`, `src/models/mcc.jl`)
- **Purpose** Convert problems into grid-based or particle-based model representations.
- **FDTDModel** Builds a ZR grid, tags material nodes and interface edges, and maps boundary conditions to edge indices; detects dielectric interfaces automatically.
- **FDMModel** Builds 1D or 2D grids, tags materials, and maps Dirichlet/Neumann/Periodic constraints onto nodes and edges; translates PEC and PMC to Dirichlet and Neumann.
- **PICModel** Builds a particle-in-cell model from `ParticleProblem` or `ParticleCollisionProblem`; requires per-species `weights` and `maxcount` dictionaries.
- **FEMModel** Placeholder type for finite element support.
- **MCCModel** Assembles particle and fluid sets and collision lists for Monte Carlo collisions from `ParticleCollisionProblem`.

**SVG** (`src/plots.jl`)
- **Purpose** Visualization utilities for domains and models, built on `NativeSVG`.
- **Types** `Figure` with extensive styling configuration (size, margins, axes, colormap).
- **Rendering** `svg(figure)` returns an SVG; `save(svg, filename)` writes to disk.
- **Supported inputs** `BoundaryValueProblem{2,:ZR}`, `FDTDModel{2,:ZR}`, `FDMModel{2,:ZR}` with axisymmetric layouts.
- **Notes** The `SVG` module includes shape definitions for rectangles, circles, polygons, and composite shapes, plus domain and grid visualization helpers.

## Data, examples, and scripts

**Data** (`data/`)
- Cross section datasets loaded by `CrossSections`: `Biagi-7.1.jld2`, `Biagi-8.97.jld2`, and `Phelps.jld2`.

**Examples** (`examples/`)
- End-to-end simulation setups for waveguides, coaxial lines, two-stream instabilities, and Townsend coefficient calculations.

**Scripts** (`scripts/`)
- Additional case studies and configuration scripts, often mirroring the examples with more parameters.

**Plots** (`plots/`)
- Default output directory for SVG renders.

## Suggested workflows

- Build field problems with `Domains`, `Materials`, and `BoundaryConditions`, then create a `BoundaryValueProblem` and feed it to `FDMModel` or `FDTDModel`.
- Build particle problems with `Species`, `Sources`, and `ParticleProblem`, then create a `PICModel` (optionally `MCCModel` if collisions are included).
- Use `SVG` rendering to visualize domain layouts and boundary conditions in axisymmetric ZR configurations.
