$fn=180;
outer_socket_depth = 12;
hex_depth = 6.5;
handle_thickness = 8;
handle_curve = 65;
handle_width=18;

handle_curve_radius = 130;
handle_curve_angle = 45;

hex_mm = 7;
cyl_cutout = sqrt((2*pow(hex_mm, 2)) / (cos(60)+1)); // 60deg for hex (360/6)
echo("dist to origin", sqrt(pow((cyl_cutout*sin(60))/2, 2) + pow((cyl_cutout*cos(60)+cyl_cutout)/2, 2)));
echo("func says 7mm hex gives", polygon_edge_dist_to_corner_dist(hex_mm, 6));
echo("orig calc for 7mm hex gives", cyl_cutout);

//difference to make hex socket
difference()
{	
    cylinder(h=outer_socket_depth, d=handle_width);
    
	// Hex section
	rotate(360/12) translate([0,0,-0.5]) cylinder(h=outer_socket_depth, d=cyl_cutout, $fn=6);
	// Inner circle section
	rotate(360/12) translate([0,0,hex_depth]) cylinder(h=outer_socket_depth-hex_depth + 0.5, d=cyl_cutout+0.5);
    
    //We make the bottom of the socket a circle because the shaft isn't a pefect hex all the way down - it gets a little wider at the base where it meets the grinder
    inner_circle_depth = 1.5; //this plus hex_depth should equal the length of exposed hex shaft
    
    lower_shaft_width=12.5;
    // Outer circle section
	rotate(360/12) translate([0,0,hex_depth+inner_circle_depth]) cylinder(h=outer_socket_depth-hex_depth + 0.5, d=lower_shaft_width);
}

spin_loc = [33,-90,0]; //location of bearing (trial and error)
spin_d = 21-0.01;


//need to make a circle segment that is d(handle_width) wide
//linear_extrude(angle=20) translate([200,0]) circle(d=handle_width);
translate([0,0,-handle_thickness]) 
{
	// handle arc
	difference() 
	{ 
        chamfer_radius = 2;
        chamferred_handle(handle_width, handle_thickness, handle_curve_radius, handle_curve_angle, chamfer_radius);
			
		translate([0,0,-0.5])
		{
            //trim remaining arc from just after the bearing
            translate(spin_loc - [5, 95, 0]) cube([120, 100, 20]);
			
			// remove the cylinder for the spinner
			translate(spin_loc) cylinder(h=handle_thickness+1, d=spin_d);
		}
	}
	
	// add rounded end under socket/nut
	cylinder(d=handle_width+2,  h = handle_thickness); 
	
	// Add cool grinder knob
	translate(spin_loc)
	{
        clearance = 0.4;
		stator(clearance);
		difference()
		{
			rotor(clearance);
			translate([0,0,-0.5]) cylinder(h=handle_thickness*2 + 1, d=5.5); //hole for bolt shaft
			translate([0,0,8-4]) cylinder(h=5, d=polygon_edge_dist_to_corner_dist(8.2, 6), $fn=6); //hex hole for bolt head
		}
	}
}


function polygon_edge_dist_to_corner_dist(edge_dist, num_sides) = sqrt((2*pow(edge_dist, 2)) / (cos(360/num_sides)+1));

module chamferred_handle(width, thickness, curve_radius = 130, curve_angle = 45, chamfer_amount = 2)
{
  circ_r = chamfer_amount;
  rec_w = width - 2 * circ_r;
  rec_h = thickness - 2 * circ_r;
  rotate([0,180,0]) mirror([0,1,0])
  translate([-curve_radius - width/2,0,-thickness]) 
  rotate_extrude(angle = curve_angle) 
  translate([curve_radius, 0, 0])
  rotate(180) mirror([1,1,0])
  translate([circ_r,circ_r,0]) 
  {
    minkowski()
    {
      square([rec_h, rec_w]);
      echo ([rec_h, rec_w]);
      circle(r=circ_r);
    }
  }
}



// Total height;
h = 8;
// Stator outer diameter.
sd1 = 21;
// Rotor base diameter
rd1 = 16;
// Rotor center diameter
rd2 = 8;
// Rotor base height
rh1 = 1;
// Small values for maintaining manifold.
eps1 = 0.01;
eps2 = eps1*2;
eps3 = eps1*3;

// Lower half of a rotor, without the screwdriver slot and text.
module half_rotor() {
  slope_height = (rd1 - rd2) / 2;
  // Base cylinder
  cylinder(d=rd1, h=1);
  // Slope cone
  translate([0, 0, rh1-eps1]) cylinder(d1=rd1, d2=rd2, h=slope_height);
  // Center cylinder
  cylinder(d=rd2, h=h/2+eps1);
}

// Full rotor
module rotor(clearance) {
  difference() {
    union() {
      // Bottom half
      half_rotor(); 
      // Top half
      translate([0, 0, h]) mirror([0, 0, 1]) half_rotor();
    }
  }
}

// Lower half of a stator. 
module half_stator(clearance) {
  difference() {
    // Add
    cylinder(d=sd1, h=h/2+eps1);
    // Remove
    translate([0, 0, -eps1]) cylinder(d=rd2+2*clearance, h=h/2+eps3);
    translate([0, 0, -eps1]) 
      cylinder(d1 = rd1+2*rh1+2*clearance+eps2, 
         d2=rd2+2*clearance,
         h = eps1 + rh1 + (rd1-rd2)/2);
  }
}

// Full rotor.
module stator(clearance) {
  half_stator(clearance);
  translate([0, 0, h]) mirror([0, 0, 1]) half_stator(clearance);
}