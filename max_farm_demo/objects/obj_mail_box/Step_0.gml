// === ПОЧТОВЫЙ ЯЩИК (STEP) ===

// --- 1. Проверяем, есть ли новое письмо ---
has_letter     = false;
current_letter = -1;

var _day = 1;
if (instance_exists(obj_day_controller)) {
    _day = obj_day_controller.day_index;
}

// ищем самое раннее непрочитанное письмо, чей день уже наступил
for (var i = 0; i < array_length(letter_db); i++) {
    var _lt = letter_db[i];
    if (_lt.trigger_day <= _day) {
        var _read = false;
        for (var j = 0; j < array_length(global.letters_read); j++) {
            if (global.letters_read[j] == _lt.id) {
                _read = true;
                break;
            }
        }
        if (!_read) {
            has_letter = true;
            current_letter = _lt;
            break;
        }
    }
}

// --- 2. Действие после закрытия письма (напр. спавн соседки) ---
if (pending_action != "" && !instance_exists(obj_ui_letter)) {
    if (pending_action == "spawn_neighbor") {
        // Проверка: не создаём соседку, если она уже существует
        if (!instance_exists(obj_neighbor) && instance_exists(obj_max)) {
            var _lyr = layer_get_id("Max");
            if (_lyr == -1) _lyr = layer;
            var inst = instance_create_layer(obj_max.x - 60, obj_max.y, _lyr, obj_neighbor);
            inst.target_id = obj_max;
        }
    }
    pending_action = "";
}

// --- 3. Взаимодействие: игрок рядом и жмёт E ---
if (has_letter && !global.control_locked) {
    if (instance_exists(obj_max)) {
        var p = instance_find(obj_max, 0);
        if (point_distance(x, y, p.x, p.y) < 48) {
            if (keyboard_check_pressed(ord("E"))) {
                // отмечаем как прочитанное
                array_push(global.letters_read, current_letter.id);

                // запоминаем on_close действие
                var _action = variable_struct_exists(current_letter, "on_close") ? current_letter.on_close : "";
                pending_action = _action;

                // открываем окно письма
                var _lyr = layer_get_id("letter");
                if (_lyr == -1) _lyr = layer;
                var _viewer = instance_create_layer(0, 0, _lyr, obj_ui_letter);
                _viewer.letter_data = current_letter;

                has_letter = false;
            }
        }
    }
}
