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

        // Разблокируем управление
        global.control_locked = false;

        instance_destroy();
        break;
}
