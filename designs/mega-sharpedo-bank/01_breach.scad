// Mega Sharpedo coin bank — Design 1: "Breach"
// The shark leaps nose-up out of a splash. Coins go in a slot on its back,
// slide down through the hollow water column, and collect in the wave base.
// Empty it with the twist-lock plug under the base.
//
//   part = "preview"  coloured assembly (F5)
//   part = "bank"     printable shell (F6, export STL; tree supports)
//   part = "plug"     twist-lock plug (print cap-down)

include <lib/bank_common.scad>

part = "preview";

TILT  = 24;    // nose-up angle
LIFT  = 112;   // height of the body pivot above the table

// Body blobs, nose toward +X: [x, z, rx, ry, rz]
BODY = [
    [-82, 10,  9,  5,  7],
    [-52,  5, 24, 18, 21],
    [-12,  0, 38, 30, 34],
    [ 28,  1, 30, 29, 31],
    [ 56,  4, 18, 18, 20],
];
// Hollow only from the column forward so coins always drain into it.
CAVITY = [ for (i = [2 : 4]) BODY[i] ];
CAV_REAR = [-30, 0, 18, 17, 18];

HINGE = [20, -6];          // jaw hinge (x, z)
UP_S  = 0.14;              // upper jaw plane slope
LO_S  = -0.62;             // lower jaw plane slope

function up_z(x) = HINGE[1] + UP_S * (x - HINGE[0]);
function lo_z(x) = HINGE[1] + LO_S * (x - HINGE[0]);

// Linear profile through the blobs, used to place teeth on the jaw rims.
function prof(x, k) = lookup(x, [ for (b = BODY) [b[0], b[k]] ]);
function rim_y(x, z) =
    let(dz = (z - prof(x, 1)) / prof(x, 4))
    abs(dz) < 1 ? prof(x, 3) * sqrt(1 - dz * dz) : 0;

module envelope(inset = 0) spine(BODY, inset);

module mouth_cut(grow = 0)
    rotate([90, 0, 0]) linear_extrude(height = 80, center = true)
        offset(delta = grow)
            polygon([HINGE, [120, up_z(120)], [120, lo_z(120)]]);

module teeth() {
    intersection() {
        envelope(0.6);
        union() {
            for (x = [26 : 5 : 74], s = [-1, 1]) {
                yu = rim_y(x, up_z(x)) - 3.2;
                if (yu > 1.5)
                    translate([x, s * yu, up_z(x) + 0.8]) rotate([0, 172, 0]) tooth(7, 2.3);
                yl = rim_y(x, lo_z(x)) - 3.2;
                if (yl > 1.5)
                    translate([x, s * yl, lo_z(x) - 0.8]) rotate([0, 32, 0]) tooth(7, 2.3);
            }
        }
    }
}

module dorsal_fin()
    fin([[-48, 0, 26], [-18, 0, 30], [-42, 0, 72], [-52, 0, 66]], 2.6);

module tail_fins() {
    fin([[-74, 0, 12], [-96, 0, 6], [-120, 0, 54]], 2.2);     // swept crescent tail
    fin([[-74, 0, 6],  [-92, 0, 2], [-108, 0, -30]], 2.2);
}

module side_fins() for (s = [-1, 1]) {
    fin([[0, s * 24, -14], [-30, s * 20, -14], [-44, s * 62, -40]], 2.4);
    fin([[-58, s * 12, -12], [-66, s * 10, -10], [-76, s * 26, -24]], 1.8);   // pelvic
}

module nose_drill() {
    translate([66, 0, 14]) rotate([0, 62, 0]) cylinder(h = 30, r1 = 9, r2 = 0.6, $fn = 7);
    for (a = [-1, 1]) translate([62, a * 7, 18]) rotate([a * 30, 40, 0])
        cylinder(h = 14, r1 = 4, r2 = 0.4, $fn = 6);
}

// Decals sit 0.5 mm proud of the skin so they read in preview and can be
// split out for multi-colour printing.
module decal(c = C_YELLOW) color(c) render() intersection() { envelope(-0.5); children(); }

