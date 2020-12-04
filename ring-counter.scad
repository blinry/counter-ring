part = 0;

inner_diameter = 21;
wall_thickness = 0.45;
layer_height = 0.2;
width = 10;
num_segments = 10;

// Distance between the number rings:
gap = layer_height*6;

// Distance between parts which we want be able to rotate:
wiggle_room = 0.2;

// Distance between parts we want to plug into each other, fixed:
plug_room = 0.08;

// Width of the rim at the edges of the ring:
rim_width = width/10;

// Width of a single number ring:
ring_width = (width - 2*rim_width - gap)/2;

tension_ring_stretch_factor = 1;

eps = 0.02;
$fn = 128;

module cyl(h, inner_radius, thickness) {
    difference() {
        cylinder(h=h,r=inner_radius + thickness,center=true);
        cylinder(h=h+eps,r=inner_radius,center=true);
    }
}

module teeth(flip, width_to_inside, extra_size) {
    translate([0,0,flip*(width/2 - rim_width)]) {
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
    }
}

module inner() {
    union() {
        cyl(width, inner_diameter/2, wall_thickness);
        translate([0,0,-width/2 + rim_width/2]) {
            cyl(rim_width, inner_diameter/2, 4*wall_thickness + plug_room);
        }
        teeth(-1, 3.5*wall_thickness + plug_room, 0);
    }
}

module outer() {
    difference() {
        union() {
            translate([0,0,rim_width/2]) {
                cyl(width - rim_width, inner_diameter/2 + wall_thickness + plug_room, wall_thickness);
            }
            translate([0,0,width/2 - rim_width/2]) {
                cyl(rim_width, inner_diameter/2 + wall_thickness + plug_room, 3*wall_thickness);
            }
            teeth(1, 2.5*wall_thickness, 0);
        }
        teeth(-1, 3*wall_thickness, plug_room);
    }
}

module tension() {
    cyl(3*layer_height, tension_ring_stretch_factor*(inner_diameter/2 + 2*wall_thickness + plug_room + wiggle_room), 2*wall_thickness);
}

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
                                text(str(i), font="Helvetica:style=Bold", size=ring_width*1.2, halign="center", valign="center");
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

/*module mushroom(width) {
    rotate([180,0,0]) {
        union() {
            cylinder(h=1,r1=1,r2=width);

            translate([0,0,0]) {
                cylinder(h=6, r=0.2);
            }
        }
    }
}

mushroom(3);
translate([0,8,0]){
    mushroom(6);
}*/

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