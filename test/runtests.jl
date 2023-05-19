using Test

@testset "Geometry" begin

import PlasmaModelingToolkit.Geometry: Polygon, Segment2D, Ray, ∩, ∈

p1 = Polygon([(0.,0.), (4.,0.), (4.,4.), (0.,4.)])
p2 = Polygon([(-4.,-4.), (-2.,-4.), (-2.,-2.), (-4.,-2.)])

@testset "Polygon" begin
  @test (2.,2.) ∈ p1          # inside
  @test (2.,0.) ∈ p1          # on the side (bottom)
  @test (4.,2.) ∈ p1          # on the side (right)
  @test (2.,4.) ∈ p1          # on the side (top)
  @test (0.,2.) ∈ p1          # on the side (left)
  @test (0.,0.) ∈ p1          # on the corner (left-bottom, origin)
  @test (4.,0.) ∈ p1          # on the corner (right-bottom)
  @test (4.,4.) ∈ p1          # on the corner (right-top)
  @test (0.,4.) ∈ p1          # on the corner (left-top)
  @test !((5.,5.) ∈ p1)       # outside
  @test !((-5.,2.) ∈ p1)      # outside
  @test !((-5.,-5.) ∈ p1)     # outside
  @test !((-1e-5,-1e-5) ∈ p1) # outside
  @test (-3.,-3.) ∈ p2        # inside
  @test (-3.,-4.) ∈ p2        # on the side (bottom)
  @test (-2.,-3.) ∈ p2        # on the side (right)
  @test (-3.,-2.) ∈ p2        # on the side (top)
  @test (-4.,-3.) ∈ p2        # on the side (left)
  @test (-4.,-4.) ∈ p2        # on the corner (left-bottom)
  @test (-2.,-4.) ∈ p2        # on the corner (right-bottom)
  @test (-2.,-2.) ∈ p2        # on the corner (right-top)
  @test (-4.,-2.) ∈ p2        # on the corner (left-top)
  @test !((5.,5.) ∈ p2)       # outside
  @test !((-5.,2.) ∈ p2)      # outside
  @test !((-5.,-5.) ∈ p2)     # outside
  @test !((1e-5,1e-5) ∈ p2)   # outside
end

s1 = Segment2D(0.,0.,0.,4.)
r1 = Ray((-2.,2.),(1.,0.))
r2 = Ray((2.,2.),(-1.,0.))

@testset "Ray-Segment2D intersection" begin
  @test r1 ∩ s1
  @test r2 ∩ s1
end

end