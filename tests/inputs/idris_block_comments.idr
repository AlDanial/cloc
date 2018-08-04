--
-- A module about shapes
--

||| a Shape
data Shape =
  ||| Triangle with base and heigth
  Triangle Double Double |
  ||| Circle with radius
  Circle Double

||| computes the area of a shape
area : Shape -> Double
area (Triangle x y) = 0.5 * x * y
area (Circle x) = pi * x * x
                  -- pi is known by idris

{-
commented out code
-}
