import PlasmaModelingToolkit.SVG: Figure, svg, save
import PlasmaModelingToolkit.Examples.CoaxialCable: model, r_coax, R_coax, L_coax

f = Figure(model; width=25)
f.margin["right"]  = 19
f.margin["left"]   = 3
f.margin["bottom"] = 3

f.offset["left"] = 1.7

f.x_axis["ticks"] = [0.0 r_coax R_coax]
f.x_axis["tick_labels_angle"] = -45

f.x_axis["label"] = "r-coordinate [m]"
f.x_axis["label_offset"] = 2.5

f.y_axis["ticks"] = [0.0 L_coax]

f.y_axis["label"] = "z-coordinate [m]"
f.y_axis["label_offset"] = 1.2

f.normals["length"] = 3

save(svg(f), "coaxial-cable.svg")