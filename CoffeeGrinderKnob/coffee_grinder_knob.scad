$fn=180;

//Mk1, largely a copy of the old coffee grinder knob

screw_width = 5;

//copied from the old German coffee grinder.
knob_radius = 16;
knob_base_radius = 8;
knob_height = 38;

base_translate = (knob_height - (knob_radius) - (knob_base_radius*2));

module my_knob()
{
    translate([0, knob_height - knob_radius])
    rotate(270)
    difference()
    {
        hull()
        {
            circle(r=knob_radius);            
            translate([base_translate, -(knob_base_radius)])
            {
                square(knob_base_radius*2);
            };
        }
        translate([-30,-30]) square([60,30]);
    }
}

difference()
{
    rotate_extrude()
    {
        my_knob();
    };
    
    translate([0,0,-0.5])
    cylinder(d=screw_width, h=25);
}





function polygon_edge_dist_to_corner_dist(edge_dist, num_sides) = sqrt((2*pow(edge_dist, 2)) / (cos(360/num_sides)+1));