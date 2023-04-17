module SVG
export Figure, save, svg
import NativeSVG

import ..Models: Model
import ..Domains: AbstractDomain, AxisymmetricDomain
import ..Geometry: Rectangle, Circle, Polygon, Segment, CompositeShape, Shape
import ..Materials: Material, Medium, Conductor, Dielectric, PerfectlyMatchedLayer, Metal, Vacuum, PTFE, Air
import ..BoundaryConditions: PerfectMagneticConductor, PerfectElectricConductor, SurfaceImpedance, BoundaryCondition
import ..BoundaryConditions: ParticleBoundaryCondition
import ..Sources: CoaxialPort, WaveguidePort, UniformPort
import ..Constants: ε_0, μ_0

default_colormap = Dict(
	"PerfectlyMatchedLayer" => "#9D9D9D",
	"Conductor" => "#50514F",
	"PerfectMagneticConductor" => "#247BA0",
	"PerfectElectricConductor" => "#F25F5C",
	"SurfaceImpedance" => "#FFE066",
	"CoaxialPort" => "#70C1B3",
	"WaveguidePort" => "#70C1B3",
	"UniformPort" => "#70C1B3",
	"Vacuum" => "#FFFFFF",
	"PTFE" => "#B1B1B1",
	"Air" => "#8EB1C7",
	"axis" => "#2D3142",
	"font" => "#2D3142",
	"normals" => "#2D3142"
	)

mutable struct Figure{D}
	model :: Model{D}
	width :: Float64
	margin :: Dict
	offset :: Dict
	font :: Dict
	x_axis :: Dict
	y_axis :: Dict
	colormap :: Dict
	background :: Dict
	normals :: Dict
end

function Figure(model::Model{AxisymmetricDomain};
	width = 20,
	margin = Dict("top" => 2.,"bottom" => 2., "left" => 2., "right" => 2.),
	offset = Dict("top" => 0.5,"bottom" => 0.5, "left" => 0.5, "right" => 0.5),
	font = Dict("family" => "serif", "size" => 12),
	x_axis = Dict("ticks" => [], "stroke_width" => 1, "label" => nothing, "label_offset" => 2, "start_from_zero" => false, "tick_labels_angle" => 0, "tick_labels_max_digits" => 3),
	y_axis = Dict("ticks" => [], "stroke_width" => 1, "label" => nothing, "label_offset" => 2, "start_from_zero" => false, "tick_labels_angle" => 0, "tick_labels_max_digits" => 3), 
	colormap = default_colormap,
	background = Dict("color" => "white"),
	normals = Dict("show" => true, "length" => 6, "thickness" => 1, "color" => default_colormap["normals"])
	)

	return Figure(
		model,
		float(width),
		margin,
		offset,
		font,
		x_axis,
		y_axis,
		colormap,
		background,
		normals)
end

import Base: setproperty!
function setproperty!(f::Figure, s::Symbol, val::T) where {T<:Number}
    if (s == :offset) || (s == :margin)
    	val = float(val)
        return setfield!(f, s, Dict("top" => val, "bottom" => val, "left" => val, "right" => val))
    else
        return setfield!(f, s, value)
    end
end

color(::PerfectlyMatchedLayer, colormap) = colormap["PerfectlyMatchedLayer"]
color(::Dielectric{1.0006ε_0, μ_0, 0.0}, colormap) = colormap["Air"]
color(::Dielectric{2.04ε_0, μ_0, 0.0}, colormap) = colormap["PTFE"]
color(::Dielectric{ε_0, μ_0, 0.0}, colormap) = colormap["Vacuum"]
color(::Conductor, colormap) = colormap["Conductor"]
color(::PerfectMagneticConductor, colormap) = colormap["PerfectMagneticConductor"]
color(::PerfectElectricConductor, colormap) = colormap["PerfectElectricConductor"]
color(::SurfaceImpedance, colormap) = colormap["SurfaceImpedance"]
color(::CoaxialPort, colormap) = colormap["CoaxialPort"]
color(::WaveguidePort, colormap) = colormap["WaveguidePort"]
color(::UniformPort, colormap) = colormap["UniformPort"]
color(m::Material, colormap) = get!(colormap, string(objectid(m)), "#ff00ff") # TODO: add fallback colors
color(b::BoundaryCondition, colormap) = get!(colormap, string(objectid(b)), "#ff0000") # TODO: add fallback colors

function draw(color::String, shape::Union{Rectangle, Circle, Polygon, CompositeShape})
	return NativeSVG.use(href="#$(objectid(shape))", xlink!href="#$(objectid(shape))", fill=color)
end

