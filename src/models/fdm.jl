struct FDMModel{CS} <: DiscretizedModel
	grid :: AbstractGrid
	materials :: Dict{Material, UInt8}
	conditions :: Dict{BoundaryCondition, UInt8}
	node_boundary :: Matrix{UInt8}
	node_material :: Matrix{UInt8}
end

function FDMModel(problem::BoundaryValueProblem{AxisymmetricDomain}, NZ, NR)
	grid = discretize(problem.domain, NZ, NR)
	
	materials = Dict{Material, UInt8}()
	conditions = Dict{BoundaryCondition, UInt8}()
	node_boundary = zeros(UInt8, NZ, NR)
	node_material = zeros(UInt8, NZ, NR)
	
	materials[Conductor()] = 0x00
	for (shape, material) in problem.domain.materials
		get!(materials, material, length(materials))
		discretize!(node_material, grid, shape, materials[material])
	end

	fdm = FDMModel{:ZR}(grid, materials, conditions, node_boundary, node_material)

	for (region, constraint) in problem.constraints
		fdm[region] = constraint
	end

	return fdm
end

function setindex!(model::FDMModel, bc::BoundaryCondition, segment::Segment)
	nodes = model.node_material
	grid = model.grid
	bcs = model.conditions
	get!(bcs, bc, length(bcs) + 1)

	is, js = snap(nodes, grid, segment)
    for j=js, i=is
        model.node_boundary[i,j] = bcs[bc]
    end
	
	return nothing
end

function setindex!(model::FDMModel, dbc::DirichletBoundaryCondition, shape::Shape)
	grid = model.grid
	bcs = model.conditions
	get!(bcs, dbc, length(bcs) + 1)

	nz, nr = size(grid.z)
	for j=1:nr, i=1:nz
		if (grid.z[i,j], grid.r[i,j]) ∈ shape && (model.node_material[i,j] == 0x00)
			model.node_boundary[i,j] = bcs[dbc]
		end
	end

	return nothing
end