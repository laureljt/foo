// Mega Sharpedo coin bank — Design 3: "Torpedo"
// A faceted, low-poly take on the classic piggy-bank pose: the shark lies
// level, standing on its belly and pectoral fins, with a locked jagged grin.
// Coin slot on the back, twist-lock plug in the belly.
//
//   part = "preview"  coloured assembly (F5)
//   part = "bank"     printable shell (F6, export STL; prints upright)
//   part = "plug"     twist-lock plug (print cap-down)

include <lib/bank_common.scad>

part = "preview";

FACETS = 10;   // lower = chunkier low-poly look

// [x, z, rx, ry, rz], nose toward +X
BODY = [
    [-88, 40, 10,  6,  8],
    [-56, 36, 28, 22, 26],
    [-12, 34, 42, 34, 40],
    [ 34, 35, 34, 32, 36],
    [ 66, 38, 18, 20, 22],
];

module envelope(inset = 0)
    intersection() {
        spine(BODY, inset, FACETS);
        translate([-200, -200, inset > 0 ? PLUG_FLOOR : 0]) cube(400);
    }

// The closed grin: a sloped band across the snout.
GRIN_TOP = [[24, 34], [84, 42]];
GRIN_BOT = [[24, 26], [84, 26]];
module grin_band(grow = 0)
    rotate([90, 0, 0]) linear_extrude(height = 100, center = true)
        offset(delta = grow) polygon([GRIN_BOT[0], GRIN_BOT[1], GRIN_TOP[1], GRIN_TOP[0]]);

function lerp(a, b, t) = a + (b - a) * t;

// Interlocking triangle teeth filling the grin band.
module teeth() {
    n = 9;
    intersection() {
        envelope(-0.2);
        grin_band();
        rotate([90, 0, 0]) linear_extrude(height = 100, center = true) offset(delta = -0.3)
            for (i = [0 : n - 1]) {
                t0 = i / n; t1 = (i + 1) / n; tm = (i + 0.5) / n;
                // upper fang hangs from the top edge
                polygon([lerp(GRIN_TOP[0], GRIN_TOP[1], t0) + [0, 1],
                         lerp(GRIN_TOP[0], GRIN_TOP[1], t1) + [0, 1],
                         lerp(lerp(GRIN_BOT[0], GRIN_BOT[1], tm), lerp(GRIN_TOP[0], GRIN_TOP[1], tm), 0.12)]);
                // lower fang rises between them
                if (i < n - 1)
                    polygon([lerp(GRIN_BOT[0], GRIN_BOT[1], tm) - [0, 1],
                             lerp(GRIN_BOT[0], GRIN_BOT[1], tm + 1 / n) - [0, 1],
                             lerp(lerp(GRIN_BOT[0], GRIN_BOT[1], t1), lerp(GRIN_TOP[0], GRIN_TOP[1], t1), 0.88)]);
            }
    }
}

module dorsal_fin() fin([[-44, 0, 64], [-8, 0, 70], [-40, 0, 112], [-52, 0, 106]], 2.4, 4);
module tail_fin() {
    fin([[-84, 0, 44], [-98, 0, 40], [-124, 0, 82]], 2.2, 4);
    fin([[-84, 0, 38], [-96, 0, 36], [-114, 0, 10]], 2.2, 4);
}
module side_fins() for (s = [-1, 1])      // doubles as the front legs
    fin([[18, s * 26, 16], [-14, s * 28, 14], [-6, s * 62, 2.2]], 2.2, 4);

module nose_drill() {
    translate([74, 0, 50]) rotate([0, 58, 0]) cylinder(h = 32, r1 = 9, r2 = 0.6, $fn = 5);
    for (s = [-1, 1]) translate([68, s * 7, 54]) rotate([s * 30, 34, 0])
        cylinder(h = 14, r1 = 4, r2 = 0.4, $fn = 4);
}

module belly() translate([0, 0, -28]) rotate([0, -6, 0]) cube([400, 200, 100], center = true);

module decal(c = C_YELLOW, lift = 0.6) color(c) render() intersection() { envelope(-lift); children(); }

module side_plate(x, z, r, fn) for (s = [-1, 1])
    translate([x, s * 50, z]) rotate([90, 0, 0]) cylinder(h = 100, r = r, center = true, $fn = fn);

module scar(x, z, ang, len = 24, w = 4)
    for (s = [-1, 1]) decal()
        translate([x, s * 40, z]) rotate([0, ang, 0]) cube([w, 30, len], center = true);

module eyes() {
    decal(C_YELLOW) side_plate(48, 48, 8, 6);
    decal(C_BLACK, 1.0) side_plate(50, 48, 3.8, 6);
}

module slot_cut() translate([-2, 0, 74]) coin_slot(24);

module shell() union() {
    difference() {
        union() { envelope(); dorsal_fin(); tail_fin(); side_fins(); nose_drill(); }
        grin_band();
    }
    teeth();
}

module cavity() difference() { envelope(WALL); grin_band(WALL); }

module bank()
    difference() {
        shell();
        cavity();
        slot_cut();
        translate([-12, 0, 0]) plug_socket();
    }

module preview() {
    difference() {
        union() {
            color(C_NAVY) envelope();
            color(C_NAVY) dorsal_fin();
            color(C_NAVY) tail_fin();
            color(C_BLUE) side_fins();
            color(C_YELLOW) nose_drill();
        }
        color(C_MAW) grin_band();
        color(C_BLACK) slot_cut();
    }
    color(C_RED) render() difference() {
        intersection() { envelope(-0.6); belly(); }
        grin_band(0.4);
    }
    color(C_WHITE) render() teeth();
    scar(10, 50, 35, 30);
    scar(0, 46, 35, 20, 3);
    scar(36, 58, -30, 18, 3);
    eyes();
}

if (part == "preview") preview();
else if (part == "bank") bank();
else if (part == "plug") plug();
