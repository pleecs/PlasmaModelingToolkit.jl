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

struct CoaxialPort <: BoundaryCondition
	signal :: Signal
	η :: Float64
end

struct WaveguidePort <: BoundaryCondition
	signal :: Signal
	mode :: WaveguideMode
	η :: Float64
end

struct UniformPort <: BoundaryCondition
	signal :: Signal
  η :: Float64
end
end