struct Domain1D
	xmin :: Float64
	xmax :: Float64
	materials :: Vector{Pair{Segment2D, Material}}
end

function Domain1D(xmin::Float64, xmax::Float64, material::Material)
	region = Segment1D{xmin, xmax}()
	return Domain1D(xmin, xmax, [region => material])
end

function setindex!(domain::Domain1D, material::Material, shape::Shape1D)
    push!(domain.materials, shape => material)
end