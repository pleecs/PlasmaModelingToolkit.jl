const FDTDCondition = Union{BoundaryCondition, InterfaceCondition}

struct FDTDModel{D, CS} <: DiscretizedModel
	grid :: Grid{D, CS}
	materials :: Dict{Material, UInt8}
	conditions :: Dict{Condition, UInt8}
	edge_boundary :: NTuple{D, Array{UInt8, D}} # TODO: check if right definition
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
	
	materials[Conductor()] = 0x00
	for (shape, material) in problem.domain.materials
		get!(materials, material, length(materials) + 1)
		discretize!(node_material, grid, shape, materials[material])
	end
	
	fdtd =  FDTDModel{2, :ZR}(grid, materials, conditions, edge_boundary, node_material)
	
	for (region, constraint) in problem.constraints
		fdtd[region] = constraint
	end

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
	
	return fdtd
end

function setindex!(model::FDTDModel{2,:ZR}, bc::BoundaryCondition, segment::Segment2D)
	grid = model.grid
	cond = model.conditions
	get!(cond, bc, length(cond) + 1)
	node_material = model.node_material
	z_edges, r_edges = model.edge_boundary

	is, js = snap(node_material, grid, segment; extend=true)
	
	if first(is) == last(is) && first(js) < last(js)
		Z0 = first(is)
		R1 = first(js)
		R2 = last(js)
		for j=R1:R2-1, i=Z0
			r_edges[i,j] = cond[bc]
		end
	end

    if first(is) < last(is) && first(js) == last(js)
		Z1 = first(is)
		Z2 = last(is)
		R0 = first(js)
		for j=R0, i=Z1:Z2-1
			z_edges[i,j] = cond[bc]
		end
	end
end