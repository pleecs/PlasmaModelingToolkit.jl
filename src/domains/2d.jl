import ..Geometry: Shape2D, Segment2D
import ..Materials: Material
import Base: setindex!

const Domain2D = Domain{2, :XY}

function Domain2D(xmax::Float64, ymax::Float64, material::Material; xmin=0.0, ymin=0.0)
  height = ymax - ymin
  width  = xmax - xmin
  region = Rectangle(xmin, ymin, width, height)
  return Domain2D((xmin, ymin), (xmax,ymax), [region => material])
end

function Domain2D((xmin, xmax), (ymin, ymax), material::Material)
  height = ymax - ymin
  width  = xmax - xmin
  region = Rectangle(xmin, ymin, width, height)
  AxisymmetricDomain((xmin, ymin), (xmax, xmax), [region => material])
end

function setindex!(domain::Domain2D, material::Material, shape::Shape2D)
  push!(domain.materials, shape => material)
end