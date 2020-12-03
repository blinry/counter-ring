//use <text_on.scad>

inner_diameter = 20;
thickness = 2;
width = 10;
num_segments = 10;

rim_width = width/10;
gap = width/10;
tension_ring_stretch_factor = 1.01;

eps = 0.01;
$fn = 128;

module cyl(h, inner_radius, thickness) {
    difference() {
        cylinder(h=h,r=inner_radius + thickness,center=true);
        cylinder(h=h+eps,r=inner_radius,center=true);
    }
}

module inner() {
    union() {
        cyl(width, inner_diameter/2, thickness/4);
        translate([0,0,-width/2 + rim_width/2]) {
            cyl(rim_width, inner_diameter/2, thickness*3/4);
        }
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
    }
}

module tension() {
    cyl(gap/2, tension_ring_stretch_factor*(inner_diameter/2 + thickness/2), tension_ring_stretch_factor*thickness/2);
}

module ring(flip) {
    ring_width = (width - 2*rim_width - gap)/2;
    
    translate([0,0,flip*(ring_width/2 + gap/2)]) {
        difference() {
            cyl(ring_width, inner_diameter/2 + thickness/2, thickness/2);
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
                                cube([1, ring_width*3/4, 1], center=true);
                            }
                        }
                    }
                }
            }
        }
    }
    
}

inner();
outer();
tension();
ring(1);
ring(-1);