// Mega Sharpedo's yellow scar marks: short diagonal slashes on the cheeks.
module scar(x, z, ang, len = 22, w = 3.4)
    for (s = [-1, 1]) decal()
        translate([x, s * prof(x, 3), z]) rotate([0, ang, 0]) cube([w, 18, len], center = true);

module scars() {
    scar(24, 16, -35);
    scar(31, 20, -35, 14);
    scar(-4, 18, 40, 26, 3.8);
    scar(-14, 14, 40, 18, 3);
}

module eyes() for (s = [-1, 1]) {
    color(C_YELLOW) decal() translate([46, s * 22, 14]) sphere(7, $fn = 32);
    color(C_BLACK) intersection() {
        envelope(-0.9); translate([48, s * 22, 14]) sphere(3.4, $fn = 24);
    }
}

module belly() translate([0, 0, -60]) rotate([0, -12, 0]) cube([400, 200, 100], center = true);

module shark_solid() {
    difference() {
        union() {
            envelope();
            dorsal_fin(); tail_fins(); side_fins(); nose_drill();
        }
        color(C_MAW) mouth_cut();
    }
    teeth();
}

module shark_cavity() {
    difference() {
        union() { spine(CAVITY, WALL); hull() { blob(CAV_REAR); blob(CAVITY[0], WALL); } }
        mouth_cut(WALL);
    }
    // coin slot through the back, just ahead of the dorsal fin
    translate([2, 0, 34]) coin_slot(24);
}

module shark_frame() translate([0, 0, LIFT]) rotate([0, -TILT, 0]) translate([30, 0, 0]) children();

// ---- Splash base --------------------------------------------------------
BASE_R = 60; BASE_H = 18; DOME_H = 34; COL_R = 17;

module base_outer() {
    cylinder(h = BASE_H, r = BASE_R, $fn = 120);
    translate([0, 0, BASE_H]) cylinder(h = DOME_H, r1 = BASE_R, r2 = COL_R + 6, $fn = 120);
    cylinder(h = LIFT, r = COL_R, $fn = 64);
}
module base_inner() {
    translate([0, 0, PLUG_FLOOR]) cylinder(h = BASE_H - PLUG_FLOOR, r = BASE_R - WALL, $fn = 120);
    translate([0, 0, BASE_H - 0.01])   // 45° ceiling: prints without support
        cylinder(h = DOME_H, r1 = BASE_R - WALL, r2 = COL_R + 6 - WALL, $fn = 120);
    cylinder(h = LIFT + 4, r = COL_R - WALL, $fn = 64);
}

module splash() {
    for (i = [0 : 9]) rotate(i * 36 + 8)
        translate([COL_R + 10, 0, BASE_H + DOME_H - 10])
            rotate([0, 28 + (i % 3) * 8, 0]) cylinder(h = 22 + (i % 2) * 10, r1 = 6, r2 = 0.8, $fn = 10);
    for (i = [0 : 17]) rotate(i * 20)        // foam crest around the rim
        translate([BASE_R - 9 + (i % 2) * 3, 0, BASE_H + 2 - (i % 3) * 2]) sphere(9 - (i % 3), $fn = 20);
}

module bank() {
    difference() {
        union() {
            base_outer();
            splash();
            shark_frame() shark_solid();
        }
        base_inner();
        shark_frame() shark_cavity();
        plug_socket();
    }
}

module preview() {
    color(C_WATER) difference() { base_outer(); plug_socket(); }
    color(C_FOAM) splash();
    shark_frame() {
        difference() {
            union() {
                color(C_NAVY) envelope();
                color(C_NAVY) dorsal_fin();
                color(C_NAVY) tail_fins();
                color(C_BLUE) side_fins();
                color(C_YELLOW) nose_drill();
            }
            color(C_MAW) mouth_cut();
            translate([2, 0, 34]) color(C_BLACK) coin_slot(24);
        }
        // render() bakes these to meshes so the preview keeps their colour
        color(C_RED) render() difference() {
            intersection() { envelope(-0.5); belly(); }
            mouth_cut();
        }
        color(C_WHITE) render() teeth();
        color(C_YELLOW) scars();
        eyes();
    }
}

if (part == "preview") preview();
else if (part == "bank") bank();
else if (part == "plug") plug();
