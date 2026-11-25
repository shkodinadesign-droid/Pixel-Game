// ===== СТАРАЯ ПЕЩЕРА — ПРОХОД (DRAW): фон, поверхности, фонарь на выступе, хранитель =====
cave_draw_backdrop();
side_draw_solids();
if (!global.has_lantern) {                  // старинный фонарь на каменном выступе
    var _lx = LANTERN_X, _ly = 420;
    draw_set_color(make_color_rgb(70, 52, 34)); draw_rectangle(_lx - 5, _ly - 14, _lx + 5, _ly, false);
    draw_set_color(make_color_rgb(150, 110, 60)); draw_rectangle(_lx - 3, _ly - 11, _lx + 3, _ly - 3, false);
    draw_set_color(make_color_rgb(70, 52, 34)); draw_line(_lx - 4, _ly - 14, _lx, _ly - 20); draw_line(_lx, _ly - 20, _lx + 4, _ly - 14);
    draw_set_color(c_white);
}
if (keeper_state != "gone") {
    var _up = (keeper_state == "strike") ? clamp(keeper_t / 12, 0, 1) * (keeper_t < 24) : 0;
    cave_draw_keeper(KEEPER_X + keeper_dx, FLOOR_Y, keeper_alpha, 8 + sin(flick / 40) * 6, _up);
}
