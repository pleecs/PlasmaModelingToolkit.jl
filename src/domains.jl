module Domains
	import ..Geometry: Shape, Rectangle
	import ..Materials: Material
	export AxisymmetricDomain

	struct AxisymmetricDomain
		zmin :: Float64
		zmax :: Float64
		rmin :: Float64
		rmax :: Float64
		materials :: Dict{Shape, Material}
	end

	function AxisymmetricDomain(zmax::Float64, rmax::Float64, material::Material; rmin=0.0, zmin=0.0)
		AxisymmetricDomain((zmin, zmax), (rmin, rmax), material)
	end

	function AxisymmetricDomain((zmin, zmax), (rmin, rmax), material::Material)
		height = rmax - rmin
		width  = zmax - zmin
		region = Rectangle{zmin, rmin, width, height}()
		AxisymmetricDomain(zmin, zmax, rmin, rmax, Dict{Shape, Material}(region => material))
	end

	import Base: setindex!
	function setindex!(domain::AxisymmetricDomain, material::Material, shape::Shape)
		domain.materials[shape] = material
	end
end