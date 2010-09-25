import io/FileWriter
import math, math/Random
import structs/ArrayList

Float3: class {
	x, y, z: Float

	init: func (=x, =y, =z){ }

	normalize: func () -> Float3 {
		n := sqrt(this x * this x + this y * this y + this z * this z)
		Float3 new(this x / n, this y / n, this z / n)
	}

	dot: func (right: Float3) -> Float {
		dot(this, right)
	}

}

operator + (left, right: Float3) -> Float3 {
	Float3 new(left x + right x, left y + right y, left z + right z)
}

operator - (left, right: Float3) -> Float3 {
	Float3 new(left x - right x, left y - right y, left z - right z)
}

operator * (left: Float3, right: Float) -> Float3 {
	Float3 new(left x * right, left y * right, left z * right)
}

dot: func (a, b: Float3) -> Float {
	a x * b x + a y * b y + a z * b z
}


Ray: class {
	origin: Float3
	direction: Float3

	init: func (=origin, =direction){ }
}

Hit: class {
	t: Float
	N: Float3
	P: Float3
	object: Sphere	

	init: func (=object){ }
	shade: func () -> Color { object shade(this) }
}

Sphere: class {
	center: Float3
	radius: Float

	init: func (=center, =radius){ }

	intersect?: func (ray: Ray) -> Hit {
		a := dot(ray direction, ray direction)
		b := 2. * dot(ray direction, ray origin)
		c := dot(ray origin, ray origin) - sqrt(radius)
		d := b * b - 4 * a * c
		if (d < 0) {
			return null
		}
		t1 := (-b + sqrt(d)) / (2 * a)
		t2 := (-b - sqrt(d)) / (2 * a)
		t := t1 < t2 ? t1 : t2
		if (t < 0) {
			return null
		}
		hit := Hit new(this)
		hit t = t
		hit P = ray origin + ray direction * t
		hit N = (hit P - center) normalize()
		hit
	}

	shade: func (hit: Hit) -> Color {
		f := hit N y > 0. ? hit N y : 0.
		Color new(0.25, 0.25, 0.25) + Color new(0.5, 0.5, 0.5) * f
	}

}


Color: class {
	r, g, b: Float

	init: func (=r, =g, =b) { }
}

operator + (a, b: Color) -> Color {
	Color new(a r + b r, a g + b g, a b + b b)
}

operator / (a: Color, b: Float) -> Color {
	Color new(a r / b, a g / b, a b / b)
}

operator * (a: Color, b: Float) -> Color {
	Color new(a r * b, a g * b, a b * b)
}


rando: func -> Float {
	(rand() % 1000) / 1000.
}

main: func (args: ArrayList<String>) {
	width := (args size > 1) ? args[1] toInt() : 200
	height := (args size > 2) ? args[2] toInt() : width
	samples_per_pixel := (args size > 3) ? args[3] toInt() : 3

	// output ppm
	"P3\n%d %d\n255\n" format(width, height) print()

	world := Sphere new(Float3 new(0, 0, 0), 1)

	r := Ray new(Float3 new(0., 0., -3.), Float3 new(0, 0, 0))
	for (y in 0..height){
		for (x in 0..width){
			c := Color new(0, 0, 0)
			for (n in 0..samples_per_pixel){
				// jitter a little bit
				xx := (x + rando() * 1. - 1.) as Float
				yy := (y + rando() * 1. - 1.) as Float

				focus := Float3 new(-2. + (4. * xx / (width - 1.)), 2. - (4. * yy / (height - 1.)), 0)
				r direction = (focus - r origin) normalize()
				hit := world intersect?(r)
				if (hit)
					c += hit shade()
			}
			c = c / samples_per_pixel as Float
			"%d %d %d " format((c r * 255) as Int, (c g * 255) as Int, (c b * 255) as Int) print()
		}
	}	

}
