// ===== АТМОСФЕРА (STEP) =====
var _outdoor = (room == rm_farm || room == rm_village || room == rm_forest_entrance);
var _indoor  = (room == rm_house_inside || room == rm_bakery || room == rm_joshua_shop
             || room == rm_butcher_shop || room == room_barn);
var _forest  = (room == rm_forest_entrance);

// Дождь: третий день, и дальше до утра — пока идёт ночная сцена с лягушонком
var _day  = instance_exists(obj_day_controller) ? obj_day_controller.day_index : 0;
var _rain = (_day == 3) || (_day == 4 && instance_exists(obj_cutscene_frog_night));

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

// --- светлячки: создаются заново при входе в лес ---
if (_forest && flies_room != room) {
    flies_room = room;
    flies = [];
    for (var k = 0; k < 9; k++) {
        array_push(flies, { x: random(room_width), y: random(room_height), ph: random(1000), sp: random_range(0.15, 0.35) });
    }
}
if (!_forest) flies_room = -1;
for (var k = 0; k < array_length(flies); k++) {
    var f = flies[k];
    f.ph += 1;
    f.x += sin(f.ph / 90) * f.sp;
    f.y += cos(f.ph / 130) * f.sp * 0.7;
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
