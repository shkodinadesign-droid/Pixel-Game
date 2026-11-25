// ===== СТАРАЯ ПЕЩЕРА — ПРОХОД (DRAW END): свет, капли, пылинки, подсказки =====
var _m = max_side;
var _amb = global.has_lantern ? make_color_rgb(66, 56, 82) : make_color_rgb(44, 38, 58);
light_surf = cave_light_begin(light_surf, _amb);
var _day = make_color_rgb(150, 142, 128);                                    // дневной свет от входа
draw_rectangle_colour(0, 0, 300, room_height, _day, c_black, c_black, _day, false);
if (!global.has_lantern) {                                                   // фонарь на выступе тлеет
    cave_light_circle(LANTERN_X, 410, 46 + sin(flick / 7) * 3, make_color_rgb(150, 110, 60));
}
if (instance_exists(_m)) {
    var _lx = cave_lantern_x(_m), _ly = cave_lantern_y(_m);
    if (global.has_lantern) {
        var _r = lerp(60, 175, lantern_glow) + sin(flick / 9) * 3;
        cave_light_circle(_lx, _ly, _r, make_color_rgb(240, 196, 136));
        cave_light_circle(_lx, _ly, _r * 0.45, make_color_rgb(90, 70, 40));
    } else {
        cave_light_circle(_lx, _ly - 10, 70, make_color_rgb(90, 84, 96));   // глаза привыкают к темноте
    }
}
if (keeper_state == "strike" && keeper_t < 70) cave_light_circle(KEEPER_X - 22, FLOOR_Y - 85, 90, make_color_rgb(80, 120, 160));   // посох светится
if (flash > 0) { draw_set_alpha(flash); draw_set_color(make_color_rgb(120, 140, 180)); draw_rectangle(0, 0, room_width, room_height, false); draw_set_alpha(1); }
cave_light_end(light_surf);
side_draw_edges(0.35);
cave_fx_draw();
if (lantern_near) draw_hint("[E] Взять фонарь", LANTERN_X, 372, true);
