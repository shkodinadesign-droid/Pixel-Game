// ===== ПЕРВОЕ ИСПЫТАНИЕ (DRAW): фон, поверхности, страж, камни, глина =====
cave_draw_backdrop();
draw_set_color(make_color_rgb(14, 10, 16));
draw_rectangle(WALL_R, 96, 960, 144, false);            // проём выхода наверху справа
draw_rectangle(0, 400, WALL_L, F, false);               // проём входа слева
side_draw_solids();

// страж
var _sh = (g_shake > 0) ? g_shake : 0;
cave_draw_clay(gx + random_range(-_sh, _sh), F - gr + random_range(-_sh, _sh), gr, g_ang, g_eye, g_arm, g_arm_up, g_mood);

// падающие и рассыпающиеся камни
for (var i = 0; i < array_length(rocks); i++) {
    var r = rocks[i];
    if (r.st != "fall" && r.st != "crumble") continue;
    var _x1 = r.x - ROCK_W / 2, _a = (r.st == "crumble") ? 1 - r.t / 18 : 1;
    draw_set_alpha(_a);
    draw_set_color(make_color_rgb(90, 80, 96));    draw_roundrect_ext(_x1, r.y, _x1 + ROCK_W, r.y + ROCK_H, 12, 12, false);
    draw_set_color(make_color_rgb(126, 114, 132)); draw_roundrect_ext(_x1 + 4, r.y + 3, _x1 + ROCK_W - 12, r.y + 12, 8, 8, false);
    if (r.st == "crumble") { draw_set_color(make_color_rgb(54, 46, 60)); draw_line(_x1 + 10, r.y + 6, _x1 + 26, r.y + ROCK_H); draw_line(_x1 + 36, r.y + 4, _x1 + 30, r.y + ROCK_H); }
    draw_set_alpha(1);
}

// поднимающаяся глина
if (clay_y < F) {
    draw_set_color(make_color_rgb(132, 88, 62));
    for (var _x = 0; _x < room_width; _x += 8) {
        var _top = clay_y + sin(_x / 23 + flick / 18) * 2;
        draw_rectangle(_x, _top, _x + 7, F, false);
    }
    draw_set_color(make_color_rgb(160, 112, 80));
    for (var _x = 0; _x < room_width; _x += 8) draw_rectangle(_x, clay_y + sin(_x / 23 + flick / 18) * 2, _x + 7, clay_y + sin(_x / 23 + flick / 18) * 2 + 2, false);
    draw_set_color(make_color_rgb(110, 72, 52));                       // пузыри
    for (var k = 0; k < 6; k++) { var _bx = (k * 157 + flick * 0.7) mod room_width; draw_circle(_bx, clay_y + 10 + (k mod 3) * 14, 2 + (flick div 10 + k) mod 2, false); }
}
draw_set_color(c_white);
