// ===== АНИМАЦИЯ ПЕРЕДАЧИ ДНЕВНИКА - STEP =====

phase_timer += 1;

switch (phase) {
    case "give_diary":
        // Проигрываем анимацию передачи
        if (phase_timer >= anim_duration) {
            phase = "finishing";
            phase_timer = 0;
        }
        break;

    case "finishing":
        // Плавный переход - небольшая пауза перед завершением
        if (phase_timer >= 15) { // 0.25 секунды паузы
            phase = "done";
        }
        break;

    case "done":
        // Возвращаем видимость персонажей
        if (instance_exists(obj_grandma_Maggie)) {
            obj_grandma_Maggie.visible = true;
            obj_grandma_Maggie.state = "leaving";
        }
        if (instance_exists(obj_max)) {
            obj_max.visible = true;
            obj_max.image_speed = 0;
            obj_max.image_index = 0;
        }

        // Даём дневник в инвентарь с эффектом появления
        if (!variable_global_exists("has_diary")) global.has_diary = false;
        global.has_diary = true;
        global.diary_appear_alpha = 0; // начинаем с прозрачного

        // Открываем дневник на вкладке "Задания"
        var _dlyr = layer_get_id("GUI");
        if (_dlyr == -1) _dlyr = layer_get_id("Instances");
        if (_dlyr == -1) _dlyr = layer_get_id("Instances_3");
        if (_dlyr == -1) _dlyr = layer_get_id("letter");
        var _d = (_dlyr != -1)
            ? instance_create_layer(0, 0, _dlyr, obj_diary)
            : instance_create_depth(0, 0, 0, obj_diary); // гарантированно валидно, без привязки к слою
        _d.current_tab = 0;
        // Управление остаётся заблокированным — это уже сделал Create дневника (obj_diary),
        // снимется само, когда игрок закроет дневник.

        instance_destroy();
        break;
}
