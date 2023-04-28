module Species
import ..PlasmaModelingToolkit.Atoms: Atom

abstract type Species end

struct Particles{SYM, Q, M} <: Species end
struct Fluid{SYM, M} <: Species end

electrons() = Particles{:e, -q_e, m_e}()
ions(atom::Atom, n = 1) = Particles{Symbol("i"^n * String(atom.sym)), (n * q_e), atom.mass - (n * m_e)}()
particles(atom::Atom) = Particles{atom.sym, 0.0, atom.mass}()
gas(atom::Atom) = Fluid{atom.sym, atom.mass}()
end