// ===== АТМОСФЕРА (DRAW END) — поверх всех объектов, под интерфейсом =====
var _cam = view_camera[0];
var _cx = camera_get_view_x(_cam), _cy = camera_get_view_y(_cam);
var _cw = camera_get_view_width(_cam), _ch = camera_get_view_height(_cam);

// --- тайная комната: тёмно-фиолетовая дымка, тень по краям, свечение котелка и лунный свет ---
var _secret = (room == rm_secret_room);
if (_secret) {
    var _rw = room_width, _rh = room_height;
    draw_set_color(make_color_rgb(40, 18, 70));                 // общая сиреневая полутьма
    draw_set_alpha(0.34);
    draw_rectangle(0, 0, _rw, _rh, false);
    draw_set_color(make_color_rgb(12, 4, 24));                  // виньетка: края темнее
    for (var k = 0; k < 24; k++) {
        var _e = (24 - k) * 4;
        draw_set_alpha(0.022);
        draw_rectangle(0, 0, _rw, _e, false);
        draw_rectangle(0, _rh - _e, _rw, _rh, false);
        draw_rectangle(0, 0, _e, _rh, false);
        draw_rectangle(_rw - _e, 0, _rw, _rh, false);
    }
    gpu_set_blendmode(bm_add);
    var _pulse = 0.75 + 0.25 * sin(current_time / 700) + random_range(-0.04, 0.04);
    draw_set_color(make_color_rgb(120, 40, 160));               // котелок на столе с зельями
    for (var g = 0; g < 4; g++) {
        draw_set_alpha(0.07 * _pulse);
        draw_circle(470, 190, 18 + g * 16, false);
    }
    draw_set_color(make_color_rgb(60, 70, 120));                // лунный свет из окна
    for (var g = 0; g < 3; g++) {
        draw_set_alpha(0.06);
        draw_ellipse(300 - 34 - g * 10, 100 - 46 - g * 8, 300 + 34 + g * 10, 100 + 46 + g * 8, false);
    }
    draw_set_color(make_color_rgb(150, 100, 40));               // тёплая лампа над горшками
    for (var g = 0; g < 3; g++) {
        draw_set_alpha(0.06 * (0.95 + 0.05 * sin(current_time / 230)));
        draw_circle(171, 182, 10 + g * 12, false);
    }
    draw_set_color(make_color_rgb(60, 70, 120));
    draw_set_alpha(0.05);                                       // пятно света на полу под окном
    draw_ellipse(250, 236, 350, 276, false);
    gpu_set_blendmode(bm_normal);
}

// --- пылинки: тёплые светлые точки, мерцают (в тайной комнате — сиреневые искорки) ---
if (motes_alpha > 0) {
    draw_set_color(_secret ? make_color_rgb(215, 190, 255) : ((room == rm_forest_entrance) ? make_color_rgb(230, 245, 210) : make_color_rgb(255, 240, 200)));
    for (var m = 0; m < array_length(motes); m++) {
        var d = motes[m];
        var _tw = 0.55 + 0.45 * sin(d.ph / 37);
        if (_secret) _tw = 0.25 + 0.75 * power(0.5 + 0.5 * sin(d.ph / 19 + m * 1.7), 3);   // вспыхивают и гаснут
        draw_set_alpha(min(1, d.a * _tw * motes_alpha * (_secret ? 1.6 : 1)));
        var _x = floor(_cx + d.x), _y = floor(_cy + d.y);
        if (d.big) draw_rectangle(_x, _y, _x + 1, _y + 1, false);
        else       draw_point(_x, _y);
        if (_secret && d.big && _tw > 0.8) {                    // искорка-крестик на пике
            draw_set_alpha(0.5 * motes_alpha);
            draw_point(_x - 1, _y); draw_point(_x + 2, _y); draw_point(_x, _y - 1); draw_point(_x, _y + 2);
        }
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
