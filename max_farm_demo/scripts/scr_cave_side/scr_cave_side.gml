// ===== ПЕЩЕРА: ВИД СБОКУ (ходьба и прыжки) =====
// В комнатах rm_cave (проход: фонарь, хранитель) и rm_cave_arena (первое испытание — глиняный страж)
// обычный Макс (obj_max, вид сверху) спрятан и не управляется (global.side_view), вместо него — obj_max_side.
// Поверхности — obj_side_solid: прямоугольник x1..x2 / y1..y2. oneway = каменный уступ: на него можно
// запрыгнуть снизу, стоять сверху. Время суток в пещере стоит (global.clock_paused).
// Графика временная — рисуется кодом (земля, мох, корни, камни).

#macro SIDE_BW 14     // коробка столкновений Макс: ширина
#macro SIDE_BH 40     //                              высота; x,y obj_max_side — левый верх коробки

/// Вход в комнату с видом сбоку (Create контроллера комнаты)
function side_room_begin() {
    forest_episode_init();
    global.side_view    = true;
    global.clock_paused = true;
}
/// Выход из комнаты (CleanUp контроллера) — всё возвращается обычному Макс
function side_room_end() {
    global.side_view    = false;
    global.clock_paused = false;
    if (instance_exists(obj_camera)) obj_camera.follow_obj = obj_max;
}

/// Поверхность. kind: "earth" (пол/стены/потолок), "ledge" (каменный уступ), "rock" (упавшая глыба),
/// "barrier" (каменная перегородка), "hidden" (не рисуется)
function side_solid(_x1, _y1, _x2, _y2, _kind = "earth", _oneway = false) {
    var _s = instance_create_depth(0, 0, 0, obj_side_solid);
    _s.x1 = _x1; _s.y1 = _y1; _s.x2 = _x2; _s.y2 = _y2;
    _s.kind = _kind; _s.oneway = _oneway;
    return _s;
}

/// Коробка Макс в точке (_x,_y) задевает сплошную поверхность (уступы не считаются)
function side_box_hit(_x, _y) {
    var _hit = false;
    with (obj_side_solid) {
        if (!oneway && _x < x2 && _x + SIDE_BW > x1 && _y < y2 && _y + SIDE_BH > y1) { _hit = true; break; }
    }
    return _hit;
}

/// Приземление на уступ: низ коробки был не ниже верха уступа и пересёк его — верх уступа, иначе -1
function side_oneway_land(_x, _old_bottom, _new_bottom) {
    var _top = -1;
    with (obj_side_solid) {
        if (oneway && _x < x2 && _x + SIDE_BW > x1 && _old_bottom <= y1 && _new_bottom >= y1) {
            if (_top < 0 || y1 < _top) _top = y1;
        }
    }
    return _top;
}

/// Макс стоит на уступе
function side_on_oneway(_x, _bottom) {
    var _on = false;
    with (obj_side_solid) {
        if (oneway && _x < x2 && _x + SIDE_BW > x1 && abs(_bottom - y1) < 0.5) { _on = true; break; }
    }
    return _on;
}

/// Верх ближайшей поверхности под отрезком _x1.._x2 ниже _y (для камней и капель).
/// _solid_only — уступы пропускаются (камни падают сквозь них до пола или глыбы)
function side_ground_below(_x1, _x2, _y, _solid_only = false) {
    var _top = room_height;
    with (obj_side_solid) {
        if ((!_solid_only || !oneway) && _x1 < x2 && _x2 > x1 && y1 >= _y && y1 < _top) _top = y1;
    }
    return _top;
}

/// Детерминированный «шум» 0..1 по координатам — чтобы узор земли не мигал
function side_hash(_a, _b) {
    var _v = sin(_a * 12.9898 + _b * 78.233) * 43758.5453;
    return _v - floor(_v);
}

/// Заполнить прямоугольник спрайтом-тайлом (сетка привязана к миру — узор не «плывёт»)
function side_tile_rect(_spr, _x1, _y1, _x2, _y2, _col = c_white) {
    var _w = sprite_get_width(_spr), _h = sprite_get_height(_spr);
    for (var _ty = floor(_y1 / _h) * _h; _ty < _y2; _ty += _h) {
        for (var _tx = floor(_x1 / _w) * _w; _tx < _x2; _tx += _w) {
            var _l = max(0, _x1 - _tx), _t = max(0, _y1 - _ty);
            var _r = min(_w, _x2 - _tx), _b = min(_h, _y2 - _ty);
            if (_r > _l && _b > _t) draw_sprite_part_ext(_spr, 0, _l, _t, _r - _l, _b - _t, _tx + _l, _ty + _t, 1, 1, _col, 1);
        }
    }
}

