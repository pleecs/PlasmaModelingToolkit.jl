module Models
import ..BoundaryConditions: BoundaryCondition, DirichletBoundaryCondition
import ..Grid: AbstractGrid, AxisymmetricGrid
import ..Domains: AxisymmetricDomain
import ..Geometry: Shape, Segment
import ..Materials: Material, Conductor

import Base: setindex!

abstract type AbstractModel end

struct FDTDModel{G <: AbstractGrid} <: AbstractModel
	grid :: G
	materials :: Dict{Material, UInt8}
	boundaries :: Dict{BoundaryCondition, UInt8}
	edge_boundary :: NTuple{2, Matrix{UInt8}}
	node_material :: Matrix{UInt8}
end

function FDTDModel(domain::AxisymmetricDomain, NZ, NR)
	grid = discretize(domain, NZ, NR)
	
	materials = Dict{Material, UInt8}()
	boundaries = Dict{BoundaryCondition, UInt8}()
	z_edge_boundary = zeros(UInt8, NZ-1, NR)
	r_edge_boundary = zeros(UInt8, NZ, NR-1)
	node_material = zeros(UInt8, NZ, NR)
	edge_boundary = z_edge_boundary, r_edge_boundary
	
	materials[Conductor()] = 0x00
	for (shape, material) in domain.materials
		get!(materials, material, length(materials) + 1)
		discretize!(model.node_material, grid, shape, materials[material])
	end

	return FDTDModel(grid, materials, boundaries, edge_boundary, node_material)
end

function setindex!(model::FDTDModel, bc::BoundaryCondition, segment::Segment)
	grid = model.grid
	bcs = model.boundaries
	get!(bcs, bc, length(bcs) + 1)
	# segment should be potientially snapped base on model.node_material
	discretize!(model.edge_boundary, grid, segment, bcs[bc])
end

struct FDMModel{G <: AbstractGrid} <: AbstractModel
	grid :: G
	materials :: Dict{Material, UInt8}
	boundaries :: Dict{BoundaryCondition, UInt8}
	node_boundary :: Matrix{UInt8}
	node_material :: Matrix{UInt8}
end

function FDMModel(domain::AxisymmetricDomain, NZ, NR; maxiter=1_000)
	grid = discretize(domain, NZ, NR)
	
	materials = Dict{Material, UInt8}()
	boundaries = Dict{BoundaryCondition, UInt8}()
	node_boundary = zeros(UInt8, NZ, NR)
	node_material = zeros(UInt8, NZ, NR)
	
	for (shape, material) in domain.materials
		get!(materials, material, length(materials) + 1)
		discretize!(model.node_material, grid, shape, materials[material])
	end

	return FDMModel(grid, materials, boundaries, node_boundary, node_material)
end

function setindex!(model::FDMModel, bc::BoundaryCondition, segment::Segment)
	grid = model.grid
	bcs = model.boundaries
	get!(bcs, bc, length(bcs) + 1)
	discretize!(model.node_boundary, grid, segment, bcs[bc])
	return nothing
end

function setindex!(model::FDMModel, dbc::DirichletBoundaryCondition, shape::Shape)
	grid = model.grid
	bcs = model.boundaries
	get!(bcs, dbc, length(bcs) + 1)
	discretize!(model.node_boundary, grid, shape, bcs[dbc])
	return nothing
end

struct PICModel <: AbstractModel end
struct FEMModel <: AbstractModel end
end