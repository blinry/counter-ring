// Which part should be displayed? 0 = all, 1 to 5 are the five parts.
// The Makefile uses this variable to automate .stl export.
part = 0;

// THESE VARIABLES ARE PROBABLY FINE TO MODIFY:

// Inner diameter in mm:
inner_diameter = 20;

// Width of the whole ring in mm:
width = 10;

// Number of segments per ring:
num_segments = 10;

// THESE VARIABLES MIGHT DEPEND ON THE PRINTER, modify with caution:

// Extrusion width in mm in PrusaSlicer:
wall_thickness = 0.45;

// Layer height in PrusaSlicer:
layer_height = 0.2;

// THESE ARE INTERNAL VARIABLES, you can try to modify them when your
// tolerances don't work:

// Distance between parts which we want be able to rotate:
wiggle_room = 0.2;

// Distance between parts we want to plug into each other, fixed:
plug_room = 0.06;

// Distance between the number rings:
gap = layer_height*9;

// Width of the rim at the edges of the ring:
rim_width = 0.5;

// Width of a single number ring:
ring_width = (width - 2*rim_width - gap)/2;

// How much bigger do we want to make the tension ring, to account for
// it being slightly bent?
tension_ring_stretch_factor = 1.01;

// A "small number":
eps = 0.02;

// How many corners does a circle have?
$fn = 128;

// A hollow cylinder.
module cyl(h, inner_radius, thickness) {
    difference() {
        cylinder(h=h,r=inner_radius + thickness,center=true);
        cylinder(h=h+eps,r=inner_radius,center=true);
    }
}

// The teeth on the outer and inner ring.
module teeth(flip, width_to_inside, extra_size) {
    translate([0,0,flip*(width/2 - rim_width)]) {
        difference() {
            for (i = [0:num_segments-1]) {
                angle = -(i+0.5)*360/num_segments;
                rotate([0,0,angle]) {
                    translate([0,-inner_diameter/2 - 4*wall_thickness + width_to_inside/2 - plug_room + eps,0]) {
                        rotate([0, 45, 0]) {
                            cube([ring_width/3 + extra_size, width_to_inside, ring_width/3 + extra_size], center=true);
                        }
                    }
                }
            }
            translate([0,0,flip*(ring_width/2+rim_width)]) {
                cylinder(ring_width, r=inner_diameter*0.7, center=true);
            }
        }
    }
}

// The inner part of the base ring.
module inner() {
    difference() {
        union() {
            cyl(width, inner_diameter/2, wall_thickness);
            translate([0,0,-width/2 + rim_width/2]) {
                cyl(rim_width, inner_diameter/2, 4*wall_thickness + plug_room);
            }
            teeth(-1, 3.5*wall_thickness + plug_room, 0);
        }
        cutout();
    }
}

// The outer cutout in the base rings.
module cutout() {
    difference() {
        union() {
            cutout_single();
            mirror([0,0,1]) {
                cutout_single();
            }
        }
        cylinder(h=width*6/8, r=inner_diameter*0.7, center=true);
    }
}

// Helper function for cutout().
module cutout_single() {
    translate([0, -inner_diameter/2, width/2]) {
        rotate([0,45,0]) {
            size = inner_diameter/2*0.4;
            cube([size,10,size], center=true);
        }
    }
}

// The outer part of the base ring.
module outer() {
    difference() {
        union() {
            translate([0,0,rim_width/2 + layer_height/2]) {
                cyl(width - rim_width - layer_height, inner_diameter/2 + wall_thickness + plug_room, wall_thickness);
            }
            translate([0,0,width/2 - rim_width/2]) {
                cyl(rim_width, inner_diameter/2 + wall_thickness + plug_room, 3*wall_thickness);
            }
            teeth(1, 2.5*wall_thickness, 0);
        }
        teeth(-1, 3*wall_thickness + eps, plug_room + layer_height);
        cutout();
    }
}

// The thin tension ring.
module tension() {
    cyl(2*layer_height, tension_ring_stretch_factor*(inner_diameter/2 + 2*wall_thickness + 1*plug_room), 2.5*wall_thickness);
}

// A number ring. Flip can be 1 or -1.
module ring(flip) {
    translate([0,0,flip*(ring_width/2 + gap/2)]) {
        difference() {
            cyl(ring_width, inner_diameter/2 + 2*wall_thickness + plug_room + wiggle_room, 3*wall_thickness);
            for (i = [0:num_segments-1]) {
                angle = -i*360/num_segments;
                rotate([0,0,angle]) {
                    translate([0,-inner_diameter/2 - 4.8*wall_thickness - plug_room - wiggle_room + wall_thickness,0]) {
                        rotate([90,90,0]) {
                            linear_extrude(2*wall_thickness) {
                                text(str(i), font="Helvetica", size=ring_width*1.1, halign="center", valign="center");
                            }
                        }
                    }
                }
            }
            for (i = [0:num_segments-1]) {
                angle = -(i+0.5)*360/num_segments;
                rotate([0,0,angle]) {
                    translate([0,-inner_diameter/2 - 4*wall_thickness - plug_room - wiggle_room,0]) {
                        translate([0, 0, flip*ring_width/2]) {
                            rotate([0, 45, 0]) {
                                cube([ring_width/3 + plug_room, ring_width*3/4, ring_width/3 + plug_room], center=true);
                            }
                        }
                    }
                }
            }
        }
    }
}

if (part == 0 || part == 1)
    inner();
if (part == 0 || part == 2)
    outer();
if (part == 0 || part == 3)
    tension();
if (part == 0 || part == 4)
    ring(1);
if (part == 0 || part == 5)
    ring(-1);