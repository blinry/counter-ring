default:
	openscad -Dpart=1 -o inner.stl counter-ring.scad
	openscad -Dpart=2 -o outer.stl counter-ring.scad
	openscad -Dpart=3 -o tension.stl counter-ring.scad
	openscad -Dpart=4 -o ring1.stl counter-ring.scad
	openscad -Dpart=5 -o ring2.stl counter-ring.scad
