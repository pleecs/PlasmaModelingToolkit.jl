module Domains
	import ..Geometry: Shape, Rectangle, Segment
	import ..Materials: Material
	import ..BoundaryConditions: BoundaryCondition
	import ..ParticleBoundaryConditions: ParticleBoundaryCondition
	export AxisymmetricDomain
	import Base: ∈

	struct AxisymmetricDomain
		zmin :: Float64
		zmax :: Float64
		rmin :: Float64
		rmax :: Float64
		materials :: Vector{Pair{Shape, Material}}
		bcs :: Dict{Shape, Union{BoundaryCondition, ParticleBoundaryCondition}} 
	end

	function AxisymmetricDomain(zmax::Float64, rmax::Float64, material::Material; rmin=0.0, zmin=0.0)
		AxisymmetricDomain((zmin, zmax), (rmin, rmax), material)
	end

	function AxisymmetricDomain((zmin, zmax), (rmin, rmax), material::Material)
		height = rmax - rmin
		width  = zmax - zmin
		region = Rectangle{zmin, rmin, width, height}()
		AxisymmetricDomain(zmin, zmax, rmin, rmax, [region => material], Dict())
	end

	import Base: setindex!
	function setindex!(domain::AxisymmetricDomain, material::Material, shape::Shape)
        push!(domain.materials, shape => material)
	end

	function setindex!(domain::AxisymmetricDomain, bc::Union{ParticleBoundaryCondition, BoundaryCondition}, segment::Segment)
		domain.bcs[segment] = bc
	end

	function ∈(segment::Segment{Z1, R1, Z2, R2}, domain::AxisymmetricDomain) where {Z1, R1, Z2, R2}
		rect = Rectangle{domain.zmin, domain.rmin, (domain.rmax - domain.rmin), (domain.zmax - domain.zmin)}()
		return ((Z1,R1) ∈ rect) && ((Z2,R2) ∈ rect)
	end

end