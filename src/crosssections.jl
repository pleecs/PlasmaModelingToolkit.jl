module CrossSections
abstract type AbstractCrossSections end
struct Biagi{SYM} <: AbstractCrossSections end
Biagi(sym::Symbol) = Biagi{sym}()
end