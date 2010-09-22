import io/FileWriter
import math, math/Random

Point: class {
	x, y, z: Float

	init: func (=x, =y, =z){ }
}

Vector: class extends Point {
	init: func (=x, =y, =z){ }
}

operator + (left, right: Point) -> Point {
	Point new(left x + right x, left y + right y, left z + right z)
}

operator - (left, right: Point) -> Vector {
	Vector new(left x - right x, left y - right y, left z - right z)
}

dot: func (a, b: Point) -> Float {
	a x * b x + a y * b y + a z * b z
}

normalize: func (a: Vector) -> Vector {
	n := sqrt(a x * a x + a y * a y + a z * a z)
	Vector new(a x / n, a y / n, a z / n)
}

Ray: class {
	origin: Point
	direction: Vector

	init: func (=origin, =direction){ }
}

Sphere: class {

	center: Point
	radius: Float
	radius2: Float	

	init: func (=center, =radius){
		radius2 = radius * radius 
	}

	intersect?: func (ray: Ray) -> Bool {
		dst := ray origin - center
		B := dot(dst, ray direction)
		C := dot(dst, dst) - radius2
		D := B * B - C
		D > 0 // -B * sqrt(D)
	}

}


Color: class {
	r, g, b: Int

	init: func (=r, =g, =b) { }
}

operator + (a, b: Color) -> Color {
	Color new(a r + b r, a g + b g, a b + b b)
}

operator / (a: Color, b: Int) -> Color {
	Color new(a r / b, a g / b, a b / b)
}

rando: func -> Float {
	(rand() % 1000) / 1000.
}

main: func {
	width := 256
	height := 256
	samples_per_pixel = 8 : Int

	// output ppm
	"P3\n%d %d\n255\n" format(width, height) print()

	world := Sphere new(Point new(0, 0, 0), 1)

	r := Ray new(Point new(0., 0., -3.), Vector new(0, 0, 0))
	for (y in 0..height){
		for (x in 0..width){
			c := Color new(0, 0, 0)
			for (n in 0..samples_per_pixel){
				// jitter a little bit
				xx := (x + rando() * 1. - 1.) as Float
				yy := (y + rando() * 1. - 1.) as Float

				focus := Point new(-2. + (4. * xx / (width - 1.)), 2. - (4. * yy / (height - 1.)), 0)
				r direction = normalize(focus - r origin)
				if (world intersect?(r))
					c += Color new(94, 94, 94)
			}
			c = c / samples_per_pixel
			"%d %d %d " format(c r, c g, c b) print()
		}
	}	

}
