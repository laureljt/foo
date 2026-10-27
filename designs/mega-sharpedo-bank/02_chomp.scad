// Mega Sharpedo coin bank — Design 2: "Chomp"
// A chunky chibi Mega Sharpedo sitting on its belly with its jaws wide open.
// Feed coins straight into the mouth: a slot in the floor of the mouth drops
// them into the hollow body. The twist-lock plug is underneath.
//
//   part = "preview"  coloured assembly (F5)
//   part = "bank"     printable shell (F6, export STL; prints upright)
//   part = "plug"     twist-lock plug (print cap-down)

include <lib/bank_common.scad>

part = "preview";

// [x, z, rx, ry, rz], nose toward +X
BODY = [
    [-48, 42, 14, 10, 14],
    [-16, 40, 44, 44, 46],
    [ 22, 38, 40, 42, 44],
    [ 44, 40, 18, 26, 28],
];
MOUTH_C = [54, 0, 32];
MOUTH_R = [36, 35, 20];

// Conservative inside test: point lies within one of the body blobs.
function in_body(p) = max([ for (b = BODY)
    let(d = [(p[0] - b[0]) / b[2], p[1] / b[3], (p[2] - b[1]) / b[4]]) d * d < 0.92 ? 1 : 0 ]) == 1;

module envelope(inset = 0)
    intersection() {
        spine(BODY, inset, 64);
        translate([-200, -200, inset > 0 ? PLUG_FLOOR : 0]) cube(400);   // flat bottom
    }

module mouth(grow = 0)
    translate(MOUTH_C)
        scale([MOUTH_R[0] + grow, MOUTH_R[1] + grow, MOUTH_R[2] + grow]) sphere(1, $fn = 64);

// Two staggered rows of teeth line the mouth bowl, pointing at its centre
// line; anything outside the head is trimmed off by the envelope.
module teeth()
    intersection() {
        envelope(0.4);
        for (row = [0, 1], t = [row * 9 : 18 : 359]) {
            a = 92 + row * 12;
            p = MOUTH_C + [MOUTH_R[0] * cos(a), MOUTH_R[1] * sin(a) * cos(t), MOUTH_R[2] * sin(a) * sin(t)];
            if (in_body(p))   // skip teeth whose root would float past the lips
                translate(p) rotate([t + 90, 0, 0]) translate([0, 0, -1.5]) tooth(9, 3);
        }
    }

module dorsal_fin() fin([[-34, 0, 76], [-4, 0, 80], [-40, 0, 124], [-50, 0, 118]], 3);
module tail_fin()   fin([[-54, 0, 44], [-66, 0, 42], [-86, 0, 74], [-80, 0, 76]], 2.6);
module side_fins() for (s = [-1, 1])     // splayed on the table like little feet
    fin([[8, s * 30, 8], [-28, s * 30, 8], [-12, s * 66, 3]], 3);

module nose_drill() {
    translate([40, 0, 62]) rotate([0, 38, 0]) cylinder(h = 32, r1 = 10, r2 = 0.8, $fn = 7);
    for (s = [-1, 1]) translate([32, s * 8, 66]) rotate([s * 28, 20, 0])
        cylinder(h = 15, r1 = 4.5, r2 = 0.5, $fn = 6);
}

module belly() translate([0, 0, -24]) rotate([0, 10, 0]) cube([300, 300, 80], center = true);

module decal(c = C_YELLOW, lift = 0.6) color(c) render() intersection() { envelope(-lift); children(); }

module scar(x, z, ang, len = 22, w = 3.6)
    for (s = [-1, 1]) decal()
        translate([x, s * 44, z]) rotate([0, ang, 0]) cube([w, 30, len], center = true);

module eyes() for (s = [-1, 1]) {
    decal(C_YELLOW) translate([26, s * 38, 60]) sphere(11, $fn = 32);
    decal(C_BLACK, 1.0) translate([30, s * 38, 61]) sphere(5.5, $fn = 24);
    decal(C_WHITE, 1.4) translate([31, s * 37, 64]) sphere(2, $fn = 16);
}

module slot_cut() translate([34, 0, MOUTH_C[2] - MOUTH_R[2] + 2]) rotate(90) coin_slot(16);

module shell() {
    difference() {
        union() { envelope(); dorsal_fin(); tail_fin(); side_fins(); nose_drill(); }
        mouth();
    }
    teeth();
}

module cavity()
    difference() {
        envelope(WALL);
        mouth(WALL);
    }

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
        color(C_MAW) mouth();
        color(C_BLACK) slot_cut();
    }
    color(C_RED) render() difference() {
        intersection() { envelope(-0.6); belly(); }
        mouth();
    }
    color(C_WHITE) render() teeth();
    scar(-6, 60, 35, 26);
    scar(-16, 54, 35, 18, 3);
    scar(8, 74, -30, 16, 3);
    eyes();
}

if (part == "preview") preview();
else if (part == "bank") bank();
else if (part == "plug") plug();
