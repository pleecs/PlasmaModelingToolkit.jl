
import ..BoundaryConditions: BoundaryCondition
import ..InterfaceConditions: InterfaceCondition
import ..Grids: Grid, discretize, discretize!, snap_boundary
import ..Domains: AxisymmetricDomain, Domain1D
import ..Geometry: Shape2D, Segment2D, Rectangle, Segment1D, Point1D, Shape
import ..Materials: Material, IdealConductor, Dielectric, PerfectlyMatchedLayer
import ..Problems: BoundaryValueProblem
import ..InterfaceConditions: detect_interface_z!, detect_interface_r!
import Base: setindex!

const Condition = Union{BoundaryCondition, InterfaceCondition}

struct FDTDModel{D, CS}
	grid :: Grid{D, CS}
	materials :: Dict{Material, UInt8}
	conditions :: Dict{Condition, UInt8}
	edge_boundary :: NTuple{D, Array{UInt8, D}}
	node_material :: Array{UInt8, D}
end

function FDTDModel(problem::BoundaryValueProblem{2, :ZR}, NZ, NR)
	grid = discretize(problem.domain, NZ, NR)
	
	materials = Dict{Material, UInt8}()
	conditions = Dict{Condition, UInt8}()
	z_edge_boundary = zeros(UInt8, NZ-1, NR)
	r_edge_boundary = zeros(UInt8, NZ, NR-1)
	node_material = zeros(UInt8, NZ, NR)
	edge_boundary = z_edge_boundary, r_edge_boundary
	
	materials[IdealConductor()] = 0x00
	for (shape, material) in problem.domain.materials
		get!(materials, material, length(materials) + 1)
		discretize!(node_material, grid, shape, materials[material])
	end
	
	fdtd =  FDTDModel{2, :ZR}(grid, materials, conditions, edge_boundary, node_material)
	
	dielectrics = Dict{UInt8, Dielectric}()
	for (material, id) in materials
		if material isa Dielectric
			dielectrics[id] = material
		end

		if material isa PerfectlyMatchedLayer
			dielectrics[id] = material.dielectric
		end
	end

	detect_interface_z!(conditions, z_edge_boundary, node_material, dielectrics)
	detect_interface_r!(conditions, r_edge_boundary, node_material, dielectrics)
	
	for (region, constraint) in problem.constraints
		fdtd[region] = constraint
	end

	return fdtd
end

function setindex!(model::FDTDModel{2,:ZR}, bc::BoundaryCondition, segment::Segment2D)
	grid = model.grid
	cond = model.conditions
	get!(cond, bc, length(cond) + 1)
	node_material = model.node_material
	z_edges, r_edges = model.edge_boundary

	i1, j1 = snap_boundary(r_edges, grid, segment.p₁)
	i2, j2 = snap_boundary(r_edges, grid, segment.p₂)
	if i1 == i2 && j1 != j2
		Z0 = i1
		R1 = min(j1, j2)
		R2 = max(j1, j2)
		for j=R1:R2, i=Z0
			r_edges[i,j] = cond[bc]
		end
	end

	i1, j1 = snap_boundary(z_edges, grid, segment.p₁)
	i2, j2 = snap_boundary(z_edges, grid, segment.p₂)
	if i1 != i2 && j1 == j2
		Z1 = min(i1, i2)
		Z2 = max(i1, i2)
		R0 = j1
		for j=R0, i=Z1:Z2
			z_edges[i,j] = cond[bc]
		end
	end
end