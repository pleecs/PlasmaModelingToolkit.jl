import .Domains: AxisymmetricDomain

PYPLOT_AVAILABLE = false

try
	import PyPlot
	PYPLOT_AVAILABLE = true
catch e
	if isa(e, ArgumentError)
		@info "Using a fallback display. Install PyPlot to plot the domain."
	else
		rethrow(e)
	end
end

import Base: display
function display(domain::AxisymmetricDomain)
	if PYPLOT_AVAILABLE
		@info "I will be plotting in the future!"
	else
		println("AxisymmetricDomain($(domain.zmin):$(domain.zmax), $(domain.rmin):$(domain.rmax))")
		for (shape, material) in domain.materials
			println("\t$(shape) => $(material)")
		end
	end
end