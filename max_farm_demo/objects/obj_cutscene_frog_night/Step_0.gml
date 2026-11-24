// ===== НОЧЬ: ЛЯГУШОНОК И КАРТА (STEP) =====
phase_timer++;
frog_anim++;

// Прыжок по дуге: hop_from -> hop_to за hop_len кадров, высота hop_h; true — приземлился
var _hop = function() {
    hop_t++;
    var _k = min(hop_t / hop_len, 1);
    fx = lerp(hop_from[0], hop_to[0], _k);
    fy = lerp(hop_from[1], hop_to[1], _k) - sin(_k * pi) * hop_h;
    return (_k >= 1);
};
var _start_hop = function(_tx, _ty, _len, _h) {
    hop_from = [fx, fy]; hop_to = [_tx, _ty]; hop_len = _len; hop_h = _h; hop_t = 0;
};
// Шаг к точке; true — пришёл
var _walk_to = function(_tx, _ty, _spd) {
    var _d = point_distance(fx, fy, _tx, _ty);
    if (_d <= _spd) { fx = _tx; fy = _ty; return true; }
    fx += (_tx - fx) / _d * _spd; fy += (_ty - fy) / _d * _spd;
    f_spr = (_ty - fy > abs(_tx - fx)) ? spr_frog_idle_down : spr_frog_walk_side_left;
    f_flip = (_tx > fx);
    return false;
};
// Крошки из миски
var _crumbs = function(_n) {
    repeat (_n) array_push(crumbs, { x: bowl_x + 16 + irandom_range(-8, 8), y: bowl_y + 14,
                                     vx: random_range(-1.2, 1.2), vy: random_range(-2.4, -1.2), life: 30 });
};

