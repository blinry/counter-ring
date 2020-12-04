default:
	openscad -Dpart=1 -o inner.stl ring-counter.scad
	openscad -Dpart=2 -o outer.stl ring-counter.scad
	openscad -Dpart=3 -o tension.stl ring-counter.scad
	openscad -Dpart=4 -o ring1.stl ring-counter.scad
	openscad -Dpart=5 -o ring2.stl ring-counter.scad
