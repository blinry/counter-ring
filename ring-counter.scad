//use <text_on.scad>

inner_diameter = 20;
thickness = 2;
width = 10;
num_segments = 10;

// Distance between the number rings:
gap = width/8;

// Distance between parts which we want be able to rotate:
wiggle_room = 1/20;

// Width of the rim at the edges of the ring:
rim_width = width/10;

// Width of a single number ring:
ring_width = (width - 2*rim_width - gap)/2;

tension_ring_stretch_factor = 1.01;

eps = 0.01;
$fn = 128;

module cyl(h, inner_radius, thickness) {
    difference() {
        cylinder(h=h,r=inner_radius + thickness,center=true);
        cylinder(h=h+eps,r=inner_radius,center=true);
    }
}

module teeth(flip) {
    translate([0,0,flip*(width/2 - rim_width)]) {
        for (i = [0:num_segments-1]) {
            angle = -(i+0.5)*360/num_segments;
            rotate([0,0,angle]) {
                translate([0,-inner_diameter/2 - thickness*(5/8) + eps,0]) {
                    rotate([0, 45, 0]) {
                        cube([ring_width/4, thickness/4, ring_width/4], center=true);
                    }
                }
            }
        }
    }
}

module inner() {
    union() {
        cyl(width, inner_diameter/2, thickness/4);
        translate([0,0,-width/2 + rim_width/2]) {
            cyl(rim_width, inner_diameter/2, thickness*3/4);
        }
        teeth(-1);
    }
}

module outer() {
    union() {
        translate([0,0,rim_width/2]) {
            cyl(width - rim_width, inner_diameter/2 + thickness/4, thickness/4);
        }
        translate([0,0,width/2 - rim_width/2]) {
            cyl(rim_width, inner_diameter/2 + thickness/4, thickness/2);
        }
        teeth(1);
    }
}

module tension() {
    cyl(gap/3, tension_ring_stretch_factor*(inner_diameter/2 + thickness/2), tension_ring_stretch_factor*thickness/2);
}

module ring(flip) {
    translate([0,0,flip*(ring_width/2 + gap/2)]) {
        difference() {
            cyl(ring_width, inner_diameter/2 + thickness/2 + wiggle_room, thickness/2);
            for (i = [0:num_segments-1]) {
                angle = -i*360/num_segments;
                rotate([0,0,angle]) {
                    translate([0,-inner_diameter/2 - thickness*3/4,0]) {
                        rotate([90,90,0]) {
                            linear_extrude(thickness/2) {
                                text(str(i), font="Helvetica:style=Bold", size=ring_width*3/4, halign="center", valign="center");
                            }
                        }
                    }
                }
            }
            for (i = [0:num_segments-1]) {
                angle = -(i+0.5)*360/num_segments;
                rotate([0,0,angle]) {
                    translate([0,-inner_diameter/2 - thickness*3/4,0]) {
                        translate([0, 0, flip*ring_width/2]) {
                            rotate([0, 45, 0]) {
                                cube([ring_width/4, ring_width*3/4, ring_width/4], center=true);
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

inner();
outer();

tension();
#ring(1);
#ring(-1);