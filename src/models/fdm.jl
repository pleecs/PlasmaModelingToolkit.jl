struct FDMModel <: DiscretizedModel
	grid :: AbstractGrid
	materials :: Dict{Material, UInt8}
	boundaries :: Dict{BoundaryCondition, UInt8}
	node_boundary :: Matrix{UInt8}
	node_material :: Matrix{UInt8}
end

function FDMModel(model::Model{AxisymmetricDomain}, NZ, NR)
	grid = discretize(domain, NZ, NR)
	
	materials = Dict{Material, UInt8}()
	boundaries = Dict{BoundaryCondition, UInt8}()
	node_boundary = zeros(UInt8, NZ, NR)
	node_material = zeros(UInt8, NZ, NR)
	
	for (shape, material) in domain.materials
		get!(materials, material, length(materials) + 1)
		discretize!(model.node_material, grid, shape, materials[material])
	end

	fdm = FDMModel{:ZR}(grid, materials, boundaries, node_boundary, node_material)

	for (region, constraint) in model.constraints
		model[region] = constraint
	end

	return fdm
end

function setindex!(model::FDMModel, bc::BoundaryCondition, segment::Segment)
	nodes = model.node_material
	grid = model.grid
	bcs = model.boundaries
	get!(bcs, bc, length(bcs) + 1)

	is, js = snap(nodes, grid, segment)
    for j=js, i=is
        model.node_boundary[i,j] = bcs[bc]
    end
	
	return nothing
end

function setindex!(model::FDMModel, dbc::DirichletBoundaryCondition, shape::Shape)
	grid = model.grid
	bcs = model.boundaries
	get!(bcs, dbc, length(bcs) + 1)
	discretize!(model.node_boundary, grid, shape, bcs[dbc])
	return nothing
end