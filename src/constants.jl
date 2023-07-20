module Constants
# physical constants
const q_e = 1.60217662e-19 # charge of electron [C]
const m_e = 9.10938356e-31 # mass of electron [kg]
const Da  = 1.66053907e-27 # atomic mass unit [kg]
const ε_0 = 8.85418781e-12 # vacuum permittivity [F/m]
const μ_0 = 1.256637062e-6 # vacuum permeability [H/m]
const kB  = 1.38064852e-23 # Boltzmann's constant [J/K]
const c   = 299_792_458.   # speed of light [m/s]
const χ_01 = 2.4048        # zero of a Bessel's function [-]
# derived constants
const η_0 = sqrt(μ_0/ε_0)  # intristic impedance of free space [Ω]
const c²  = c^2            # speed of light squared [m^2/s^2]


# ionization energy division coefficients
# from Opal et al. "Measurements of secondary electron spectra produced by electron impact ionization of a number of simple gases,"
ω = Dict{Symbol, Float64}(
	:He => 15.8
)

end