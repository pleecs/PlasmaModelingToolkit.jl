module TemporalFunctions
abstract type TemporalFunction end
"""
f(t) = A + \frac{K - A}{(C + Qe^{-B(t - M)})^{1/ν}}

"""
struct GeneralizedLogisticFunction{A, K, B, ν, Q, C, M} <: TemporalFunction end
GeneralizedLogisticFunction(y₁, y₂, t, growth) = GeneralizedLogisticFunction{y₁, y₂, growth, 1.0, 1.0, 1.0, t}()

"""
f(t) = \frac{L}{1+e^{-k(t - t₀)}}
"""
LogisticFunction{t₀, L, k} = GeneralizedLogisticFunction{0.0, L, k, 1.0, 1.0, 1.0, t₀}
end