module Grid
export AxisymmetricGrid, Nodes, Edges

struct AxisymmetricGrid{ZN, RN}
	z  :: Matrix{Float64}
    r  :: Matrix{Float64}
    dz :: Float64
    dr :: Float64
end

struct Nodes{Z1, Z2, R1, R2}
    mask :: Matrix{Bool}
end

"""
A - start index of coordinate 1
B - end index of coordinate 1
C - constant index of coordinate 2
U - normal component of Z direction 
V - normal component of R direction

U, V are determining which coordinates (z or r) are range and constant, and orientation of normal vector

Edges{1, 5, 2, 0, +1}
z: A:B => 1:5
r: C => 2
normal vector is oriented towards rise direction of the coordinate r

Edges{1, 7, 3, -1, 0}
z: C => 3
r: A:B => 1:7
normal vector is oriented towards falling direction of the coordinate z
"""
struct Edges{A, B, C, U, V} end


end