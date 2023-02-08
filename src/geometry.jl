module Geometry
export isinside, +, -
export Rectangle, Circle, Segment

const mm = 1e-3 # unit conversion ratio [mm/m]
const cm = 1e-2 # unit conversion ratio [cm/m]

abstract type Shape end

struct Rectangle{X, Y, W, H} <: Shape end
struct Circle{X, Y, R} <: Shape end
struct Segment{X1, Y1, X2, Y2} <: Shape end 

function isinside(x, y, ::Rectangle{X, Y, W, H}) where {X, Y, W, H}
  if X <= x <= X + W
    if Y <= y <= Y + H
      return true
    end
  end

  return false
end

function isinside(x, y, ::Circle{X, Y, R}) where {X, Y, R}
  r² = (x - X)^2 + (y - Y)^2
  if r² <= R^2
    return true
  end

  return false
end

struct CompositeShape{OPERATOR, A, B}  <: Shape end
import Base: +, -

function +(A::Shape, B::Shape)
  return CompositeShape{+, A, B}()
end
 
function -(A::Shape, B::Shape)
  return CompositeShape{-, A, B}()
end
 
function isinside(x, y, ::CompositeShape{+, A, B}) where {A, B}
  return isinside(x, y, A) ||
         isinside(x, y, B)
end

function isinside(x, y, ::CompositeShape{-, A, B}) where {A, B}
  return isinside(x, y, A) &&
        !isinside(x, y, B)
end

end