import ..Geometry: Shape2D, Rectangle, Segment2D
import ..Materials: Material
import Base: ∈, setindex!

const AxisymmetricDomain = Domain{2, :ZR}

function AxisymmetricDomain(zmax::Float64, rmax::Float64, material::Material; rmin=0.0, zmin=0.0)
  AxisymmetricDomain((zmin, zmax), (rmin, rmax), material)
end

function AxisymmetricDomain((zmin, zmax), (rmin, rmax), material::Material)
  height = rmax - rmin
  width  = zmax - zmin
  region = Rectangle(zmin, rmin, width, height)
  AxisymmetricDomain((zmin, rmin), (zmax, rmax), [region => material])
end

function setindex!(domain::AxisymmetricDomain, material::Material, shape::Shape2D)
  push!(domain.materials, shape => material)
end

function ∈(segment::Segment2D, domain::AxisymmetricDomain)
  Z1, R1 = segment.p₁
  Z2, R2 = segment.p₂
  rect = Rectangle(domain.zmin, domain.rmin, (domain.rmax - domain.rmin), (domain.zmax - domain.zmin))
  return ((Z1,R1) ∈ rect) && ((Z2,R2) ∈ rect)
end