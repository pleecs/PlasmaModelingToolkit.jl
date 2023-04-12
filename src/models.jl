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
	
end

function setindex!(model::FDTDModel, bc::BoundaryCondition, segment::Segment)
	push!(domain.bcs, segment => bc)
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
	return FDMModel(grid, materials, boundaries, node_boundary, node_material)
end

function setindex!(model::FDMModel, bc::BoundaryCondition, segment::Segment)
	grid = model.grid
	bcs = model.boundaries
	id = convert(UInt8, length(bcs))
	nz, nr = size(node_boundary)
	for j=1:nr, i=1:nz
		# ...
	end
	return nothing
end

function setindex!(model::FDMModel, dbc::DirichletBoundaryCondition, shape::Shape)
	grid = model.grid
	bcs = model.boundaries
	id = convert(UInt8, length(bcs))
	nz, nr = size(node_boundary)
	for j=1:nr, i=1:nz
		if (grid.z[i,j], grid.r[i,j]) ∈ shape
            node_boundary[i,j] = id
        end
	end
	return nothing
end

struct PICModel <: AbstractModel end
struct FEMModel <: AbstractModel end
end