/// Рисует все поверхности (вызывать в Draw контроллера).
/// kind: "floor" — коричневая земля (тропа), "stone" — каменная стена/потолок с трещинами,
/// "ledge" — каменная плита-уступ, "rock" — глыба, "barrier" — перегородка, "hidden" — не рисуется
function side_draw_solids() {
    with (obj_side_solid) {
        switch (kind) {
            case "floor":
                side_tile_rect(spr_cave_earth_top, x1, y1, x2, min(y2, y1 + 32));
                if (y2 > y1 + 32) side_tile_rect(spr_cave_earth, x1, y1 + 32, x2, y2);
                break;
            case "stone":
            case "earth":
                side_tile_rect(spr_cave_wall, x1, y1, x2, y2);
                draw_set_color(make_color_rgb(40, 38, 46));
                draw_rectangle(x1, y1, x2 - 1, y2 - 1, true);
                if (y1 <= 0) {     // потолок: корни и мох свисают вниз
                    draw_set_color(make_color_rgb(92, 66, 48));
                    for (var _rx = x1 + 10; _rx < x2; _rx += 37) {
                        var _len = 8 + side_hash(_rx, 3) * 30;
                        if (side_hash(_rx, 7) < 0.6) {
                            draw_line_width(_rx, y2 - 1, _rx + 3, y2 + _len * 0.5, 2);
                            draw_line(_rx + 3, y2 + _len * 0.5, _rx + 1, y2 + _len);
                        }
                    }
                    draw_set_color(make_color_rgb(78, 110, 72));
                    for (var _mx = x1; _mx < x2; _mx += 8) if (side_hash(_mx, y2) < 0.3) draw_rectangle(_mx, y2 - 2, _mx + 5, y2, false);
                }
                break;
            case "ledge":
                side_tile_rect(spr_cave_ledge, x1, y1, x2, y2);
                draw_set_color(make_color_rgb(60, 56, 68)); draw_rectangle(x1, y1, x2 - 1, y2 - 1, true);
                break;
            case "rock":
                draw_set_color(make_color_rgb(104, 100, 112)); draw_roundrect_ext(x1, y1, x2 - 1, y2 - 1, 12, 12, false);
                draw_set_color(make_color_rgb(140, 136, 150)); draw_roundrect_ext(x1 + 4, y1 + 3, x2 - 12, y1 + 12, 8, 8, false);
                draw_set_color(make_color_rgb(60, 56, 66));    draw_line(x1 + (x2 - x1) * 0.6, y1 + 8, x1 + (x2 - x1) * 0.5, y2 - 6);
                draw_roundrect_ext(x1, y1, x2 - 1, y2 - 1, 12, 12, true);
                break;
            case "barrier":
                side_tile_rect(spr_cave_wall, x1, y1, x2, y2, make_color_rgb(200, 190, 215));
                draw_set_color(make_color_rgb(44, 40, 52)); draw_rectangle(x1, y1, x2 - 1, y2 - 1, true);
                break;
        }
    }
    draw_set_color(c_white);
}

/// Светлая кромка уступов и глыб поверх темноты — края платформ всегда видны (вызывать после света)
function side_draw_edges(_alpha) {
    draw_set_alpha(_alpha);
    draw_set_color(make_color_rgb(200, 186, 210));
    with (obj_side_solid) if (kind == "ledge" || kind == "rock") draw_rectangle(x1 + 1, y1, x2 - 2, y1, false);
    draw_set_alpha(1); draw_set_color(c_white);
}

// ---------- свет: карта света умножается на картинку ----------
function cave_light_begin(_surf, _ambient) {
    if (!surface_exists(_surf)) _surf = surface_create(room_width, room_height);
    surface_set_target(_surf);
    draw_clear(_ambient);
    gpu_set_blendmode(bm_add);
    return _surf;
}
function cave_light_circle(_x, _y, _r, _col) {
    draw_circle_colour(_x, _y, _r, _col, c_black, false);
}
function cave_light_end(_surf) {
    gpu_set_blendmode(bm_normal);
    surface_reset_target();
    gpu_set_blendmode_ext(bm_zero, bm_src_colour);   // тёмное темнит, белое не меняет
    draw_surface(_surf, 0, 0);
    gpu_set_blendmode(bm_normal);
}

/// Положение фонаря на поясе Макс (для света)
function cave_lantern_x(_m) { return _m.x + SIDE_BW * 0.5 - _m.facing * 6; }   // на поясе сзади
function cave_lantern_y(_m) { return _m.y + 25; }

