module Sources
import ..BoundaryConditions: BoundaryCondition
import ..Materials: Medium

abstract type Signal end
struct HarmonicSignal{A, FREQ} <: Signal end                # A * sin(2pi * FREQ * t)
struct GaussianPulse{A, SIGMA} <: Signal end                # A * gaussian_pulse(SIGMA, t)
struct GaussianWavePacket{A, SIGMA, FREQ} <: Signal end     # HarmonicSignal * GaussianPulse

abstract type WaveguideMode end
struct TM01 <: WaveguideMode end
struct TEM <: WaveguideMode end

struct CoaxialPort{S<:Signal} <: BoundaryCondition
	m :: Medium			 				# FIXME: remove when we will be able to calculate impedance in Hennel.jl
end

struct WaveguidePort{S<:Signal, M<:WaveguideMode} <: BoundaryCondition
	m :: Medium			 				# FIXME: remove when we will be able to calculate impedance in Hennel.jl
end

struct UniformPort{S<:Signal} <: BoundaryCondition
  m :: Medium			 				# FIXME: remove when we will be able to calculate impedance in Hennel.jl
end

end