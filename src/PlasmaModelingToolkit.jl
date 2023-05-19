module PlasmaModelingToolkit
function ++(code::Expr, block::Expr)
  push!(code.args, block)
  return code
end

include("units.jl")
include("constants.jl")
include("atoms.jl")
include("crosssections.jl")
include("species.jl")
include("geometry.jl")
include("temporal.jl")
include("materials.jl")
include("boundaries.jl")
include("collisions.jl")
include("distributions.jl")
include("interfaces.jl")
include("sources.jl")
include("domains.jl")
include("grid.jl")
include("problems.jl")
include("models.jl")
include("plots.jl")
end

