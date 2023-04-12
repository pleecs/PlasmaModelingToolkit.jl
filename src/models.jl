module Models
import ..BoundaryConditions: BoundaryCondition
import ..Geometry: Shape, Rectangle, Segment
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

struct FDMModel <: AbstractModel end
struct PICModel <: AbstractModel end
struct FEMModel <: AbstractModel end
end