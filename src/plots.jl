module SVG
export Figure, save, svg
import NativeSVG

import ..Domains: AxisymmetricDomain
import ..Geometry: Rectangle, Circle, Polygon, Segment, CompositeShape, Shape
import ..Materials: Material, Medium, Conductor, Dielectric, PerfectlyMatchedLayer, Metal, Vacuum, PTFE, Air
import ..BoundaryConditions: PerfectMagneticConductor, PerfectElectricConductor, SurfaceImpedance, BoundaryCondition
import ..ParticleBoundaryConditions: ParticleBoundaryCondition
import PlasmaModelingToolkit.Sources: CoaxialPort

default_colormap = Dict(
	"Medium" => "blue",
	"PerfectlyMatchedLayer" => "green",
	"Conductor" => "goldenrod",
	"PerfectMagneticConductor" => "blue",
	"PerfectElectricConductor" => "#ff00ff",
	"SurfaceImpedance" => "orange",
	"CoaxialPort" => "orange",
	"Vacuum" => "green",
	"PTFE" => "beige",
	"Air" => "skyblue",
	"axis" => "black",
	"font" => "black"
	)

mutable struct Figure
	domain
	width :: Float64
	margin :: Dict
	offset :: Dict
	font :: Dict
	x_axis :: Dict
	y_axis :: Dict
	colormap :: Dict
	background :: Dict
end

function Figure(domain;
	width = 20,
	margin = Dict("top" => 2,"bottom" => 2, "left" => 2, "right" => 2),
	offset = Dict("top" => 0.5,"bottom" => 0.5, "left" => 0.5, "right" => 0.5),
	font = Dict("family" => "serif", "size" => 12),
	x_axis = Dict("ticks" => [], "stroke_width" => "1px", "label" => nothing, "label_offset" => 2, "start_from_zero" => false),
	y_axis = Dict("ticks" => [], "stroke_width" => "1px", "label" => nothing, "label_offset" => 2, "start_from_zero" => false),
	colormap = default_colormap,
	background = Dict("color" => "#f5f5f5")
	)

	return Figure(
		domain,
		width,
		margin,
		offset,
		font,
		x_axis,
		y_axis,
		colormap,
		background)
end

import Base: setproperty!
function setproperty!(f::Figure, s::Symbol, val::T) where{T<:Number}
    if (s == :offset) || (s == :margin)
        return setfield!(f, s, Dict("top" => val, "bottom" => val, "left" => val, "right" => val))
    else
        return setfield!(f, s, value)
    end
end


function color(m::Dielectric, colormap) 
	if m.id ==  0xff 
		return colormap["Vacuum"]
	elseif m.id == 0xfe
		return colormap["PTFE"]
	elseif m.id == 0xae
		return colormap["Air"]
	end
end

color(::Medium, colormap) = colormap["Medium"]
color(::PerfectlyMatchedLayer, colormap) = colormap["PerfectlyMatchedLayer"]
color(::Conductor, colormap) = colormap["Conductor"]
color(::PerfectMagneticConductor, colormap) = colormap["PerfectMagneticConductor"]
color(::PerfectElectricConductor, colormap) = colormap["PerfectElectricConductor"]
color(::SurfaceImpedance, colormap) = colormap["SurfaceImpedance"]
color(::CoaxialPort, colormap) = colormap["CoaxialPort"]

function draw(color::String, shape::Union{Rectangle, Circle, Polygon, CompositeShape})
	return NativeSVG.use(href="#$(objectid(shape))", fill=color)
end

function draw(color::String, shape::Segment)
	return NativeSVG.use(href="#$(objectid(shape))", stroke=color, stroke_width="1%")
end

function define(shape::Rectangle{X, Y, W, H}) where {X, Y, W, H}
	x, y, w, h = 1000 .* (X, Y, W, H)
	return NativeSVG.rect(id="$(objectid(shape))", x="$x", y="$y", width="$w", height="$h")
end

function define(shape::Circle{X, Y, R}) where {X, Y, R}
	x, y, r = 1000 .* (X, Y, R)
	return NativeSVG.circle(id="$(objectid(shape))", cx="$x", cy="$y", r="$r")
end

function define(polygon::Polygon)
	points = ""
	for segment in polygon.segments
		x,y,_,_ = typeof(segment).parameters
		x,y = 1000 .* (x,y)
		points *= "$x,$y " 
	end
	return NativeSVG.polygon(id="$(objectid(polygon))", points=points)
end

function define(shape::Segment{X1,Y1,X2,Y2}) where {X1,Y1,X2,Y2}
	x1,y1,x2,y2 = 1000 .* (X1,Y1,X2,Y2)
	return NativeSVG.line(id="$(objectid(shape))", x1="$x1", y1="$y1", x2="$x2", y2="$y2")
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

function generate_svg(domain::AxisymmetricDomain, colormap)
	Z = (domain.zmax - domain.zmin) * 1000

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
			draw(color(material, colormap), shape)
		end

		for (segment, bc) in domain.bcs
			draw(color(bc, colormap), segment)
		end
	end
end

function get_domain_size(domain::AxisymmetricDomain, desired_width)
	ldW = domain.rmax * 1000
	ldH = domain.zmax * 1000
	gdW = float(desired_width)
	gdH = desired_width * (ldH / ldW)

	return gdW, gdH, ldW, ldH
end

function save(fig::NativeSVG.SVG, filename="domain.svg")
	write("plots/$filename", fig )
end