// ---------- капли со стен и пылинки (вызывать из контроллера комнаты) ----------
function cave_fx_init() {
    fx_drip_x = []; fx_drips = []; fx_motes = [];
    for (var i = 0; i < max(6, room_width div 120); i++) array_push(fx_drip_x, irandom_range(40, room_width - 40));
    for (var i = 0; i < 18; i++) array_push(fx_motes, { x: random(room_width), y: random_range(60, room_height - 80), ph: random(1000), sp: random_range(0.08, 0.25) });
    fx_flies = [];       // светлячки
    for (var i = 0; i < max(10, room_width div 70); i++) array_push(fx_flies, { x: random(room_width), y: random_range(80, room_height - 90), ph: random(1000), dir: random(360) });
}
function cave_fx_step() {
    if (random(1) < 0.035) {
        var _dx = fx_drip_x[irandom(array_length(fx_drip_x) - 1)];
        var _cy = 0; with (obj_side_solid) if (y1 <= 0 && _dx >= x1 && _dx < x2) _cy = max(_cy, y2);   // нижняя кромка потолка
        array_push(fx_drips, { x: _dx, y: _cy, vy: 0, t: -1 });
    }
    for (var i = array_length(fx_drips) - 1; i >= 0; i--) {
        var d = fx_drips[i];
        if (d.t < 0) {
            d.vy = min(d.vy + 0.25, 7); d.y += d.vy;
            var _g = side_ground_below(d.x, d.x + 1, d.y - d.vy);
            if (d.y >= _g) { d.y = _g; d.t = 0; }
        } else {
            d.t += 1;
            if (d.t > 12) array_delete(fx_drips, i, 1);
        }
    }
    for (var i = 0; i < array_length(fx_motes); i++) {
        var m = fx_motes[i];
        m.ph += 1;
        m.x += sin(m.ph / 120) * m.sp;
        m.y += cos(m.ph / 160) * m.sp * 0.5 - 0.04;
        if (m.y < 40) m.y = room_height - 80;
    }
    for (var i = 0; i < array_length(fx_flies); i++) {
        var f = fx_flies[i];
        f.ph += 1; f.dir += sin(f.ph / 37) * 4;
        f.x = clamp(f.x + lengthdir_x(0.35, f.dir), 10, room_width - 10);
        f.y = clamp(f.y + lengthdir_y(0.35, f.dir), 60, room_height - 90);
    }
}
function cave_fx_draw() {
    draw_set_color(make_color_rgb(170, 190, 230));
    for (var i = 0; i < array_length(fx_drips); i++) {
        var d = fx_drips[i];
        if (d.t < 0) { draw_set_alpha(0.7); draw_line(d.x, d.y - 3, d.x, d.y); }
        else { draw_set_alpha(0.6 * (1 - d.t / 12)); var _r = 1 + d.t * 0.4; draw_point(d.x - _r, d.y - 1); draw_point(d.x + _r, d.y - 1); }
    }
    draw_set_color(make_color_rgb(205, 180, 255));
    for (var i = 0; i < array_length(fx_motes); i++) {
        var m = fx_motes[i];
        draw_set_alpha(0.25 + 0.3 * (0.5 + 0.5 * sin(m.ph / 30 + i)));
        draw_point(floor(m.x), floor(m.y));
    }
    gpu_set_blendmode(bm_add);
    for (var i = 0; i < array_length(fx_flies); i++) {
        var f = fx_flies[i];
        var _tw = 0.5 + 0.5 * sin(f.ph / 20 + i);
        draw_set_color(make_color_rgb(200, 255, 130));
        draw_set_alpha(0.2 * _tw); draw_circle(f.x, f.y, 6, false);
        draw_set_alpha(0.9 * _tw); draw_rectangle(floor(f.x), floor(f.y), floor(f.x) + 1, floor(f.y) + 1, false);
    }
    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1); draw_set_color(c_white);
}

