// ===== АТМОСФЕРА (DRAW END) — поверх всех объектов, под интерфейсом =====
var _cam = view_camera[0];
var _cx = camera_get_view_x(_cam), _cy = camera_get_view_y(_cam);
var _cw = camera_get_view_width(_cam), _ch = camera_get_view_height(_cam);

// --- светлячки в лесу: бледно-зелёные, мерцают ---
for (var k = 0; k < array_length(flies); k++) {
    var f = flies[k];
    var _a = 0.25 + 0.35 * max(0, sin(f.ph / 45));
    draw_set_color(make_color_rgb(200, 255, 190));
    draw_set_alpha(_a * 0.35); draw_circle(f.x, f.y, 3, false);
    draw_set_alpha(_a);        draw_rectangle(f.x - 1, f.y - 1, f.x, f.y, false);
}

if (rain_alpha > 0) {
    // лёгкая серо-синяя пасмурность
    draw_set_color(make_color_rgb(40, 50, 70));
    draw_set_alpha(0.16 * rain_alpha);
    draw_rectangle(_cx, _cy, _cx + _cw, _cy + _ch, false);

    // капли — тонкие белые чёрточки
    draw_set_color(c_white);
    var _dx = lengthdir_x(1, RAIN_ANGLE), _dy = lengthdir_y(1, RAIN_ANGLE);
    for (var i = 0; i < RAIN_COUNT; i++) {
        var d = drops[i];
        draw_set_alpha(d.a * rain_alpha);
        var _x = _cx + d.x, _y = _cy + d.y;
        draw_line(_x, _y, _x - _dx * d.len, _y - _dy * d.len);
    }
    // всплески — короткие расходящиеся штрихи
    for (var j = 0; j < array_length(splashes); j++) {
        var s = splashes[j];
        var _r = 1 + s.t * 0.4;
        draw_set_alpha((1 - s.t / 10) * 0.35 * rain_alpha);
        draw_line(_cx + s.x - _r - 1, _cy + s.y, _cx + s.x - _r, _cy + s.y - 1);
        draw_line(_cx + s.x + _r, _cy + s.y - 1, _cx + s.x + _r + 1, _cy + s.y);
    }
}
draw_set_alpha(1);
draw_set_color(c_white);