function svg(f::Figure)

	domain_width = f.width - f.offset["left"] - f.offset["right"] - f.margin["left"] - f.margin["right"]

	@assert domain_width > 0 "Margins and offsets are too large!"

	gdW, gdH, ldW, ldH = get_domain_size(f.domain, domain_width)

	W = f.width
	H = gdH + f.offset["top"] + f.offset["bottom"] + f.margin["top"] + f.margin["bottom"] 
 
	NativeSVG.SVG(width="$(W)cm", height="$(H)cm") do
		NativeSVG.defs() do
			# background
			NativeSVG.rect(id="background", width="$(W)cm", height="$(H)cm", fill=f.background["color"])

			# arrowheads
			NativeSVG.polygon(id="x_arrowhead", points="0,-5 8.7,0 0,5", fill=f.colormap["axis"])
			NativeSVG.polygon(id="y_arrowhead", points="-5,0 5,0 0,-8.7", fill=f.colormap["axis"])

			# tick mark
			NativeSVG.line(id="x_tick", x1="0", y1="5", x2="0", y2="-5", stroke=f.colormap["axis"], stroke_width=f.y_axis["stroke_width"])
			NativeSVG.line(id="y_tick", x1="5", y1="0", x2="-5", y2="0", stroke=f.colormap["axis"], stroke_width=f.x_axis["stroke_width"])


			# labels
			if !isnothing(f.y_axis["label"])
				NativeSVG.text(id="y_axis_label", text_anchor="middle", font_size="$(f.font["size"])pt", font_family="$(f.font["family"])", transform="rotate(-90)") do
					NativeSVG.str(f.y_axis["label"])
				end
			end

			if !isnothing(f.x_axis["label"])
				NativeSVG.text(id="x_axis_label", text_anchor="middle", font_size="$(f.font["size"])pt", font_family="$(f.font["family"])") do
					NativeSVG.str(f.x_axis["label"])
				end
			end

		end

		# background
		NativeSVG.use(href="#background")

		# vertical axis
		NativeSVG.g() do
			x = f.margin["left"]
			y = f.margin["top"]
			NativeSVG.use(href="#y_arrowhead", x="$(x)cm", y="$(y)cm")

			x1 = x2 = f.margin["left"]
			y1 = f.margin["top"]
			y2 = f.margin["top"] + f.offset["top"] + gdH
			y2 += f.y_axis["start_from_zero"] ? 0 : f.offset["bottom"]
			NativeSVG.line(x1="$(x1)cm", x2="$(x2)cm", y1="$(y1)cm", y2="$(y2)cm", stroke=f.colormap["axis"], stroke_width=f.y_axis["stroke_width"])
			
			if !isempty(f.y_axis["ticks"])
				ticks = f.y_axis["ticks"]
				gticks = (ticks ./ ldW) * gdW * 1000
				for i in 1:length(ticks)
					x = f.margin["left"]
					y = f.margin["top"] + f.offset["top"] + gdH - gticks[i]
					NativeSVG.use(href="#y_tick", x="$(x)cm", y="$(y)cm")

					x = f.margin["left"] - 0.3
					y = f.margin["top"] + f.offset["top"] + gdH - gticks[i] + (f.font["size"]/2 * 0.02) # FIXME: eye-ball
					NativeSVG.text(x="$(x)cm", y="$(y)cm", text_anchor="end", font_size="$(f.font["size"])pt", font_family="$(f.font["family"])") do
						NativeSVG.str("$(ticks[i])")
					end
				end
			end

			if !isnothing(f.y_axis["label"])
				x = f.margin["left"] - f.y_axis["label_offset"]
				y = f.margin["top"] + f.offset["top"] + gdH/2
				NativeSVG.use(href="#y_axis_label", x="$(x)cm", y="$(y)cm")
			end
		end

		# horizontal axis
		NativeSVG.g() do
			x = f.margin["left"] + f.offset["left"] + gdW + f.offset["right"]
			y = f.margin["top"] + f.offset["top"] + gdH + f.offset["bottom"]
			NativeSVG.use(href="#x_arrowhead", x="$(x)cm", y="$(y)cm")

			x1 = f.margin["left"]
			x1 += f.x_axis["start_from_zero"] ? f.offset["left"] : 0
			x2 = f.margin["left"] + f.offset["left"] + gdW + f.offset["right"]
			y1 = y2 = f.offset["top"] + f.margin["top"] + gdH + f.offset["bottom"]
			NativeSVG.line(x1="$(x1)cm", x2="$(x2)cm", y1="$(y1)cm", y2="$(y2)cm", stroke=f.colormap["axis"], stroke_width=f.x_axis["stroke_width"])

			if !isempty(f.x_axis["ticks"])
				ticks = f.x_axis["ticks"]
				gticks = (ticks ./ ldH) * gdH * 1000
				for i in 1:length(ticks)
					x = f.margin["left"] + f.offset["left"] + gticks[i]
					y = f.margin["top"] + f.offset["top"] + gdH + f.offset["bottom"]
					NativeSVG.use(href="#x_tick", x="$(x)cm", y="$(y)cm")

					y += f.font["size"] * 0.02 + 0.3 # FIXME: eye-ball
					NativeSVG.text(x="$(x)cm", y="$(y)cm", text_anchor="middle", font_size="$(f.font["size"])pt", font_family=f.font["family"]) do
						NativeSVG.str("$(ticks[i])")
					end
				end
			end

			if !isnothing(f.x_axis["label"])
				x = f.margin["left"] + f.offset["left"] + gdW/2
				y = f.margin["top"] + f.offset["top"] + gdH + f.x_axis["label_offset"]
				NativeSVG.use(href="#x_axis_label", x="$(x)cm", y="$(y)cm")
			end
		end

		x = f.margin["left"] + f.offset["left"]
		y = f.margin["top"] + f.offset["top"]
		NativeSVG.svg(x="$(x)cm", y="$(y)cm", width="$(gdW)cm", height="$(gdH)cm", viewBox="0 0 $ldW $ldH") do 
			generate_svg(f.domain, f.colormap)
		end
	end
end
end