import PlasmaModelingToolkit.SVG: Figure, svg, save
import PlasmaModelingToolkit.Examples.CircularWaveguide: model, RADIUS, LENGTH

f = Figure(model; width=25)
f.margin["right"]  = 15.5
f.margin["left"]   = 3.5
f.margin["bottom"] = 3

f.x_axis["ticks"] = [0.0 RADIUS]

f.x_axis["label"] = "r-coordinate [m]"

f.y_axis["ticks"] = [0.0 LENGTH/2-RADIUS/3 LENGTH/2 LENGTH/2+RADIUS/3 LENGTH]
f.y_axis["tick_labels_max_digits"] = 4

f.y_axis["label"] = "z-coordinate [m]"
f.y_axis["label_offset"] = 2

save(svg(f), "circular-waveguide.svg")