switch (phase) {

    case 2: // полное затемнение
        darkness = min(darkness + 0.06, 1);
        if (phase_timer > 15) { phase = 3; phase_timer = 0; text_alpha = 0; }
    break;

    case 3: // надпись «Ночью в огороде...»
        text_alpha = min(text_alpha + 0.06, 1);
        if (phase_timer > 90) { darkness = NIGHT_DARK; phase = 4; phase_timer = 0; t = 0; }
    break;

    case 4: // лягушонок
        t++;
        f_frame_lock = -1;
        switch (st) {
            case "emerge":   // пауза в тишине, потом из-за грядки показываются шляпка и глаза
                f_spr = spr_frog_idle_down; f_flip = false;
                if (t == 50 && audio_exists(snd_rustle)) audio_play_sound(snd_rustle, 2, false);
                if (t > 50) f_vis_h = min(14, f_vis_h + 0.5);
                if (t > 100) { st = "peek"; t = 0; }
            break;
            case "peek":     // выглядывает: глянул влево, вправо, снова на миску
                f_frame_lock = 0;
                if (t < 40)       { f_spr = spr_frog_walk_side_left; f_flip = false; }
                else if (t < 80)  { f_spr = spr_frog_walk_side_left; f_flip = true;  }
                else              { f_spr = spr_frog_idle_down;      f_flip = false; }
                if (t > 110) { st = "rise"; t = 0; }
            break;
            case "rise":     // вылезает целиком
                f_vis_h = min(32, f_vis_h + 1.5);
                if (f_vis_h >= 32) { st = "hop"; _start_hop(eat_x, eat_y, 46, 46); }
            break;
            case "hop":      // прыжок через забор к миске
                f_spr = spr_frog_walk_side_left; f_flip = true; f_frame_lock = 1;
                if (_hop()) { st = "check"; t = 0; }
            break;
            case "check":    // проверяет, нет ли кого рядом
                f_frame_lock = 0;
                if (t < 30)        { f_spr = spr_frog_idle_down;      f_flip = false; }
                else if (t < 60)   { f_spr = spr_frog_walk_side_left; f_flip = true;  }
                else if (t < 90)   { f_spr = spr_frog_idle_up;        f_flip = false; }
                else               { f_spr = spr_frog_walk_side_left; f_flip = false; }
                if (t > 110) { st = "sniff"; t = 0; }
            break;
            case "sniff":    // нюхает: тянется к миске три раза
                f_spr = spr_frog_walk_side_left; f_flip = false; f_frame_lock = 0;
                fx = eat_x - ((t div 10) mod 2) * 2;
                if (t > 70) { fx = eat_x; st = "taste"; t = 0; }
            break;
            case "taste":    // пробует маленький кусочек — и подпрыгивает от радости
                f_spr = spr_frog_walk_side_left; f_flip = false; f_frame_lock = 0;
                if (t == 10) { bowl_fr = 1; _crumbs(2); }
                if (t == 40) _start_hop(eat_x, eat_y, 18, 8);
                if (t > 40) _hop();
                if (t > 75) { fx = eat_x; fy = eat_y; st = "gobble"; t = 0; }
            break;
            case "gobble":   // быстро съедает остальное
                f_spr = spr_frog_walk_side_left; f_flip = false; f_frame_lock = (t div 4) mod 2;
                fx = eat_x - ((t div 3) mod 2);
                if (t mod 6 == 0) _crumbs(1);
                if (t == 30) bowl_fr = 2;
                if (t == 60) bowl_fr = 3;   // одна крошка остаётся — за ней он ещё вернётся
                if (t > 80) { fx = eat_x; st = "to_drop"; t = 0; }
            break;
            case "to_drop":  // отходит под камень, чтобы положить карту
                if (_walk_to(drop_x, drop_y, 1.2)) { st = "drop"; t = 0; }
            break;
            case "drop":     // достаёт сложенную карту и кладёт — сначала криво
                f_spr = spr_frog_idle_down; f_flip = false; f_frame_lock = 0;
                if (t == 25) {
                    global.magic_map_placed = true;
                    if (!instance_exists(obj_frog_map)) map_inst = instance_create_depth(map_tx + 7, map_ty + 3, 0, obj_frog_map);
                    else map_inst = instance_find(obj_frog_map, 0);
                }
                if (t > 55) { st = "fix"; t = 0; }
            break;
            case "fix":      // поправляет карту, чтобы её было хорошо видно
                f_spr = spr_frog_idle_down; f_flip = false; f_frame_lock = (t div 8) mod 2;
                if (instance_exists(map_inst)) {
                    map_inst.x = lerp(map_inst.x, map_tx, 0.08);
                    map_inst.y = lerp(map_inst.y, map_ty, 0.08);
                }
                if (t > 60) {
                    if (instance_exists(map_inst)) { map_inst.x = map_tx; map_inst.y = map_ty; }
                    st = "leave"; t = 0;
                }
            break;
            case "leave":    // уходит в темноту
                _walk_to(gone_x, gone_y, 1.4);
                f_alpha = max(0, 1 - t / 70);
                if (f_alpha <= 0) { st = "wait"; t = 0; }
            break;
            case "wait":     // тишина... и он возвращается
                if (t > 50) { st = "return"; t = 0; }
            break;
            case "return":   // быстро возвращается за последней крошкой
                f_alpha = min(1, f_alpha + 0.06);
                if (_walk_to(eat_x, eat_y, 3)) { st = "last_crumb"; t = 0; }
            break;
            case "last_crumb":
                f_spr = spr_frog_walk_side_left; f_flip = false; f_frame_lock = 0;
                if (t == 15) { bowl_fr = 4; _crumbs(1); }
                if (t == 25) _start_hop(eat_x, eat_y, 16, 6);
                if (t > 25) _hop();
                if (t > 50) { fx = eat_x; fy = eat_y; st = "run"; t = 0; }
            break;
            case "run":      // теперь точно убегает
                _walk_to(gone_x, gone_y, 3);
                f_alpha = max(0, 1 - t / 35);
                if (f_alpha <= 0) {
                    global.pudding_on_porch = false;
                    global.pudding_bowl_empty = true;   // утром на камне пустая миска и карта
                    phase = 7; phase_timer = 0;
                }
            break;
        }
    break;

    case 7: // рассвет
        darkness = max(darkness - 0.007, 0);
        if (darkness <= 0 && phase_timer > 60) { phase = 8; phase_timer = 0; }
    break;

    case 8: // утро: Макс просыпается в доме
        if (phase_timer > 90) {
            if (crickets_id >= 0) audio_stop_sound(crickets_id);
            global.frog_night_done     = true;
            global.frog_morning_dialog = true;  // утренний монолог Макс в доме (obj_day_controller)
            global.rain_day = instance_exists(obj_day_controller) ? obj_day_controller.day_index : -1;  // утром идёт дождь
            global.control_locked      = false;
            if (instance_exists(obj_max)) obj_max.visible = true;
            global.next_spawn_x = 96;
            global.next_spawn_y = 320;
            room_goto(rm_house_inside);
            instance_destroy();
        }
    break;
}

// крошки летят и падают
for (var i = array_length(crumbs) - 1; i >= 0; i--) {
    var _c = crumbs[i];
    _c.x += _c.vx; _c.y += _c.vy; _c.vy += 0.15; _c.life--;
    if (_c.life <= 0) array_delete(crumbs, i, 1);
}
