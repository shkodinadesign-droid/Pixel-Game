// ===== АТМОСФЕРА (STEP) =====
var _outdoor = (room == rm_farm || room == rm_village || room == rm_forest_entrance);
var _indoor  = (room == rm_house_inside || room == rm_bakery || room == rm_joshua_shop
             || room == rm_butcher_shop || room == room_barn || room == rm_maggie_house);
var _forest  = (room == rm_forest_entrance);

// Дождь: весь день после ночи с лягушонком (обычно день 4) — Макс находит карту и идёт в лес под дождём.
// global.rain_day ставит сцена лягушонка на рассвете; на саму ночь дождя нет.
var _day  = instance_exists(obj_day_controller) ? obj_day_controller.day_index : 0;
var _rain = variable_global_exists("rain_day") && (_day == global.rain_day) && !instance_exists(obj_cutscene_frog_night);

rain_alpha = clamp(rain_alpha + ((_rain && _outdoor) ? 0.01 : -0.02), 0, 1);

// --- капли ---
if (rain_alpha > 0) {
    var _dx = lengthdir_x(1, RAIN_ANGLE), _dy = lengthdir_y(1, RAIN_ANGLE);
    for (var i = 0; i < RAIN_COUNT; i++) {
        var d = drops[i];
        d.x += _dx * d.spd; d.y += _dy * d.spd;
        if (d.y > 560) {
            if (random(1) < 0.35) array_push(splashes, { x: d.x + random_range(-20, 20), y: random_range(40, 530), t: 0 });
            d.y = random_range(-40, -10); d.x = random(1100) - 70;
        }
    }
    for (var j = array_length(splashes) - 1; j >= 0; j--) {
        splashes[j].t += 1;
        if (splashes[j].t > 10) array_delete(splashes, j, 1);
    }
}

// --- пылинки: в лесу всегда, на улице — на следующий день после дождя ---
var _after_rain = variable_global_exists("rain_day") && global.rain_day >= 0 && _day == global.rain_day + 1;
var _motes_on = !_rain && (_forest || (_outdoor && _after_rain));
motes_alpha = clamp(motes_alpha + (_motes_on ? 0.01 : -0.02), 0, 1);
if (motes_alpha > 0) {
    for (var m = 0; m < array_length(motes); m++) {
        var d = motes[m];
        d.ph += 1;
        d.x += sin(d.ph / 110) * d.sp + 0.05;          // чуть сносит ветерком вправо
        d.y += cos(d.ph / 150) * d.sp * 0.6 - 0.03;    // и медленно вверх
        if (d.x > 970) d.x -= 980; if (d.x < -10) d.x += 980;
        if (d.y < -10) d.y += 560; if (d.y > 550) d.y -= 560;
    }
}

// --- бабочки: днём в огороде, не в дождь ---
var _dark = instance_exists(obj_day_controller) ? obj_day_controller.darkness : 0;
var _bfly_on = (room == rm_farm) && !_rain && _dark < 0.25 && !instance_exists(obj_cutscene_frog_night);
bfly_alpha = clamp(bfly_alpha + (_bfly_on ? 0.02 : -0.03), 0, 1);
if (room == rm_farm) {
    for (var b = 0; b < array_length(butterflies); b++) {
        var f = butterflies[b];
        f.ph += 1;
        if (point_distance(f.x, f.y, f.tx, f.ty) < 8 || random(1) < 0.004) {   // новая цветочная точка
            f.tx = random_range(GARDEN_X1, GARDEN_X2);
            f.ty = random_range(GARDEN_Y1, GARDEN_Y2);
        }
        var _dir = point_direction(f.x, f.y, f.tx, f.ty) + sin(f.ph / 9) * 50;  // зигзагом
        f.vx = lerp(f.vx, lengthdir_x(0.7, _dir), 0.08);
        f.vy = lerp(f.vy, lengthdir_y(0.7, _dir), 0.08);
        f.x += f.vx; f.y += f.vy;
    }
}

// --- звуки: целевая громкость каждой петли ---
var _night_scene = instance_exists(obj_cutscene_frog_night);   // сцена сама играет сверчков
var _target = [
    _rain ? (_forest ? 0.30 : (_outdoor ? 0.45 : (_indoor ? 0.14 : 0))) : 0,   // дождь (в доме — приглушённо)
    (_forest && !_night_scene) ? 0.30 : 0,                                      // сверчки
    _forest ? 0.14 : 0                                                          // шум леса — еле слышно
];
for (var s = 0; s < array_length(amb); s++) {
    var a = amb[s];
    var _t = _target[s];
    var _playing = (a.id >= 0 && audio_is_playing(a.id));
    if (_t > 0 && !_playing) {
        a.id = audio_play_sound(a.snd, 0, true, 0);
        audio_sound_gain(a.id, _t, 1500);          // плавное появление
        a.tgt = _t;
    } else if (_playing) {
        if (a.tgt != _t) {                         // зашла в дом / вышла / ушла из леса
            audio_sound_gain(a.id, _t, (_t > 0) ? 1000 : 1200);
            a.tgt = _t;
        }
        if (_t <= 0 && audio_sound_get_gain(a.id) <= 0.001) { audio_stop_sound(a.id); a.id = -1; }
    }
}
