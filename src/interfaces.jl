module InterfaceConditions
import ..Materials: Dielectric
import ..BoundaryConditions: PerfectElectricConductor

abstract type InterfaceCondition end
struct DielectricInterface{EPS1, EPS2, SIG} <: InterfaceCondition end

interface(mat1::Dielectric{EPS1, MU, SIG},
          mat2::Dielectric{EPS2, MU, SIG}) where {EPS1, EPS2, MU, SIG} =
          DielectricInterface{EPS1, EPS2, SIG}()

function detect_interface_z!(boundaries, edge_boundary, node_material, dielectrics)
  NZ, NR = size(node_material)
  for i in 1:NZ, j in 1:NR-1
    A, B = 0x00, 0x00
    C, D = 0x00, 0x00
    E, F = 0x00, 0x00
    if i > 1
      A, B = node_material[i-1,j], node_material[i-1,j+1]
    end

    C, D = node_material[i,j], node_material[i,j+1]
    if (C != D) && (A != C || B != D)
      @debug "Found interface start at $i, $j"
      k = i
      while k < NZ
        C, D = node_material[k,  j], node_material[k,  j+1]
        E, F = node_material[k+1,j], node_material[k+1,j+1]
        if C == E && D == F
          k += 1
        else
          break
        end
      end
      @debug "Found interface end at $k, $j"
      l = C > D ? j + 1 : j
      n = i > 1  && C >= A && D >= B ? i - 1 : i
      m = k < NZ && C >= E && D >= F ? k : k - 1
      @debug "New interface ($n,$l) ($m,$l)"
      if m >= n && haskey(dielectrics, min(C, D)) && haskey(dielectrics, max(C, D))
        mat1 = dielectrics[min(C, D)]
        mat2 = dielectrics[max(C, D)]
        iface = interface(mat1, mat2)
        get!(boundaries, iface, length(boundaries) + 1)
        edge_boundary[n:m, l] .= boundaries[iface]
      else
        metal = PerfectElectricConductor()
        get!(boundaries, metal, length(boundaries) + 1)
        edge_boundary[n:m, l] .= boundaries[metal]
      end
    end
  end
end

function detect_interface_r!(boundaries, edge_boundary, node_material, dielectrics)
  NZ, NR = size(node_material)
  for i in 1:NZ-1, j in 1:NR
    A, B = 0x00, 0x00
    C, D = 0x00, 0x00
    E, F = 0x00, 0x00
    if j > 1
      A, B = node_material[i,j-1], node_material[i+1,j-1]
    end

    C, D = node_material[i,j], node_material[i+1,j]
    if (C != D) && (A != C || B != D)
      @debug "Found interface start at $i, $j"
      k = j
      while k < NR
        C, D = node_material[i,k  ], node_material[i+1,k  ]
        E, F = node_material[i,k+1], node_material[i+1,k+1]
        if C == E && D == F
          k += 1
        else
          break
        end
      end
      @debug "Found interface end at $i, $k"
      l = C > D ? i + 1 : i
      n = j > 1  && C >= A && D >= B ? j - 1 : j
      m = k < NR && C >= E && D >= F ? k : k - 1
      @debug "New interface ($l,$n) ($l,$m)"
      if m >= n && haskey(dielectrics, min(C, D)) && haskey(dielectrics, max(C, D))
        mat1 = dielectrics[min(C, D)]
        mat2 = dielectrics[max(C, D)]
        iface = interface(mat1, mat2)
        get!(boundaries, iface, length(boundaries) + 1)
        edge_boundary[l, n:m] .= boundaries[iface]
      else
        metal = PerfectElectricConductor()
        get!(boundaries, metal, length(boundaries) + 1)
        edge_boundary[l, n:m] .= boundaries[metal]
      end
    end
  end
end
end