import PlasmaModelingToolkit.SVG: Figure, svg, save

include("../examples/swo-simplified.jl")

f = Figure(fdtd; width=25)
f.margin      = 1
f.margin["bottom"]  = 2 
f.margin["left"]  = 3

f.offset      = 0.5
f.offset["right"] = 2

f.x_axis["ticks"] = [0.0 RADIUS 0.5]
f.x_axis["label"] = "r-coordinate [m]"
f.x_axis["start_from_zero"] = true

f.y_axis["ticks"] = [0.0 LENGTH 0.5]
f.y_axis["label"] = "z-coordinate [m]"
f.y_axis["start_from_zero"] = true

f.font["size"]   = 12
f.font["family"] = "serif"

save(svg(f), "plots/swo-simplified.svg")
