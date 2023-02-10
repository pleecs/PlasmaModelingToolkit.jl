module Sources
	import ..BoundaryConditions: BoundaryCondition
	export CoaxialPort

	struct CoaxialPort <: BoundaryCondition
		A :: Float64 
		f :: Float64
	end
end