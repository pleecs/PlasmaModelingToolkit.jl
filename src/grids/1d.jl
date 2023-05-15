struct Grid1D{XN}
	x :: Vector{Float64}
	dx :: Float64
end

function discretize(domain::Domain1D, nx)
	zx = range(domain.xmin, domain.xmax, length=nx)
	dx = step(zx)
	x = repeat(zx, 1, nx) 
	return Domain1D{nx}(x,dx)
end