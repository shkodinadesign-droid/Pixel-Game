// === КОЛОДЕЦ (CREATE) ===
// Источник воды для рецептов. Макс подходит — говорит реплику (один раз за игру),
// затем [E] — ведро опускается в колодец, плюх, поднимается полным, +1 вода (иконка ведра).
// Ведро и верёвка рисуются отдельно (spr_well_bucket / spr_well_bucket_full, tools/village/b14_well_bucket.py).

if (!variable_global_exists("well_remark_done")) global.well_remark_done = false;

// Геометрия в координатах спрайта колодца (78x112)
wl_left = x - sprite_xoffset;
wl_top  = y - sprite_yoffset;
bucket_x  = wl_left + 30;    // левый край ведра
bucket_y  = wl_top  + 61;    // верх ведра (ручка) в покое
rope_x    = wl_left + 38;    // верёвка от вала
rope_y0   = wl_top  + 55;    // низ вала
rim_y     = wl_top  + 83;    // передний край кладки: ниже — ведро скрыто
bucket_depth = 30;           // насколько опускается (полностью уходит в колодец)

// Анимация: idle → down → splash → up → drip → idle
well_state = "idle";
well_t     = 0;
bucket_dy  = 0;
bucket_full = false;
locked_by_well = false;

drops = [];                  // брызги/капли: {x, y, vx, vy, life}

// Реплика Макса
remark_text  = "А тут я могу набрать воду!";
remark_timer = 0;
remark_max   = room_speed * 2.5;

/// Макс рядом с колодцем (расстояние от его ног до прямоугольника маски)
function well_max_near() {
    if (!instance_exists(obj_max)) return false;
    var _mx = (obj_max.bbox_left + obj_max.bbox_right) * 0.5;
    var _my = obj_max.bbox_bottom;
    return point_distance(_mx, _my, clamp(_mx, bbox_left, bbox_right), clamp(_my, bbox_top, bbox_bottom)) < 24;
}

/// Брызги из колодца
function well_splash(_n) {
    repeat (_n) {
        array_push(drops, { x: rope_x + random_range(-6, 6), y: rim_y - 2,
                            vx: random_range(-0.8, 0.8), vy: random_range(-2.6, -1.2),
                            life: room_speed * random_range(0.4, 0.7) });
    }
}
