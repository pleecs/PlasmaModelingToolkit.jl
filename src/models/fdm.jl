import ..BoundaryConditions: NeumannBoundaryCondition, DirichletBoundaryCondition, PeriodicBoundaryCondition
import ..BoundaryConditions: PerfectElectricConductor, PerfectMagneticConductor
import ..Grids: Grid
import ..Geometry: Segment2D, Point1D, ∥
import ..Materials: Material, IdealConductor
import ..Problems: BoundaryValueProblem
import ..Grids: discretize, discretize!, snap_node
import Base: setindex!

const FDMCondition = Union{NeumannBoundaryCondition, DirichletBoundaryCondition, PeriodicBoundaryCondition}

struct FDMModel{D, CS}
  grid :: Grid{D, CS}
  materials :: Dict{Material, UInt8}
  conditions :: Dict{FDMCondition, UInt8}
  edge_boundary :: NTuple{D, Array{UInt8, D}}
  node_material :: Array{UInt8, D}
end

function FDMModel(problem::BoundaryValueProblem{D,CS}, args...) where {D,CS}
  grid = discretize(problem.domain, args...)
  materials = Dict{Material, UInt8}()
  conditions = Dict{FDMCondition, UInt8}()
  node_material = zeros(UInt8, args...)
  if D == 1
    edge_boundary = (zeros(args...),)
  else
    edge_boundary = NTuple{D,Array{UInt8,D}}([zeros([i==d ? arg-1 : arg for (i,arg) in enumerate(args)]...) for d in 1:D])
  end

  materials[IdealConductor()] = 0x00
  for (shape, material) in problem.domain.materials
    get!(materials, material, length(materials))
    discretize!(node_material, grid, shape, materials[material])
  end

  fdm = FDMModel{D,CS}(grid, materials, conditions, edge_boundary, node_material)

  for (region, constraint) in problem.constraints
    fdm[region] = constraint
  end

  return fdm
end

function setindex!(model::FDMModel{2,:XY}, bc::FDMCondition, segment::Segment2D)
  grid = model.grid
  bcs = model.conditions
  get!(bcs, bc, length(bcs) + 1)
  
  if segment ∥ :X
    @views edges = model.edge_boundary[1]
    i₁, j₁ = snap_boundary(edges, grid, segment.p₁) 
    i₂, j₂ = snap_boundary(edges, grid, segment.p₂)
    
    @assert j₁ == j₂ && i₁ != i₂

    for i=min(i₁, i₂):max(i₁, i₂)
      edges[i,j₁] = bcs[bc]
    end
  elseif segment ∥ :Y
    @views edges = model.edge_boundary[2]
    i₁, j₁ = snap_boundary(edges, grid, segment.p₁)
    i₂, j₂ = snap_boundary(edges, grid, segment.p₂)
    
    @assert i₁ == i₂ && j₁ != j₂

    for j=min(j₁, j₂):max(j₁, j₂)
      edges[i₁,j] = bcs[bc]
    end
  end
end

# TODO: needs rework after switching from node_boundary to edge_boundary
# function setindex!(model::FDMModel{2}, bc::FDMCondition, segment::Segment2D)
#   nodes = model.node_material
#   grid = model.grid
#   bcs = model.conditions
#   get!(bcs, bc, length(bcs) + 1)

#   i1, j1 = snap_node(grid, segment.p₁)
#   i2, j2 = snap_node(grid, segment.p₂)
  
#   for j=min(j1,j2):max(j1,j2), i=min(i1,i2):max(i1,i2)
#     model.node_boundary[i,j] = bcs[bc]
#   end
  
#   return nothing
# end

# translate PEC/PMC into DBC/NBC
setindex!(model::FDMModel{2}, ::PerfectElectricConductor, segment::Segment2D) =
  setindex!(model, DirichletBoundaryCondition(0.0), segment)
setindex!(model::FDMModel{2}, ::PerfectMagneticConductor, segment::Segment2D) =
  setindex!(model, NeumannBoundaryCondition(), segment)

# TODO: needs rework after switching from node_boundary to edge_boundary
# # model[shape => material] = DirichletBoundaryCondition(potential)
# function setindex!(model::FDMModel{2,:ZR}, dbc::DirichletBoundaryCondition, pair::Pair{S, M}) where {S<:Shape2D, M<:Material}
#   grid = model.grid
#   bcs = model.conditions
#   get!(bcs, dbc, length(bcs) + 1)

#   shape, material = pair
#   mid = model.materials[material]

#   nz, nr = size(grid.z)
#   for j=1:nr, i=1:nz
#     if (grid.z[i,j], grid.r[i,j]) ∈ shape && (model.node_material[i,j] == mid)
#       model.node_boundary[i,j] = bcs[dbc]
#     end
#   end

#   return nothing
#  end

function setindex!(model::FDMModel{1}, bc::FDMCondition, point::Point1D)
  nodes = model.node_material
  grid = model.grid
  bcs = model.conditions
  get!(bcs, bc, length(bcs) + 1)

  i = snap_node(grid, point)
  model.edge_boundary[i] = bcs[bc]

  return nothing
end