import PlasmaModelingToolkit.SVG: Figure, svg, save
import PlasmaModelingToolkit.Examples.DipoleAntenna: model, r_coax, R_coax, RADIUS, LENGTH

f = Figure(model; width=25)
f.margin            = 1
f.margin["bottom"]  = 2 
f.margin["left"]    = 3.5

f.offset            = 0.5
f.offset["right"]   = 2

f.x_axis["ticks"]   = [0.0 r_coax R_coax RADIUS]
f.x_axis["tick_labels_angle"] = -90
f.x_axis["label"]   = "r-coordinate [m]"
f.x_axis["start_from_zero"] = true

f.y_axis["ticks"]   = [0.0 0.015 0.023 LENGTH]
f.y_axis["label"]   = "z-coordinate [m]"
f.y_axis["start_from_zero"] = true

f.font["size"] = 12

save(svg(f), "plots/dipole-antenna.svg")
