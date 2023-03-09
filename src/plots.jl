module SVG
export figure, save
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
color(::PerfectElectricConductor) = "#ff00ff"
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

function define(shape::CompositeShape{+})
	NativeSVG.g(id="$(objectid(shape))") do
		NativeSVG.use(href="#$(objectid(shape.A))")
		NativeSVG.use(href="#$(objectid(shape.B))")
	end

	define(shape.A)
	define(shape.B)
end

function define(shape::CompositeShape{-})
	NativeSVG.g(id="$(objectid(shape))") do
		NativeSVG.mask(id="$(objectid(shape))-mask") do
			NativeSVG.use(href="#$(objectid(shape.A))", fill="white")
			NativeSVG.use(href="#$(objectid(shape.B))", fill="black")
		end
		NativeSVG.use(href="#$(objectid(shape.A))", mask="url(#$(objectid(shape))-mask)")
	end

	define(shape.A)
	define(shape.B)
end

function generate_svg(domain::AxisymmetricDomain)
	Z = (domain.zmax - domain.zmin)

	NativeSVG.defs() do
		for (shape, _) in domain.materials
			define(shape)
		end

		for (segment, _) in domain.bcs
			define(segment)
		end
	end

	NativeSVG.g(transform="rotate(-90 0 0) translate(-$Z)") do
		for (shape, material) in domain.materials
			draw(color(material), shape)
		end

		for (segment, bc) in domain.bcs
			draw(color(bc), segment)
		end
	end
end

function get_domain_size(domain::AxisymmetricDomain, desired_width)
	dW = (domain.rmax - domain.rmin)
	dH = (domain.zmax - domain.zmin)

	gW = float(desired_width)
	gH = desired_width * (dW / dH)

	return gW, gH, dW, dH
end

function save(fig::NativeSVG.SVG, filename="domain.svg")
	write(filename, fig )
end

function figure(domain, width=5)
	margin_top, margin_bottom, margin_right, margin_left = 2,2,8,2
	offset = 2

	# FIXME: swapped gH gW 
	gH, gW, dW, dH = get_domain_size(domain, width-2*offset-margin_left-margin_right)

	height = gH + 2*offset + margin_top + margin_bottom 

 
	NativeSVG.SVG(width="$(width)cm", height="$(height)cm") do
		# background
		NativeSVG.rect(width="$(width)cm", height="$(height)cm", fill="#f5f5f5")

		NativeSVG.defs() do
			NativeSVG.polygon(id="arrowhead_top", points="-5,0 5,0 0,-8.7", fill="black")
			NativeSVG.polygon(id="arrowhead_right", points="0,-5 8.7,0 0,5", fill="black")
		end

		# vertical axis
		NativeSVG.g() do
			NativeSVG.use(href="#arrowhead_top", x="$(margin_left)cm", y="$(margin_top)cm")
			NativeSVG.line(x1="$(margin_left)cm", x2="$(margin_left)cm", y1="$(margin_top)cm", y2="$(gH+2*offset+margin_top)cm", stroke="black", stroke_width="2px")
		end

		# horizontal axis
		NativeSVG.g() do
			NativeSVG.use(href="#arrowhead_right", x="$(gW+2*offset+margin_left)cm", y="$(gH+2*offset+margin_top)cm")
			NativeSVG.line(x1="$(margin_left)cm", x2="$(gW+2*offset+margin_left)cm", y1="$(gH+2*offset+margin_top)cm", y2="$(gH+2*offset+margin_top)cm", stroke="black", stroke_width="2px")
		end

		NativeSVG.svg(x="$(offset+margin_left)cm", y="$(offset+margin_top)cm", width="$(gW)cm", height="$(gH)cm", viewBox="0 0 $dW $dH") do 
			generate_svg(domain)
		end
	end

end
end