module SVG
import NativeSVG

import ..Domains: AxisymmetricDomain
import ..Geometry: Rectangle, Circle, Polygon, Segment, CompositeShape, Shape
import ..Materials: Material, Medium, Conductor, Dielectric, PerfectlyMatchedLayer, Metal, Vacuum, PTFE, Air
import ..BoundaryConditions: PerfectMagneticConductor, PerfectElectricConductor, SurfaceImpedance, BoundaryCondition
import ..ParticleBoundaryConditions: ParticleBoundaryCondition
import PlasmaModelingToolkit.Sources: CoaxialPort

function color(m::Dielectric) 
	if m.id ==  0xff #Vacuum
		return "green"
	elseif m.id == 0xfe #PTFE
		return "beige"
	elseif m.id == 0xae #Air
		return "skyblue"
	end
end

color(::Medium) = "blue"
color(::PerfectlyMatchedLayer) = "green"
color(::Conductor) = "goldenrod"
color(::PerfectMagneticConductor) = "blue"
color(::PerfectElectricConductor) = "green"
color(::SurfaceImpedance) = "orange"
color(::CoaxialPort) = "orange"

function draw(color::String, shape::Union{Rectangle, Circle, Polygon, CompositeShape})
	return NativeSVG.use(href="#$(objectid(shape))", fill=color)
end

function draw(color::String, shape::Segment)
	return NativeSVG.use(href="#$(objectid(shape))", stroke=color, stroke_width="1%")
end

function define(shape::Rectangle{X, Y, W, H}) where {X, Y, W, H}
	return NativeSVG.rect(id="$(objectid(shape))", x="$X", y="$Y", width="$W", height="$H")
end

function define(shape::Circle{X, Y, R}) where {X, Y, R}
	return NativeSVG.circle(id="$(objectid(shape))", cx="$X", cy="$Y", r="$R")
end

function define(polygon::Polygon)
	points = ""
	for segment in polygon.segments
		x,y,_,_ = typeof(segment).parameters
		points *= "$x,$y " 
	end
	return NativeSVG.polygon(id="$(objectid(polygon))", points=points)
end

function define(shape::Segment{X1,Y1,X2,Y2}) where {X1,Y1,X2,Y2}
	return NativeSVG.line(id="$(objectid(shape))", x1="$X1", y1="$Y1", x2="$X2", y2="$Y2")
end

function define(shape::CompositeShape{OPERATOR}) where {OPERATOR}
	if OPERATOR == +
		def = NativeSVG.g(id="$(objectid(shape))") do
			NativeSVG.use(href="#$(objectid(shape.A))")
			NativeSVG.use(href="#$(objectid(shape.B))")
		end
	elseif OPERATOR == -
		def = NativeSVG.g(id="$(objectid(shape))") do
			NativeSVG.mask(id="$(objectid(shape))-mask") do
				NativeSVG.use(href="#$(objectid(shape.A))", fill="white")
				NativeSVG.use(href="#$(objectid(shape.B))", fill="black")
			end
			NativeSVG.use(href="#$(objectid(shape.A))", mask="url(#$(objectid(shape))-mask)")
		end
	end

	define(shape.A)
	define(shape.B)

	return def
end


function draw!(domain::AxisymmetricDomain; filename="domain.svg")

	height = (domain.rmax - domain.rmin)
	width = (domain.zmax - domain.zmin)

	W = 1000
	H = (1000/width) * height

	domain = NativeSVG.SVG(width=H, height=W, viewBox="0 0 $height $width") do 

		NativeSVG.defs() do
			for (shape, _) in domain.materials
				define(shape)
			end

			for (segment, _) in domain.bcs
				define(segment)
			end
		end

		NativeSVG.g(transform="rotate(-90 0 0) translate(-$width)") do
			for (shape, material) in domain.materials
				draw(color(material), shape)
			end

			for (segment, bc) in domain.bcs
				draw(color(bc), segment)
			end
		end
	end

	write(filename, domain)
end
end