function draw(color::String, shape::Segment)
	return NativeSVG.use(href="#$(objectid(shape))", xlink!href="#$(objectid(shape))", stroke=color, stroke_width="1%")
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
		NativeSVG.use(href="#$(objectid(shape.A))", xlink!href="#$(objectid(shape.A))")
		NativeSVG.use(href="#$(objectid(shape.B))", xlink!href="#$(objectid(shape.B))")
	end

	define(shape.A)
	define(shape.B)
end

function define(shape::CompositeShape{-})
	NativeSVG.g(id="$(objectid(shape))") do
		NativeSVG.mask(id="$(objectid(shape))-mask") do
			NativeSVG.use(href="#$(objectid(shape.A))", xlink!href="#$(objectid(shape.A))", fill="white")
			NativeSVG.use(href="#$(objectid(shape.B))", xlink!href="#$(objectid(shape.B))", fill="black")
		end
		NativeSVG.use(href="#$(objectid(shape.A))", xlink!href="#$(objectid(shape.A))", mask="url(#$(objectid(shape))-mask)")
	end

	define(shape.A)
	define(shape.B)
end

function define(material::Material, f::Figure{AxisymmetricDomain})
	if material isa PerfectlyMatchedLayer
		Z = (f.model.domain.zmax - f.model.domain.zmin) * 1000
		thickness = Z / 200

		NativeSVG.pattern(id="$(objectid(material))", width="$(2*thickness)", height="$(2*thickness)", patternTransform="rotate(-45 0 0)", patternUnits="userSpaceOnUse") do
			NativeSVG.rect(width="$thickness", height="$(2*thickness)", fill=color(material, f.colormap))
			NativeSVG.rect(x="$thickness", width="$thickness", height="$(2*thickness)", fill=color(material.dielectric, f.colormap))
		end

		f.colormap["PerfectlyMatchedLayer"] = "url(#$(objectid(material)))"
	end
end


function domain_svg(f::Figure{AxisymmetricDomain})
	
	NativeSVG.defs() do
		for (shape, material) in f.model.domain.materials
			define(shape)
			define(material, f)
		end

		for (shape, _) in f.model.constraints
			define(shape)
		end
	end

	Z = (f.model.domain.zmax - f.model.domain.zmin) * 1000

	NativeSVG.g(id="domain", transform="rotate(-90 0 0) translate(-$Z)") do
		for (shape, material) in f.model.domain.materials
			draw(color(material, f.colormap), shape)
		end

		for (segment, bc) in f.model.constraints
			draw(color(bc, f.colormap), segment)
		end
	end
end

function get_domain_size(domain::AxisymmetricDomain, desired_width)
	ldW = (domain.rmax - domain.rmin) * 1000
	ldH = (domain.zmax - domain.zmin) * 1000
	gdW = float(desired_width)
	gdH = desired_width * (ldH / ldW)

	ldW_min = domain.rmin * 1000
	ldH_min = domain.zmin * 1000

	return gdW, gdH, ldW, ldH, ldW_min, ldH_min
end

function draw_normals(f::Figure{AxisymmetricDomain})
	domain_width = f.width - f.offset["left"] - f.offset["right"] - f.margin["left"] - f.margin["right"]

	gdW, gdH, ldW, ldH, ldW_min, ldH_min = get_domain_size(f.model.domain, domain_width)

	NativeSVG.g(id="normals") do
		for (segment, bc) in f.model.constraints
	
			lX1, lY1, lX2, lY2 = 1000 .* typeof(segment).parameters

			X1 = (lY1 - ldW_min) / ldW * gdW + f.margin["left"] + f.offset["left"]
			Y1 = gdH - ((lX1 - ldH_min) / ldH * gdH) + f.margin["top"] + f.offset["top"]

			
			X2 = (lY2 - ldW_min) / ldW * gdW + f.margin["left"] + f.offset["left"]
			Y2 = gdH - ((lX2 - ldH_min) / ldH * gdH) + f.margin["top"] + f.offset["top"]

			x1 = (X1 + X2) / 2 
			y1 = (Y1 + Y2) / 2

			dx = (X2 - X1) / √((X2 - X1)^2 + (Y2 - Y1)^2)
			dy = (Y2 - Y1) / √((X2 - X1)^2 + (Y2 - Y1)^2)

			# length scaled down 10× for more convenient usage (avoid floats)
			x2 = x1 + (f.normals["length"] / 10) * +dy
			y2 = y1 + (f.normals["length"] / 10) * -dx

			NativeSVG.line(x1="$(x1)cm", y1="$(y1)cm", x2="$(x2)cm", y2="$(y2)cm", stroke=f.normals["color"], stroke_width="$(f.normals["thickness"])px", marker_end="url(#arrowhead)")
		end
	end
