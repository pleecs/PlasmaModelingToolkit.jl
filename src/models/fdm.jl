struct FDMModel{D, CS} <: DiscretizedModel
	grid :: Grid{D, CS}
	materials :: Dict{Material, UInt8}
	conditions :: Dict{BoundaryCondition, UInt8}
	node_boundary :: Array{UInt8, D}
	node_material :: Array{UInt8, D}
end

function FDMModel(problem::BoundaryValueProblem{2, :ZR}, NZ, NR)
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

	fdm = FDMModel{2, :ZR}(grid, materials, conditions, node_boundary, node_material)

	for (region, constraint) in problem.constraints
		fdm[region] = constraint
	end

	return fdm
end

function setindex!(model::FDMModel{2, CS}, bc::NeumannBoundaryCondition, segment::Segment2D) where {CS}
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

function setindex!(model::FDMModel{2, CS}, dbc::DirichletBoundaryCondition, segment::Segment2D) where {CS}
	nodes = model.node_material
	grid = model.grid
	bcs = model.conditions
	get!(bcs, dbc, length(bcs) + 1)

	is, js = snap(nodes, grid, segment)
    for j=js, i=is
        model.node_boundary[i,j] = bcs[dbc]
    end

	return nothing
end

function setindex!(model::FDMModel{2, CS}, dbc::DirichletBoundaryCondition, shape::Shape2D) where {CS}
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

function setindex!(model::FDMModel{2, CS}, dbc::PeriodicBoundaryCondition, shape::Shape2D) where {CS}
	# TODO: add PeriodicBoundaryCondition handling
	return nothing
end

function FDMModel(problem::BoundaryValueProblem{1, :X}, nx)
	grid = discretize(problem.domain, nx)
	materials = Dict{Material, UInt8}()
	conditions = Dict{BoundaryCondition, UInt8}()
	node_boundary = zeros(UInt8, nx)
	node_material = zeros(UInt8, nx)
	
	materials[Conductor()] = 0x00
	for (shape, material) in problem.domain.materials
		get!(materials, material, length(materials))
		discretize!(node_material, grid, shape, materials[material])
	end

	fdm = FDMModel{1, :X}(grid, materials, conditions, node_boundary, node_material)

	for (region, constraint) in problem.constraints
		fdm[region] = constraint
	end

	return fdm
end

function setindex!(model::FDMModel{1, CS}, dbc::DirichletBoundaryCondition, segment::Segment1D) where {CS}
	nodes = model.node_material
	grid = model.grid
	bcs = model.conditions
	get!(bcs, dbc, length(bcs) + 1)

	is = snap(nodes, grid, segment)
    for i=is
        model.node_boundary[i] = bcs[dbc]
    end

	return nothing
end

function setindex!(model::FDMModel{1, CS}, dbc::DirichletBoundaryCondition, point::Point1D) where {CS}
	nodes = model.node_material
	grid = model.grid
	bcs = model.conditions
	get!(bcs, dbc, length(bcs) + 1)

	i = snap(nodes, grid, point)
    model.node_boundary[i] = bcs[dbc]

	return nothing
end