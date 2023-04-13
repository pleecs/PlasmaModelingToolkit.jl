module Models
import ..BoundaryConditions: BoundaryCondition, DirichletBoundaryCondition
import ..Grid: AbstractGrid, AxisymmetricGrid
import ..Domains: AxisymmetricDomain
import ..Geometry: Shape, Segment
import ..Materials: Material

import Base: setindex!

abstract type AbstractModel end

struct FDTDModel{G <: AbstractGrid} <: AbstractModel
	grid :: G
	materials :: Vector{Material}
	boundaries :: Vector{BoundaryCondition}
	edge_boundary :: NTuple{2, Matrix{UInt8}}
	node_material :: Matrix{UInt8}
end

function FDTDModel(domain::AxisymmetricDomain, NZ, NR)
	grid = discretize(domain, NZ, NR)
	
	materials = Material[]
	boundaries = BoundaryCondition[]
	z_edge_boundary = zeros(UInt8, NZ-1, NR)
	r_edge_boundary = zeros(UInt8, NZ, NR-1)
	node_material = zeros(UInt8, NZ, NR)
	edge_boundary = z_edge_boundary, r_edge_boundary
	
	for (shape, material) in domain.materials
		push!(materials, material)
		discretize!(model.node_material, grid, shape, convert(UInt8, length(materials)))
	end

	return FDTDModel(grid, materials, boundaries, edge_boundary, node_material)
end

function setindex!(model::FDTDModel, bc::BoundaryCondition, segment::Segment)
	grid = model.grid
	bcs = model.boundaries
	id = convert(UInt8, length(bcs))
	discretize!(model.node_boundary, grid, segment, id)
end

struct FDMModel{G <: AbstractGrid} <: AbstractModel
	grid :: G
	materials :: Vector{Material}
	boundaries :: Vector{BoundaryCondition}
	node_boundary :: Matrix{UInt8}
	node_material :: Matrix{UInt8}
end

function FDMModel(domain::AxisymmetricDomain, NZ, NR; maxiter=1_000)
	grid = discretize(domain, NZ, NR)
	
	materials = Material[]
	boundaries = BoundaryCondition[]
	node_boundary = zeros(UInt8, NZ, NR)
	node_material = zeros(UInt8, NZ, NR)
	
	for (shape, material) in domain.materials
		push!(materials, material)
		discretize!(model.node_material, grid, shape, convert(UInt8, length(materials)))
	end

	return FDMModel(grid, materials, boundaries, node_boundary, node_material)
end

function setindex!(model::FDMModel, bc::BoundaryCondition, segment::Segment)
	grid = model.grid
	bcs = model.boundaries
	push!(bcs, bc)
	discretize!(model.node_boundary, grid, segment, convert(UInt8, length(bcs)))
	return nothing
end

function setindex!(model::FDMModel, dbc::DirichletBoundaryCondition, shape::Shape)
	grid = model.grid
	bcs = model.boundaries
	push!(bcs, bc)
	discretize!(model.node_boundary, grid, shape, convert(UInt8, length(bcs)))
	return nothing
end

struct PICModel <: AbstractModel end
struct FEMModel <: AbstractModel end
end