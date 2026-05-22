// rm_farm — Creation Code (только для этой комнаты)

room_speed = 60;
instance_activate_all();

// === ПЕРСИСТЕНТНОСТЬ ГРЯДОК ===
// При повторном входе убираем дубли: room-редактор создаёт свежие (persistent=false),
// а старые персистентные уже живут в памяти — оставляем старые, новые уничтожаем.
if (!variable_global_exists("rm_farm_visited")) global.rm_farm_visited = false;
if (global.rm_farm_visited) {
    with (obj_soil) {
        if (!persistent) instance_destroy();
    }
    with (obj_crop) {
        if (!persistent) instance_destroy();
    }
}
global.rm_farm_visited = true;
// Помечаем все оставшиеся грядки и растения персистентными
with (obj_soil) { persistent = true; }
with (obj_crop) { persistent = true; }

if (variable_global_exists("paused"))     global.paused   = false;
if (variable_global_exists("cutscene"))   global.cutscene = false;
if (variable_global_exists("input_lock")) global.input_lock = false;

var player_obj = asset_get_index("obj_max"); // если игрок иначе называется — подставь строкой его имя
if (player_obj != -1 && instance_exists(player_obj)) {
    var p = instance_find(player_obj, 0);
    if (p != noone) {
        if (variable_instance_exists(p, "can_move"))        p.can_move = true;
        if (variable_instance_exists(p, "freeze"))          p.freeze = false;
        if (variable_instance_exists(p, "is_input_locked")) p.is_input_locked = false;
        if (variable_instance_exists(p, "hsp")) p.hsp = 0;
        if (variable_instance_exists(p, "vsp")) p.vsp = 0;
        p.speed = 0;

        // возвращаем к двери, откуда заходили
        if (variable_global_exists("return_spawn_x")) {
            p.x = global.return_spawn_x;
            p.y = global.return_spawn_y;
        }
    }
}

// === КОТИК (с Дня 1 — лежанка всегда видна) ===
if (!instance_exists(obj_kitten)) {
    instance_create_layer(540, 280, "Instances", obj_kitten);
}
// Подстилка — отдельный объект с depth=2000, всегда за персонажами
var _bed_idx = asset_get_index("obj_kitten_bed");
if (_bed_idx != -1 && !instance_exists(_bed_idx)) {
    instance_create_layer(540, 280, "Instances", _bed_idx);
}

// === МЭГГИ (День 2) ===
if (!variable_global_exists("kitten_arrived")) global.kitten_arrived = false;
var _farm_day = instance_exists(obj_day_controller) ? obj_day_controller.day_index : 1;
if (!global.kitten_arrived && _farm_day >= 2 && !instance_exists(obj_maggie_day2)) {
    instance_create_layer(-60, 300, "Instances", obj_maggie_day2);
}

// === ГРЯДКИ ПУСТЫЕ ПРИ СТАРТЕ ===
// Игрок должен сам посадить семена после прочтения письма от бабушки

// Показываем грядки и растения (они могли быть скрыты в доме)
with (obj_soil) {
    visible = true;
}

with (obj_crop) {
    visible = true;
}

// Утренний диалог Дня 2 создаётся в obj_day_controller/Step_0.gml (после Room Start)

// === НОВЫЕ ГРЯДКИ: картофель и клубника ===
// Создаём один раз, делаем persistent чтобы сохранялись при смене комнат
if (!variable_global_exists("extra_fields_created")) global.extra_fields_created = false;
if (!global.extra_fields_created) {
    var _soil_lyr = -1;
    if (instance_exists(obj_soil)) {
        _soil_lyr = instance_find(obj_soil, 0).layer;
    }
    if (_soil_lyr == -1) _soil_lyr = layer_get_id("Instances");

    var _px = [192, 224, 256];
    var _s;

    // Картофельные грядки (3 штуки, невскопанные)
    for (var i = 0; i < 3; i++) {
        _s = instance_create_layer(_px[i], 448, _soil_lyr, obj_soil);
        _s.dug     = false;
        _s.covered = false;
        _s.persistent = true;
        with (_s) soil_update_sprite();
    }

    // Клубничные грядки (3 штуки, невскопанные)
    for (var i = 0; i < 3; i++) {
        _s = instance_create_layer(_px[i], 512, _soil_lyr, obj_soil);
        _s.dug     = false;
        _s.covered = false;
        _s.persistent = true;
        with (_s) soil_update_sprite();
    }

    global.extra_fields_created = true;
    show_debug_message("Новые грядки созданы (картофель + клубника)!");
}
