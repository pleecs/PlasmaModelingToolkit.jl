module Species
import ..PlasmaModelingToolkit.Atoms: Atom
import ..Constants: m_e, q_e

abstract type AbstractSpecies end

struct Particles{SYM} <: AbstractSpecies
  charge :: Float64
  mass :: Float64
end
struct Fluid{SYM} <: AbstractSpecies
  mass :: Float64
end

electrons() = Particles{:e}(-q_e, m_e)
ions(atom::Atom, n = 1) = Particles{Symbol("i"^n * String(atom.sym))}((n * q_e), atom.mass - (n * m_e))
particles(atom::Atom) = Particles{atom.sym}(0.0, atom.mass)
gas(atom::Atom) = Fluid{atom.sym}(atom.mass)
end