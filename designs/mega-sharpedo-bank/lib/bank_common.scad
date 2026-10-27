// Shared parts for the Mega Sharpedo coin banks.
// Units: millimetres. Target printer: any FDM printer, 0.2 mm layers.

// ---- Palette (Mega Sharpedo) -------------------------------------------
C_NAVY   = [0.11, 0.20, 0.42];   // upper body
C_BLUE   = [0.18, 0.33, 0.62];   // fin highlights
C_RED    = [0.72, 0.13, 0.16];   // lower jaw / underside
C_MAW    = [0.35, 0.03, 0.06];   // inside of the mouth
C_CREAM  = [0.96, 0.92, 0.80];   // belly band
C_YELLOW = [1.00, 0.80, 0.10];   // nose drill, scars, eye ring
C_WHITE  = [0.98, 0.98, 0.96];   // teeth
C_BLACK  = [0.05, 0.05, 0.07];   // pupils
C_WATER  = [0.30, 0.62, 0.85];   // splash base
C_FOAM   = [0.90, 0.96, 1.00];

// ---- Print settings -----------------------------------------------------
WALL        = 2.4;   // shell thickness
SLOT_LEN    = 33;    // fits every US / EUR / GBP coin up to a US half dollar
SLOT_W      = 4.2;
PLUG_R      = 20;    // through-hole radius in the floor
PLUG_FLOOR  = 3;     // floor thickness the plug locks against
PLUG_CLEAR  = 0.3;   // fit clearance per side

// Ellipsoid "blob": p = [x, z, rx, ry, rz]
module blob(p, inset = 0, fn = 48)
    translate([p[0], 0, p[1]])
        scale([max(p[2] - inset, 0.5), max(p[3] - inset, 0.5), max(p[4] - inset, 0.5)])
            sphere(1, $fn = fn);

// Smooth sweep through a list of blobs (hull of consecutive pairs).
module spine(pts, inset = 0, fn = 48)
    for (i = [0 : len(pts) - 2])
        hull() { blob(pts[i], inset, fn); blob(pts[i + 1], inset, fn); }

// Rounded fin: hull of small spheres placed at the given 3D points.
module fin(pts, r = 2.2, fn = 16)
    hull() for (p = pts) translate(p) sphere(r, $fn = fn);

// Cone tooth pointing along +Z from its base.
module tooth(h = 6, r = 2.4)
    cylinder(h = h, r1 = r, r2 = 0.25, $fn = 12);

// Coin slot cutter, long axis along X, centred at origin, cuts along Z.
module coin_slot(depth = 40)
    hull() for (s = [-1, 1])
        translate([s * (SLOT_LEN - SLOT_W) / 2, 0, -depth / 2])
            cylinder(h = depth, d = SLOT_W, $fn = 24);

// Bayonet socket cut into a floor whose underside sits at z = 0.
// Two notches let the plug lugs through; a quarter turn locks it.
module plug_socket() {
    translate([0, 0, -1]) cylinder(h = PLUG_FLOOR + 2, r = PLUG_R, $fn = 96);
    for (a = [0, 180]) rotate(a)
        translate([PLUG_R - 2, -5.5, -1]) cube([6.5, 11, PLUG_FLOOR + 2]);
}

// Matching twist-lock plug, printed cap-down (flat on the bed).
module plug() {
    r = PLUG_R - PLUG_CLEAR;
    cap = 4;
    difference() {
        cylinder(h = cap, r = PLUG_R + 6, $fn = 96);
        // finger groove on the outside face for twisting
        translate([-PLUG_R, -2.5, -1]) cube([2 * PLUG_R, 5, 2.6]);
    }
    translate([0, 0, cap]) cylinder(h = PLUG_FLOOR + 0.4, r = r, $fn = 96);
    translate([0, 0, cap + PLUG_FLOOR + 0.4])
        difference() {
            cylinder(h = 2.2, r = r, $fn = 96);
            translate([0, 0, -1]) cylinder(h = 4, r = r - 3, $fn = 96);
        }
    for (a = [0, 180]) rotate(a)                                   // lugs
        translate([r - 3, -5, cap + PLUG_FLOOR + 0.4]) cube([6, 10, 2.2]);
}