end

function save(fig::NativeSVG.SVG, filename="domain.svg")
	write("plots/$filename", fig )
end

function svg(f::Figure)

	domain_width = f.width - f.offset["left"] - f.offset["right"] - f.margin["left"] - f.margin["right"]

	@assert domain_width > 0 "Margins and offsets are too large!"

	gdW, gdH, ldW, ldH, ldW_min, ldH_min = get_domain_size(f.model.domain, domain_width)

	gdW_offset = (ldW_min/ldW * gdW)
	gdH_offset = (ldH_min/ldH * gdH)

	W = f.width
	H = gdH + f.offset["top"] + f.offset["bottom"] + f.margin["top"] + f.margin["bottom"] 
 
	NativeSVG.SVG(xmlns!xlink="http://www.w3.org/1999/xlink", width="$(W)cm", height="$(H)cm") do
		NativeSVG.defs() do
			# background
			NativeSVG.rect(id="background", width="$(W)cm", height="$(H)cm", fill=f.background["color"])

			# arrowhead
			NativeSVG.marker(id="arrowhead", viewBox="0 0 10 10", refX="5", refY="5", markerWidth="8", markerHeight="8", orient="auto-start-reverse") do
				NativeSVG.path(d="M 0 0 L 10 5 L 0 10 z")
			end

			# tick mark
			NativeSVG.line(id="x_tick", x1="0", y1="5", x2="0", y2="-5", stroke=f.colormap["axis"], stroke_width="$(f.y_axis["stroke_width"])px")
			NativeSVG.line(id="y_tick", x1="5", y1="0", x2="-5", y2="0", stroke=f.colormap["axis"], stroke_width="$(f.x_axis["stroke_width"])px")

			# tick labels
			if !isempty(f.x_axis["ticks"])
				if f.x_axis["tick_labels_angle"] > 0
					text_anchor = "start"
				elseif f.x_axis["tick_labels_angle"] < 0
					text_anchor = "end"
				else
					text_anchor = "middle"
				end

				for (i,label) in enumerate(f.x_axis["ticks"])
					NativeSVG.text(id="x_tick_label_$i", text_anchor=text_anchor, font_size="$(f.font["size"])pt", font_family=f.font["family"], style="fill: $(f.colormap["font"]);", transform="rotate($(f.x_axis["tick_labels_angle"]))") do
						label = round(label, digits=f.x_axis["tick_labels_max_digits"])
						NativeSVG.str("$(label)")
					end
				end
			end

			if !isempty(f.y_axis["ticks"])
				text_anchor = "end"
				for (i,label) in enumerate(f.y_axis["ticks"])
					NativeSVG.text(id="y_tick_label_$i", text_anchor=text_anchor, font_size="$(f.font["size"])pt", font_family=f.font["family"], style="fill: $(f.colormap["font"]);", transform="rotate($(f.y_axis["tick_labels_angle"]))") do
						label = round(label, digits=f.y_axis["tick_labels_max_digits"])
						NativeSVG.str("$label")
					end
				end
			end

			# labels
			if !isnothing(f.y_axis["label"])
				NativeSVG.text(id="y_axis_label", text_anchor="middle", font_size="$(f.font["size"])pt", font_family="$(f.font["family"])", style="fill: $(f.colormap["font"]);", transform="rotate(-90)") do
					NativeSVG.str(f.y_axis["label"])
				end
			end

			if !isnothing(f.x_axis["label"])
				NativeSVG.text(id="x_axis_label", text_anchor="middle", font_size="$(f.font["size"])pt", font_family="$(f.font["family"])", style="fill: $(f.colormap["font"]);") do
					NativeSVG.str(f.x_axis["label"])
				end
			end

		end

		# background
		NativeSVG.use(href="#background", xlink!href="#background")

		# y-axis
		NativeSVG.g(id="y-axis") do
			# axis
			x1 = x2 = f.margin["left"]
			y1 = f.margin["top"]
			y2 = f.margin["top"] + f.offset["top"] + gdH
			y2 += f.y_axis["start_from_zero"] ? 0 : f.offset["bottom"]
			NativeSVG.line(x1="$(x1)cm", x2="$(x2)cm", y1="$(y1)cm", y2="$(y2)cm", stroke=f.colormap["axis"], stroke_width=f.y_axis["stroke_width"], marker_start="url(#arrowhead)")

			# label
			if !isnothing(f.y_axis["label"])
				x = f.margin["left"] - f.y_axis["label_offset"]
				y = (y1 + y2) / 2
				NativeSVG.use(href="#y_axis_label", xlink!href="#y_axis_label", x="$(x)cm", y="$(y)cm")
			end
			
			# ticks & tick labels
			if !isempty(f.y_axis["ticks"])
				ticks = f.y_axis["ticks"]
				gticks = (ticks ./ ldW) * gdW * 1000
				for i in 1:length(ticks)
					x = f.margin["left"]
					y = f.margin["top"] + f.offset["top"] + gdH - gticks[i] - gdH_offset
					NativeSVG.use(href="#y_tick", xlink!href="#y_tick", x="$(x)cm", y="$(y)cm")

					x = f.margin["left"] - 0.3
					y = f.margin["top"] + f.offset["top"] + gdH - gticks[i] - gdH_offset + (f.font["size"]/2 * 0.02) # FIXME: eye-ball
					NativeSVG.use(href="#y_tick_label_$i", xlink!href="#y_tick_label_$i", x="$(x)cm", y="$(y)cm")
				end
			end
		end

		# x-axis
		NativeSVG.g(id="x-axis") do
			# axis
			x1 = f.margin["left"]
			x1 += f.x_axis["start_from_zero"] ? f.offset["left"] : 0
			x2 = f.margin["left"] + f.offset["left"] + gdW + f.offset["right"]
			y1 = y2 = f.offset["top"] + f.margin["top"] + gdH + f.offset["bottom"]
			NativeSVG.line(x1="$(x1)cm", x2="$(x2)cm", y1="$(y1)cm", y2="$(y2)cm", stroke=f.colormap["axis"], stroke_width=f.x_axis["stroke_width"], marker_end="url(#arrowhead)")

			# label
			if !isnothing(f.x_axis["label"])
				x = (x1 + x2) / 2
				y = f.margin["top"] + f.offset["top"] + gdH + f.x_axis["label_offset"]
				NativeSVG.use(href="#x_axis_label", xlink!href="#x_axis_label", x="$(x)cm", y="$(y)cm")
			end

			# ticks & tick labels
			if !isempty(f.x_axis["ticks"])
				ticks = f.x_axis["ticks"]
				gticks = (ticks ./ ldH) * gdH * 1000
				for i in 1:length(ticks)
					x = f.margin["left"] + f.offset["left"] + gticks[i] - gdW_offset
					y = f.margin["top"] + f.offset["top"] + gdH + f.offset["bottom"] 
					NativeSVG.use(href="#x_tick", xlink!href="#x_tick", x="$(x)cm", y="$(y)cm")

					y += f.font["size"] * 0.02 + 0.3 # FIXME: eye-ball
					NativeSVG.use(href="#x_tick_label_$i", xlink!href="#x_tick_label_$i", x="$(x)cm", y="$(y)cm")
				end
			end
		end

		x = f.margin["left"] + f.offset["left"]
		y = f.margin["top"] + f.offset["top"]
		NativeSVG.svg(x="$(x)cm", y="$(y)cm", width="$(gdW)cm", height="$(gdH)cm", viewBox="$ldW_min $ldH_min $ldW $ldH") do 
			domain_svg(f)
		end 

		# draw normals 
		# need to be outside domain svg scope in case normals are wrongly defined,
		# thus would be invisible outside domain svg viewBox
		if f.normals["show"]
			draw_normals(f)
		end
	end
