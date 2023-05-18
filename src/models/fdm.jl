const FDMCondition = Union{NeumannBoundaryCondition, DirichletBoundaryCondition, PeriodicBoundaryCondition}

struct FDMModel{D, CS} <: DiscretizedModel
	grid :: Grid{D, CS}
	materials :: Dict{Material, UInt8}
	conditions :: Dict{FDMCondition, UInt8}
	node_boundary :: Array{UInt8, D}
	node_material :: Array{UInt8, D}
end

function FDMModel(problem::BoundaryValueProblem{D,CS}, args...) where {D,CS}
	grid = discretize(problem.domain, args...)
	
	materials = Dict{Material, UInt8}()
	conditions = Dict{FDMCondition, UInt8}()
	node_boundary = zeros(UInt8, args...)
	node_material = zeros(UInt8, args...)
	
	materials[Conductor()] = 0x00
	for (shape, material) in problem.domain.materials
		get!(materials, material, length(materials))
		discretize!(node_material, grid, shape, materials[material])
	end

	fdm = FDMModel{D,CS}(grid, materials, conditions, node_boundary, node_material)

	for (region, constraint) in problem.constraints
		fdm[region] = constraint
	end

	return fdm
end

function setindex!(model::FDMModel{2}, bc::FDMCondition, segment::Segment2D)
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

function setindex!(model::FDMModel{1}, dbc::DirichletBoundaryCondition, point::Point1D)
	nodes = model.node_material
	grid = model.grid
	bcs = model.conditions
	get!(bcs, dbc, length(bcs) + 1)

	i = snap(nodes, grid, point)
    model.node_boundary[i] = bcs[dbc]

	return nothing
end