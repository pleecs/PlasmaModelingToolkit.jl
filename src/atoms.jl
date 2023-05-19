module Atoms
import ..PlasmaModelingToolkit.Constants: Da

struct Atom
  sym  :: Symbol
  mass :: Float64
end

const Helium = Atom(:He, 4.002602Da)
const Argon  = Atom(:Ar, 39.948Da)

end