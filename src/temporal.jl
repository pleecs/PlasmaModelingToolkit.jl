module TemporalFunctions
abstract type TemporalFunction end
struct ConstantFunction{A} <: TemporalFunction end

# f(t) = A + \frac{K - A}{(C + Qe^{-B(t - M)})^{1/ν}}
struct GeneralizedLogisticFunction{A, K, B, ν, Q, C, M} <: TemporalFunction end
GeneralizedLogisticFunction(y₁, y₂, t, growth) = GeneralizedLogisticFunction{y₁, y₂, growth, 1.0, 1.0, 1.0, t}()

# f(t) = \frac{L}{1+e^{-k(t - t₀)}}
LogisticFunction{t₀, L, k} = GeneralizedLogisticFunction{0.0, L, k, 1.0, 1.0, 1.0, t₀}

# f(t) = A * sin(2\pi * FREQ * t)
struct SineFunction{A, FREQ} <: TemporalFunction end

# f(t) = \sum_{i=0}^{N-1} A * exp(-\frac{(t-\mu+i * T)^2}{2\sigma^2})
struct GaussianPulseTrain{A, MU, SIGMA, N, T} <: TemporalFunction end

# f(t) = A * exp(-\frac{(t-\mu)^2}{2\sigma^2})
struct GaussianFunction{A, MU, SIGMA} <: TemporalFunction end

# f(t) = A * sin(2\pi * FREQ * t) * exp(-\frac{(t - \mu)^2}{2\sigma^2})
struct GaussianWavePacket{A, MU, SIGMA, FREQ} <: TemporalFunction end

# f(t) = A * (exp(-\alpha * t) - exp(-\beta * t))
struct DoubleExponentialPulse{A, ALPHA, BETA} <: TemporalFunction end

# f(t) = { (t - A) / (B - A) * (HIGH - LOW) + LOW, A <= t <= B,
#           LOW,  t < A,
#           HIGH, t > B }
struct RampFunction{A, B, LOW, HIGH} <: TemporalFunction end
end