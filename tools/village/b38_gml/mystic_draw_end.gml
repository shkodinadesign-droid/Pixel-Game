// ===== ТАЙНЫЙ ЛЕС (DRAW END): сумрак с фиолетовым оттенком, свечение, светлячки =====
var _cam = view_camera[0];
var _cx = camera_get_view_x(_cam), _cy = camera_get_view_y(_cam);
var _cw = camera_get_view_width(_cam), _ch = camera_get_view_height(_cam);
// сумрак
draw_set_color(make_color_rgb(34, 16, 60)); draw_set_alpha(0.34);
draw_rectangle(_cx, _cy, _cx + _cw, _cy + _ch, false);
// виньетка
draw_set_color(make_color_rgb(10, 4, 20));
for (var k = 0; k < 16; k++) {
    var _e = (16 - k) * 6; draw_set_alpha(0.03);
    draw_rectangle(_cx, _cy, _cx + _cw, _cy + _e, false); draw_rectangle(_cx, _cy + _ch - _e, _cx + _cw, _cy + _ch, false);
    draw_rectangle(_cx, _cy, _cx + _e, _cy + _ch, false); draw_rectangle(_cx + _cw - _e, _cy, _cx + _cw, _cy + _ch, false);
}
gpu_set_blendmode(bm_add);
// фиолетовое свечение у земли
for (var i = 0; i < array_length(glows); i++) {
    var g = glows[i];
    if (g.x < _cx - 80 || g.x > _cx + _cw + 80 || g.y < _cy - 80 || g.y > _cy + _ch + 80) continue;
    var _p = 0.75 + 0.25 * sin(current_time / 900 + g.ph);
    draw_set_color(make_color_rgb(120, 50, 170));
    for (var k = 0; k < 3; k++) { draw_set_alpha(0.06 * _p); draw_circle(g.x, g.y, g.r * (0.5 + k * 0.35), false); }
}
// светлячки: точка + мягкий ореол, мерцают
for (var i = 0; i < array_length(fireflies); i++) {
    var f = fireflies[i];
    if (f.x < _cx - 10 || f.x > _cx + _cw + 10 || f.y < _cy - 10 || f.y > _cy + _ch + 10) continue;
    var _tw = 0.5 + 0.5 * sin(f.ph / 22 + i);
    var _col = (f.c == 1) ? make_color_rgb(200, 150, 255) : make_color_rgb(210, 255, 140);
    draw_set_color(_col);
    draw_set_alpha(0.18 * _tw); draw_circle(f.x, f.y, 6, false);
    draw_set_alpha(0.9 * _tw);  draw_rectangle(floor(f.x), floor(f.y), floor(f.x) + 1, floor(f.y) + 1, false);
}
gpu_set_blendmode(bm_normal);
draw_set_alpha(1); draw_set_color(c_white);