/// Фон пещеры: дальняя каменная стена (тёмно-серая) + пятна мха и тени (bg_spots)
function cave_draw_backdrop() {
    var _cam = view_camera[0];
    var _vx = camera_get_view_x(_cam), _vy = camera_get_view_y(_cam);
    side_tile_rect(spr_cave_backwall, max(0, _vx - 64), max(0, _vy - 64), min(room_width, _vx + 1024), min(room_height, _vy + 604), make_color_rgb(150, 145, 162));   // дальше — темнее
    for (var i = 0; i < array_length(bg_spots); i++) {
        var s = bg_spots[i];
        draw_set_color(s.c); draw_set_alpha(0.35); draw_ellipse(s.x - s.w, s.y - s.h, s.x + s.w, s.y + s.h, false);
    }
    draw_set_alpha(1); draw_set_color(c_white);
}
function cave_backdrop_init() {
    bg_spots = [];
    random_set_seed(room_width * 7 + 36);
    for (var i = 0; i < room_width div 40; i++) {
        var _c = choose(make_color_rgb(30, 28, 36), make_color_rgb(60, 84, 60), make_color_rgb(36, 34, 44));
        array_push(bg_spots, { x: random(room_width), y: random_range(40, room_height - 60), w: random_range(10, 40), h: random_range(6, 22), c: _c });
    }
    randomize();
}

/// Хранитель меча: длинное синее одеяние, высокая конусная шляпа, широко раскрытые глаза, посох.
/// _x — центр, _fy — пол под ним, _tilt — наклон головы (градусы), _staff_up 0..1 — посох поднят для удара
function cave_draw_keeper(_x, _fy, _alpha, _tilt, _staff_up) {
    if (_alpha <= 0) return;
    draw_set_alpha(_alpha);
    var _robe = make_color_rgb(54, 78, 160), _robe_d = make_color_rgb(36, 52, 116), _hat = make_color_rgb(44, 52, 130);
    // посох (в правой руке — он смотрит влево, на Макс)
    var _sy = _fy - 6 - _staff_up * 16;
    draw_set_color(make_color_rgb(110, 76, 44)); draw_line_width(_x - 22, _sy - 70, _x - 22, _sy, 3);
    draw_set_color(make_color_rgb(150, 200, 230)); draw_circle(_x - 22, _sy - 73, 4, false);
    // одеяние: трапеция до пола
    draw_set_color(_robe);
    draw_triangle(_x - 16, _fy, _x + 16, _fy, _x, _fy - 52, false);
    draw_rectangle(_x - 10, _fy - 44, _x + 10, _fy, false);
    draw_set_color(_robe_d); draw_rectangle(_x - 16, _fy - 4, _x + 16, _fy, false);
    draw_set_color(make_color_rgb(54, 78, 160)); draw_rectangle(_x - 18, _fy - 34, _x - 10, _fy - 26, false);   // рукав к посоху
    // голова (наклонена)
    var _hx = _x + lengthdir_x(4, 90 + _tilt) - 1, _hy = _fy - 54;
    draw_set_color(make_color_rgb(232, 190, 160)); draw_circle(_hx, _hy, 8, false);
    draw_set_color(make_color_rgb(236, 236, 240));                                    // длинная борода
    draw_triangle(_hx - 7, _hy + 2, _hx + 7, _hy + 2, _hx - 1, _hy + 24, false);
    draw_set_color(c_white); draw_circle(_hx - 4, _hy - 2, 3, false); draw_circle(_hx + 3, _hy - 3, 3, false);   // огромные глаза
    draw_set_color(make_color_rgb(30, 24, 40)); draw_point(_hx - 5, _hy - 2); draw_point(_hx + 2, _hy - 3);
    // высокая конусная шляпа со звёздами
    draw_set_color(_hat);
    draw_triangle(_hx - 13, _hy - 6, _hx + 13, _hy - 8, _hx + 4 + _tilt * 0.3, _hy - 52, false);
    draw_rectangle(_hx - 15, _hy - 8, _hx + 15, _hy - 5, false);
    draw_set_color(make_color_rgb(240, 214, 110));
    draw_point(_hx - 1, _hy - 20); draw_point(_hx + 4, _hy - 32); draw_point(_hx + 1, _hy - 42);
    draw_set_alpha(1); draw_set_color(c_white);
}

