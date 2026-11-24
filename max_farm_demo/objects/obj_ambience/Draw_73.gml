// ===== АТМОСФЕРА (DRAW END) — поверх всех объектов, под интерфейсом =====
var _cam = view_camera[0];
var _cx = camera_get_view_x(_cam), _cy = camera_get_view_y(_cam);
var _cw = camera_get_view_width(_cam), _ch = camera_get_view_height(_cam);

// --- пылинки: тёплые светлые точки, мерцают ---
if (motes_alpha > 0) {
    draw_set_color((room == rm_forest_entrance) ? make_color_rgb(230, 245, 210) : make_color_rgb(255, 240, 200));
    for (var m = 0; m < array_length(motes); m++) {
        var d = motes[m];
        var _tw = 0.55 + 0.45 * sin(d.ph / 37);
        draw_set_alpha(d.a * _tw * motes_alpha);
        var _x = floor(_cx + d.x), _y = floor(_cy + d.y);
        if (d.big) draw_rectangle(_x, _y, _x + 1, _y + 1, false);
        else       draw_point(_x, _y);
    }
}

// --- бабочки: тельце 1x3, крылья раскрываются и складываются ---
if (bfly_alpha > 0 && room == rm_farm) {
    for (var b = 0; b < array_length(butterflies); b++) {
        var f = butterflies[b];
        var _bx = floor(f.x), _by = floor(f.y + sin(f.ph / 14) * 3);
        var _open = (f.ph div 5) mod 2 == 0;
        draw_set_alpha(bfly_alpha);
        draw_set_color(f.c1);
        if (_open) {
            draw_rectangle(_bx - 3, _by - 2, _bx - 1, _by, false);   // верхние крылья
            draw_rectangle(_bx + 1, _by - 2, _bx + 3, _by, false);
            draw_set_color(f.c2);
            draw_rectangle(_bx - 2, _by + 1, _bx - 1, _by + 2, false); // нижние крылья
            draw_rectangle(_bx + 1, _by + 1, _bx + 2, _by + 2, false);
        } else {
            draw_rectangle(_bx - 1, _by - 3, _bx - 1, _by, false);   // крылья сложены вверх
            draw_rectangle(_bx + 1, _by - 3, _bx + 1, _by, false);
        }
        draw_set_color(make_color_rgb(50, 35, 25));
        draw_rectangle(_bx, _by - 1, _bx, _by + 1, false);           // тельце
        // лёгкая тень на земле
        draw_set_color(c_black); draw_set_alpha(0.12 * bfly_alpha);
        draw_rectangle(_bx - 1, f.y + 14, _bx + 1, f.y + 14, false);
    }
    draw_set_alpha(1);
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
