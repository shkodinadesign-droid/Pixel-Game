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
                var _th = sprite_get_height(spr_cave_earth_top);
                side_tile_rect(spr_cave_earth_top, x1, y1, x2, min(y2, y1 + _th));
                if (y2 > y1 + _th) side_tile_rect(spr_cave_earth, x1, y1 + _th, x2, y2);
                break;
            case "stone":
            case "earth":
                side_tile_rect(spr_cave_wall, x1, y1, x2, y2);
                draw_set_color(make_color_rgb(46, 30, 44));
                draw_rectangle(x1, y1, x2 - 1, y2 - 1, true);
                break;
            case "ledge":          // каменная плита: края + середина, верх плиты = линия ходьбы
                var _lw = sprite_get_width(spr_cave_ledge), _lh = sprite_get_height(spr_cave_ledge), _cap = 12;
                var _w = x2 - x1;
                draw_sprite_part(spr_cave_ledge, 0, 0, 0, _cap, _lh, x1, y1 - 3);
                for (var _sx = x1 + _cap; _sx < x2 - _cap; _sx += _lw - _cap * 2)
                    draw_sprite_part(spr_cave_ledge, 0, _cap, 0, min(_lw - _cap * 2, x2 - _cap - _sx), _lh, _sx, y1 - 3);
                draw_sprite_part(spr_cave_ledge, 0, _lw - _cap, 0, _cap, _lh, x2 - _cap, y1 - 3);
                break;
            case "rock":           // глыба — спрайт автора, растянутый на прямоугольник
                draw_sprite_stretched(spr_cave_rock, 0, x1 - 4, y1 - 4, x2 - x1 + 8, y2 - y1 + 6);
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

/// Хранитель (рисунок автора, spr_cave_keeper). Смотрит влево, на Макс.
/// _frame: 0..4 — стоит (дыхание), 5 — «?», 6 — поднимает посох, 7 — удар (дуга), 8 — посох в кристалле
function cave_draw_keeper(_x, _fy, _alpha, _frame) {
    if (_alpha <= 0) return;
    draw_sprite_ext(spr_cave_keeper, _frame, _x, _fy, -1, 1, 0, c_white, _alpha);
}
/// кадр «стоит»: медленное дыхание туда-обратно по кадрам 0..4
function cave_keeper_idle_frame() {
    var _k = (current_time div 220) mod 8;
    return (_k < 5) ? _k : 8 - _k;
}

/// Глиняный страж (рисунок автора: spr_clay_guardian — 10 кадров, spr_clay_ball — 7 кадров шара).
/// _cy — центр круга столкновений, _r — радиус; низ рисунка ставится на пол (_cy + _r).
/// Кадры стража: 0 глыба, 1 открыл глаза, 2 проснулся (рожки), 3-4 стоит, 5 руки вверх, 6 замах, 7 удар об пол,
/// 8 спокойный, 9 маленький, смущённый.
function cave_draw_clay(_x, _cy, _r, _ang, _eye, _arm, _arm_up, _mood) {
    var _fy = _cy + _r;
    if (_arm <= 0 && _eye <= 0 && _r < 40) {                 // шар: кадр по повороту + вращение
        var _n = sprite_get_number(spr_clay_ball);
        var _f = 1 + (floor(abs(_ang) / 50) mod (_n - 1));
        var _s = _r / 28;
        draw_sprite_ext(spr_clay_ball, _f, _x, _cy, _s, _s, _ang, c_white, 1);
        return;
    }
    var _fr;
    if (_mood == "shy") _fr = 9;
    else if (_mood == "calm") _fr = 8;
    else if (_arm <= 0) _fr = (_eye <= 0) ? 0 : ((_eye < 1) ? 1 : 2);
    else if (_arm < 0.6) _fr = 2;
    else if (_arm_up > 0.6) _fr = 5;
    else if (_arm_up > 0.15) _fr = 6;
    else if (_arm_up > 0.02) _fr = 7;
    else _fr = 3 + ((current_time div 400) mod 2);
    draw_sprite(spr_clay_guardian, _fr, _x, _fy);
}

// ---------- убранство пещеры (рисунок автора, spr_cave_deco_*) ----------
/// Добавить предмет: висящие — _y = низ потолка, стоящие — _y = пол. _glow — цвет свечения (кристаллы) или -1.
function cave_deco_add(_spr, _x, _y, _xs = 1, _tint = c_white, _glow = -1) {
    array_push(deco, { spr: _spr, x: _x, y: _y, xs: _xs, c: _tint, glow: _glow });
}
function cave_deco_draw() {
    for (var i = 0; i < array_length(deco); i++) { var d = deco[i]; draw_sprite_ext(d.spr, 0, d.x, d.y, d.xs, 1, 0, d.c, 1); }
}
/// свет кристаллов (вызывать между cave_light_begin и cave_light_end)
function cave_deco_lights(_flick) {
    for (var i = 0; i < array_length(deco); i++) {
        var d = deco[i]; if (d.glow == -1) continue;
        cave_light_circle(d.x, d.y - sprite_get_height(d.spr) * 0.5, 70 + sin(_flick / 30 + i) * 6, d.glow);
    }
}
/// мягкое фиолетовое сияние поверх темноты (после cave_light_end)
function cave_deco_glow(_flick) {
    gpu_set_blendmode(bm_add);
    for (var i = 0; i < array_length(deco); i++) {
        var d = deco[i]; if (d.glow == -1) continue;
        draw_set_color(make_color_rgb(120, 60, 150)); draw_set_alpha(0.10 + 0.04 * sin(_flick / 25 + i));
        draw_circle(d.x, d.y - sprite_get_height(d.spr) * 0.4, sprite_get_width(d.spr) * 0.7, false);
    }
    gpu_set_blendmode(bm_normal); draw_set_alpha(1); draw_set_color(c_white);
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