/// Глиняный страж. _r — радиус, _ang — поворот трещин (катится), _eye 0..1 — глаза открыты,
/// _arm 0..1 — руки видны, _arm_up 0..1 — руки подняты (удар), _mood: "angry" / "calm" / "shy"
function cave_draw_clay(_x, _cy, _r, _ang, _eye, _arm, _arm_up, _mood) {
    var _cl = make_color_rgb(156, 104, 72), _cd = make_color_rgb(104, 66, 46), _cl2 = make_color_rgb(186, 134, 98);
    // руки — короткие массивные
    if (_arm > 0) {
        draw_set_color(_cd);
        var _ay = _cy + 4 - _arm_up * 30;
        draw_roundrect_ext(_x - _r - 14 * _arm, _ay - 8, _x - _r + 8, _ay + 12, 8, 8, false);
        draw_roundrect_ext(_x + _r - 8, _ay - 8, _x + _r + 14 * _arm, _ay + 12, 8, 8, false);
    }
    draw_set_color(_cl); draw_circle(_x, _cy, _r, false);
    draw_set_color(_cl2); draw_circle(_x - _r * 0.35, _cy - _r * 0.4, _r * 0.32, false);
    draw_set_color(_cd);
    for (var k = 0; k < 4; k++) {                                         // трещины и камешки — крутятся с шаром
        var _a = _ang + k * 90 + 20;
        var _px = _x + lengthdir_x(_r * 0.55, _a), _py = _cy + lengthdir_y(_r * 0.55, _a);
        draw_line(_px, _py, _px + lengthdir_x(_r * 0.3, _a + 40), _py + lengthdir_y(_r * 0.3, _a + 40));
        draw_set_color(make_color_rgb(120, 116, 112));
        draw_rectangle(_x + lengthdir_x(_r * 0.75, _a + 45), _cy + lengthdir_y(_r * 0.75, _a + 45), _x + lengthdir_x(_r * 0.75, _a + 45) + 2, _cy + lengthdir_y(_r * 0.75, _a + 45) + 2, false);
        draw_set_color(_cd);
    }
    draw_circle(_x, _cy, _r, true);
    if (_eye > 0) {
        var _ex = _r * 0.32, _ey = _cy - _r * 0.18, _eh = max(1, _r * 0.17 * _eye);
        var _look = (_mood == "shy") ? -3 : 0;
        draw_set_color(make_color_rgb(250, 240, 220));
        draw_ellipse(_x - _ex - 6, _ey - _eh, _x - _ex + 6, _ey + _eh, false);
        draw_ellipse(_x + _ex - 6, _ey - _eh, _x + _ex + 6, _ey + _eh, false);
        draw_set_color(make_color_rgb(30, 22, 20));
        draw_rectangle(_x - _ex - 1 + _look, _ey - 1, _x - _ex + 1 + _look, _ey + 1, false);
        draw_rectangle(_x + _ex - 1 + _look, _ey - 1, _x + _ex + 1 + _look, _ey + 1, false);
        draw_set_color(_cd);
        if (_mood == "angry") {
            draw_line_width(_x - _ex - 7, _ey - _eh - 5, _x - _ex + 6, _ey - _eh - 1, 2);
            draw_line_width(_x + _ex - 6, _ey - _eh - 1, _x + _ex + 7, _ey - _eh - 5, 2);
        } else {
            draw_line_width(_x - _ex - 6, _ey - _eh - 3, _x - _ex + 6, _ey - _eh - 3, 2);
            draw_line_width(_x + _ex - 6, _ey - _eh - 3, _x + _ex + 6, _ey - _eh - 3, 2);
        }
    }
    draw_set_color(c_white);
}

// ---------- сердечки (волшебный сироп лягушонка: 3 сердечка) ----------
/// Одно сердечко. _full — полное/пустое, _s — масштаб
function heart_draw(_x, _y, _s, _full, _a) {
    draw_set_alpha(_a);
    draw_set_color(make_color_rgb(60, 20, 30));
    draw_circle(_x - 4 * _s, _y - 2 * _s, 5 * _s, false); draw_circle(_x + 4 * _s, _y - 2 * _s, 5 * _s, false);
    draw_triangle(_x - 9 * _s, _y - 1 * _s, _x + 9 * _s, _y - 1 * _s, _x, _y + 9 * _s, false);
    draw_set_color(_full ? make_color_rgb(235, 70, 100) : make_color_rgb(90, 70, 80));
    draw_circle(_x - 4 * _s, _y - 2 * _s, 4 * _s, false); draw_circle(_x + 4 * _s, _y - 2 * _s, 4 * _s, false);
    draw_triangle(_x - 8 * _s, _y - 1 * _s, _x + 8 * _s, _y - 1 * _s, _x, _y + 7.5 * _s, false);
    if (_full) { draw_set_color(make_color_rgb(255, 180, 200)); draw_rectangle(_x - 6 * _s, _y - 4 * _s, _x - 5 * _s, _y - 3 * _s, false); }
    draw_set_alpha(1); draw_set_color(c_white);
}
/// Ряд сердечек в левом верхнем углу (под монетами) — вызывать в Draw GUI
function hearts_draw() {
    if (!variable_global_exists("hearts_max") || global.hearts_max <= 0) return;
    for (var i = 0; i < global.hearts_max; i++) heart_draw(30 + i * 24, 62, 1, i < global.hearts, 1);
}
