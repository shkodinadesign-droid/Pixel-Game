// ===== СТАРАЯ ПЕЩЕРА — ПРОХОД (DRAW END): свет, хранитель, капли, светлячки, подсказки =====
// Пещера тёмно-серая, не чёрная: общий свет высокий, фонарь добавляет тёплый круг и видно вперёд.
var _m = max_side;
var _amb = global.has_lantern ? make_color_rgb(176, 170, 184) : make_color_rgb(140, 136, 152);
light_surf = cave_light_begin(light_surf, _amb);
var _day = make_color_rgb(90, 88, 80);                                       // дневной свет от входа
draw_rectangle_colour(0, 0, 300, room_height, _day, c_black, c_black, _day, false);
if (!global.has_lantern) cave_light_circle(LANTERN_X, 410, 60 + sin(flick / 7) * 3, make_color_rgb(110, 80, 40));   // фонарь на выступе тлеет
if (instance_exists(_m)) {
    var _lx = cave_lantern_x(_m), _ly = cave_lantern_y(_m);
    if (global.has_lantern) {
        var _r = lerp(80, 260, lantern_glow) + sin(flick / 9) * 3;
        cave_light_circle(_lx + _m.facing * 30, _ly, _r, make_color_rgb(90, 66, 34));   // тёплый круг, чуть вперёд
        cave_light_circle(_lx, _ly, _r * 0.4, make_color_rgb(50, 36, 16));
    }
}
if (keeper_state == "strike" && keeper_t < 70) cave_light_circle(KEEPER_X - 22, FLOOR_Y - 85, 90, make_color_rgb(60, 90, 130));   // посох светится
if (flash > 0) { draw_set_alpha(flash); draw_set_color(make_color_rgb(120, 140, 180)); draw_rectangle(0, 0, room_width, room_height, false); draw_set_alpha(1); }
cave_light_end(light_surf);
side_draw_edges(0.35);
// хранитель — поверх света, всегда виден (проявляется, когда Макс с фонарём подходит)
if (keeper_state != "gone") {
    var _up = (keeper_state == "strike") ? clamp(keeper_t / 12, 0, 1) * (keeper_t < 24) : 0;
    cave_draw_keeper(KEEPER_X + keeper_dx, FLOOR_Y, keeper_alpha, 8 + sin(flick / 40) * 6, _up);
}
// старинный фонарь на выступе — тоже поверх света, тёплое свечение
if (!global.has_lantern) {
    gpu_set_blendmode(bm_add);
    draw_set_color(make_color_rgb(255, 190, 90)); draw_set_alpha(0.12 + 0.05 * sin(flick / 7));
    draw_circle(LANTERN_X, 410, 18, false);
    gpu_set_blendmode(bm_normal); draw_set_alpha(1);
}
cave_fx_draw();
if (lantern_near) draw_hint("[E] Взять фонарь", LANTERN_X, 372, true);
