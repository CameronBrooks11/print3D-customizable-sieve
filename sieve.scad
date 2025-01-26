/* Customizable sieve by DrLex and contributors, formerly thing:2578935
 * based on Sieve (or Seive?) by pcstru (thing:341357).
 * Released under Creative Commons - Attribution - Share Alike license
 * https://github.com/DrLex0/print3D-customizable-sieve
 * Version 2.5, 2023/08
 */

/* [General] */

// Choose the shape of the sieve. The heart shape is a bit of a gimmick, but it works.
shape = "round"; // [round,square,heart]

// For square shape, this is the length of one side. For heart shape, this is the width and depth of the heart.
outer_diameter = 40; //[5.0:.1:250.0]

// Additional X dimension length for creating elongated shapes (rectangles or ellipses). Not applicable to heart shape.
stretch = 0.0; //[0:.1:250.0]

// Width of the filter wires. You shouldn't try to go below your nozzle diameter, although it might work within certain
// limits.
strand_width = .4; //[.10:.01:10.00]

// Thickness (height) of the filter wires. If 'Offset strands' is enabled, the filter grid will be twice this thick.
strand_thickness = .4; //[.10:.01:5]

// Spacing between filter wires, i.e. hole size.
gap_size = .8; //[.10:.01:10.00]

// Rotation (in degrees) of filter wires in relation to shape.
grid_rotation = 0; // [0:1:90]

// Thickness (width) of the outer rim (will increase with height if taper > 1).
rim_thickness = 1.7; //[.3:.01:5]

// Total height of the outer rim.
rim_height = 3; //[0:.1:50]

// Taper of the tube: scale factor of top versus bottom contour. Not applicable to heart shape.
taper = 1; //[1:0.01:3]

/* [Stacking Rim] */

// Define the allowance to achieve the desired diameter clearance between the sieve and the rim for a snap fit
snap_allowance = 0.3; // Range: [0:0.1:5]

// Define the height allowance to to prevent seam gaps between the sieve and the rim for the snap fit
height_allowance = 0.4; // Range: [0:0.1:5]

// Add a stackable rim to the sieve, increases the total height of a single sieve by x3 the rim height
stackable_rim = "no"; // [yes,no]

/* [Advanced] */

// If yes, the wires will be placed in different layers, which leads to a quicker and possibly better print, especially
// when using thin strands.
offset_strands = "yes"; // [yes,no]

// For most accurate results with thin strands, set this to your first layer height. This will ensure the strands only
// start printing from the second layer, avoiding any problems due to the first layer being squished, or using a wider
// extrusion, etc.
lift_strands = 0; //[0.00:.01:2.00]

// Shift origin of the grid, percentage of grid pattern size (100% shift is same as 0% shift)
shift_x = 0; //[0:1:99]
shift_y = 0; //[0:1:99]

/*[Special Variables]*/

// Segments for round shapes; lower values create polygons (e.g., 3 = triangle). Also affects heart shapes.
$fn = 72; //[3:1:256]

/* [Hidden] */

zFite = $preview ? 0.1 : 0; // zFite is a small value to avoid z-fighting in the CSG preview
shift_x_abs = (gap_size + strand_width) * shift_x / 100;
shift_y_abs = (gap_size + strand_width) * shift_y / 100;

// Module  : flat_heart
// Params :
// 	r_x = radius in X direction
// 	r_y = radius in Y direction
// 	thick = thickness of the heart
// 	inside = 0: heart with inside volume removed, 1: inside volume of the heart
module flat_heart(r_x, r_y, thick, inside)
{
    // radius + 2 * square
    s_x = (r_x * 2) / 1.5;
    b = s_x / 2;
    w = thick * 2;

