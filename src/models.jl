module Models
import ..BoundaryConditions: BoundaryCondition, DirichletBoundaryCondition
import ..Grid: AbstractGrid, AxisymmetricGrid
import ..Domains: AxisymmetricDomain
import ..Geometry: Shape, Segment
import ..Materials: Material, Conductor

import ..Grid: discretize, discretize!, snap
import Base: setindex!

struct Model{D}
	domain :: D
	constraints :: Vector{Pair{Any, Any}}
	Model(domain) = new{typeof(domain)}(domain, [])
end

function setindex!(model::Model, constraint, region)
    push!(model.constraints, region => constraint)
end

abstract type DiscretizedModel end

struct FDTDModel{CS} <: DiscretizedModel
	grid :: AbstractGrid
	materials :: Dict{Material, UInt8}
	boundaries :: Dict{BoundaryCondition, UInt8}
	edge_boundary :: NTuple{2, Matrix{UInt8}}
	node_material :: Matrix{UInt8}
end

function FDTDModel(model::Model{AxisymmetricDomain}, NZ, NR)
	grid = discretize(model.domain, NZ, NR)
	
	materials = Dict{Material, UInt8}()
	boundaries = Dict{BoundaryCondition, UInt8}()
	z_edge_boundary = zeros(UInt8, NZ-1, NR)
	r_edge_boundary = zeros(UInt8, NZ, NR-1)
	node_material = zeros(UInt8, NZ, NR)
	edge_boundary = z_edge_boundary, r_edge_boundary
	
	materials[Conductor()] = 0x00
	for (shape, material) in model.domain.materials
		get!(materials, material, length(materials) + 1)
		discretize!(node_material, grid, shape, materials[material])
	end
	
	fdtd =  FDTDModel{:ZR}(grid, materials, boundaries, edge_boundary, node_material)
	
	for (region, constraint) in model.constraints
		fdtd[region] = constraint
	end
	return fdtd
end

function setindex!(model::FDTDModel, bc::BoundaryCondition, segment::Segment)
	grid = model.grid
	bcs = model.boundaries
	get!(bcs, bc, length(bcs) + 1)
	node_material = model.node_material
	z_edges, r_edges = model.edge_boundary

	is, js = snap(node_material, grid, segment; extend=true)
	
	if first(is) == last(is) && first(js) < last(js)
		Z0 = first(is)
		R1 = first(js)
		R2 = last(js)
		for j=R1:R2-1, i=Z0
			r_edges[i,j] = bcs[bc]
		end
	end

    if first(is) < last(is) && first(js) == last(js)
		Z1 = first(is)
		Z2 = last(is)
		R0 = first(js)
		for j=R0, i=Z1:Z2-1
			z_edges[i,j] = bcs[bc]
		end
	end
end

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

struct PICModel <: DiscretizedModel end
struct FEMModel <: DiscretizedModel end
end