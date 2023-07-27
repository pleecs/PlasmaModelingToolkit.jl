import ..Geometry: Shape1D, Segment1D
import ..Materials: Material
import Base: setindex!

const Domain1D = Domain{1, :X}
const OneDimensionalDomain = Domain{1, :X}

function Domain1D(xmin::Float64, xmax::Float64, material::Material)
  region = Segment1D(xmin, xmax)
  return Domain1D(tuple(xmin), tuple(xmax), [region => material])
end

function setindex!(domain::Domain1D, material::Material, shape::Shape1D)
  push!(domain.materials, shape => material)
end