end
end

module Plot
using PyPlot
import ..Models: FDTDModel

function plot_nodes(model::FDTDModel; s=10, lw=1)
	nz, nr = size(model.node_material)
	z, r = model.grid.z, model.grid.r
	scatter(z, r, c=model.node_material, s=s, marker="s", linewidths=lw, edgecolors="black", cmap="tab10")
	axis("equal")
	xlabel("r (m)")
	ylabel("z (m)")
	
	return nothing
end

function plot_edges(model::FDTDModel; s=10, lw=1)
	nz, nr = size(model.node_material)
	zz, rz = model.grid.z[1:nz-1,1:nr], model.grid.r[1:nz-1,1:nr]
	zr, rr = model.grid.z[1:nz,1:nr-1], model.grid.r[1:nz,1:nr-1]
	zz .+= model.grid.dz/2
	rr .+= model.grid.dr/2
	
	scatter(zz, rz, c=first(model.edge_boundary), s=s, marker=">", linewidths=lw, edgecolors="black", cmap="tab10")
	scatter(zr, rr, c=last(model.edge_boundary),  s=s, marker="^", linewidths=lw, edgecolors="black", cmap="tab10")
	
	axis("equal")
	xlabel("r (m)")
	ylabel("z (m)")
	
	return nothing
end
end