    if (inside == 1)
    {
        translate([ -r_x, -r_x, 0 ]) union()
        {
            square(s_x);
            translate([ b, s_x, 0 ]) circle(d = s_x);
            translate([ s_x, b, 0 ]) circle(d = s_x);
        }
    }
    else
    {
        translate([ -r_x, -r_x, 0 ]) difference()
        {
            union()
            {
                square(s_x);
                translate([ b, s_x, 0 ]) circle(d = s_x);
                translate([ s_x, b, 0 ]) circle(d = s_x);
            }
            translate([ w / 2, w / 2 ]) square([ s_x - (w / 2), s_x - w ]);
            translate([ w / 2, w / 2 ]) square([ s_x - w, s_x - (w / 2) ]);
            translate([ b, s_x, 0 ]) circle(d = s_x - w);
            translate([ s_x, b, 0 ]) circle(d = s_x - w);
        }
    }
}

// A tube:
// Params:
// 	r_x = radius in X direction
// 	r_y = radius in Y direction
// 	thick = thickness of the tube
// 	height = height of the tube
// 	taper = scale factor applied to the extrusion, applied to the entire shape (i.e. wall thickness will vary if !=1)
// 	inside = 0: tube with inside volume removed, 1: inside volume of the tube, 2: inside and outside volume of tube
module tube(r_x, r_y, thick, height, taper, inside = 0)
{
    if (shape == "round")
    {
        stretchx = r_x / r_y;
        linear_extrude(height = height, convexity = 4, scale = taper)
        {
            if (inside == 0)
            {
                difference()
                {
                    scale(1 / stretchx) scale([ stretchx, 1 ]) circle(r = r_x);
                    offset(delta = -thick) scale(1 / stretchx) scale([ stretchx, 1 ]) circle(r = r_x);
                }
            }
            else if (inside == 1)
            {
                scale(1 / stretchx) offset(delta = -thick) scale([ stretchx, 1 ]) circle(r = r_x);
            }
            else
            {
                scale(1 / stretchx) scale([ stretchx, 1 ]) circle(r = r_x);
            }
        }
    }
    else if (shape == "heart")
    {
        linear_extrude(height = height) flat_heart(r_x, r_y, thick, inside);
    }
    else
    {
        linear_extrude(height = height, convexity = 4, scale = taper)
        {
            if (inside == 0)
            {
                difference()
                {
                    square([ 2 * r_x, 2 * r_y ], center = true);
                    square([ 2 * (r_x - thick), 2 * (r_y - thick) ], center = true);
                }
            }
            else if (inside == 1)
            {
                square([ 2 * (r_x - thick), 2 * (r_y - thick) ], center = true);
            }
            else
            {
                square([ 2 * r_x, 2 * r_y ], center = true);
            }
        }
    }
}

// Module  : grid
// Params :
// 	width = width of the grid
// 	length = length of the grid
// 	strand_width = width of grid strands
// 	strand_thick = thickness of grid strands
// 	gap = gap between strands
// 	do_offset = offset the strands (true or false)
// 	sh_x and sh_y = shift the grid over these distances
module grid(width, length, strand_width, strand_thick, gap, do_offset, sh_x, sh_y)
{
    wh = width / 2;
    lh = length / 2;
    // Let's enforce symmetry just for the heck of it
    wh_align = (strand_width + gap) * floor(wh / (strand_width + gap)) + strand_width + gap / 2;
    lh_align = (strand_width + gap) * floor(lh / (strand_width + gap)) + strand_width + gap / 2;

    for (iy = [-wh_align:strand_width + gap:wh_align])
    {
        translate([ -lh, iy + sh_y, 0 ]) cube([ length, strand_width, strand_thick ]);
    }

    for (ix = [-lh_align:strand_width + gap:lh_align])
    {
        if (do_offset == "yes")
        {
            translate([ ix + sh_x, -wh, strand_thick ]) cube([ strand_width, width, strand_thick ]);
        }
        else
        {
            translate([ ix + sh_x, -wh, 0 ]) cube([ strand_width, width, strand_thick ]);
        }
    }
}

