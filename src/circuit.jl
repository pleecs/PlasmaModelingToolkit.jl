module Circuit
import ..TemporalFunctions: TemporalFunction, ConstantFunction

struct LumpedElement
	symbol :: Symbol
	value  :: TemporalFunction
end
LumpedElement(symbol, value::Float64) = LumpedElement(symbol, ConstantFunction{value}())

Resistor(R) = LumpedElement(:R, R)
Inductor(L) = LumpedElement(:L, L)
Capacitor(C) = LumpedElement(:C, C)
VoltageSource(V) = LumpedElement(:V, V)

struct LumpedPort{CIR, EXC}
	circuit :: CIR
	terminals :: Tuple{Symbol, Symbol}
	excitation :: EXC
end
LumpedPort(circuit; terminals::Tuple{Symbol, Symbol},
	excitation=nothing) = LumpedPort(circuit, terminals, excitation)

end