// Module  : Sieve
// Params :
// 	od_x = outer X dimension of the cylinder or rectangle
// 	od_y = outer Y dimension of the cylinder or rectangle
// 	strand_width = width of grid strands
// 	strand_thick = thickness of grid strands
// 	gap = gap between strands
// 	rim_thick = thickness of outer rim
// 	rim_height = height of outer rim
// 	do_offset = offset the strands ("yes" or "no")
// 	sh_x and sh_y = shift the grid over these distances
module sieve(od_x, od_y, strand_width, strand_thick, gap, rim_thick, rim_height, taper, do_offset, sh_x, sh_y)
{
    or_x = od_x / 2;
    or_y = od_y / 2;
    upper_height = (do_offset == "yes") ? rim_height - 2 * strand_thick - lift_strands + .01
                                        : rim_height - strand_thick - lift_strands + .01;
    upper_start = (do_offset == "yes") ? 2 * strand_thick - .01 : strand_thick - .01;

    // Add .01 margin to ensure good overlap, avoid non-manifold
    if (lift_strands > 0)
    {
        tube(or_x, or_y, rim_thick, lift_strands + .01, 1);
    }
    translate([ 0, 0, lift_strands ])
    {
        // Generate larger grid and then trim it to the outer shape, minus some margin.
        // However, don't make it way larger because this will needlessly increase computing time.
        intersection()
        {
            rotate([ 0, 0, grid_rotation ])
                grid(od_y * 1.2, od_x * 1.2, strand_width, strand_thick, gap, do_offset, sh_x, sh_y);
            translate([ 0, 0, -.01 ]) tube(or_x, or_y, .1, rim_height + 2 * strand_thick + .1, 1, 1);
        }

        translate([ 0, 0, upper_start ]) tube(or_x, or_y, rim_thick, upper_height, taper);
    }

    tube(or_x, or_y, rim_thick - .4, rim_height - upper_height, 1);
}

// Module  : sieve_stackable_rim
// Params :
// 	od_x = outer X dimension of the cylinder or rectangle
// 	od_y = outer Y dimension of the cylinder or rectangle
// 	rim_thick = thickness of outer rim
// 	rim_height = height of outer rim
// 	snap_h_allowance = height allowance for snap fit
// 	snap_rim_allowance = rim allowance for snap fit
module sieve_stackable_rim(od_x, od_y, rim_thick, rim_height, snap_h_allowance, snap_rim_allowance)
{

    children();

    translate([ 0, 0, rim_height ])
    {
        difference()
        {
            cylinder(d = outer_diameter, h = rim_height - snap_h_allowance);

            translate([ 0, 0, -zFite / 2 ]) cylinder(d = outer_diameter - 2 * rim_thickness, h = rim_height + zFite);

            translate([ 0, 0, -zFite / 2 ]) difference()
            {
                cylinder(d = outer_diameter + snap_rim_allowance, h = rim_height + zFite);
                cylinder(d = outer_diameter - rim_thickness, h = rim_height);
            }
        }
    }

    translate([ 0, 0, -rim_height ])
    {
        difference()
        {
            cylinder(d = outer_diameter, h = rim_height);
            translate([ 0, 0, -zFite / 2 ]) cylinder(d = outer_diameter - 2 * rim_thickness, h = rim_height + zFite);

            translate([ 0, 0, -zFite / 2 ])
                cylinder(d = outer_diameter - rim_thickness + snap_rim_allowance, h = rim_height + zFite);
        }
    }
}

if (stackable_rim == "no")
    // Generate the sieve
    sieve(outer_diameter + stretch, outer_diameter, strand_width, strand_thickness, gap_size, rim_thickness, rim_height,
          taper, offset_strands, shift_x_abs, shift_y_abs);
else
    // Generate the stackable rim
    sieve_stackable_rim(od_x = outer_diameter, od_y = outer_diameter, rim_thick = rim_thickness,
                        rim_height = rim_height, snap_h_allowance = height_allowance,
                        snap_rim_allowance = snap_allowance)
        // Generate the sieve
        sieve(outer_diameter + stretch, outer_diameter, strand_width, strand_thickness, gap_size, rim_thickness,
              rim_height, taper, offset_strands, shift_x_abs, shift_y_abs);