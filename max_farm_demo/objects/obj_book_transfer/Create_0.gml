// ===== АНИМАЦИЯ ПЕРЕДАЧИ ДНЕВНИКА =====

// Фазы: "give_diary", "done"
phase = "give_diary";

// Таймер анимации
phase_timer = 0;

// Получаем количество кадров в спрайте анимации
anim_frames = sprite_get_number(spr_maggie_idle_diary);
// Длительность = количество кадров * скорость (очень медленная анимация ~2 кадра в секунду)
anim_duration = anim_frames * 30;

// Позиции персонажей
maggie_x = 0;
maggie_y = 0;
max_x = 0;
max_y = 0;

if (instance_exists(obj_grandma_Maggie)) {
    maggie_x = obj_grandma_Maggie.x;
    maggie_y = obj_grandma_Maggie.y;
    // Скрываем Мэгги на время анимации
    obj_grandma_Maggie.visible = false;
}

if (instance_exists(obj_max)) {
    max_x = obj_max.x;
    max_y = obj_max.y;
    // Скрываем Макс на время анимации
    obj_max.visible = false;
}

// Глубина - рисуем на уровне персонажей
depth = -maggie_y;

// Инициализируем глобальную переменную для эффекта появления дневника
if (!variable_global_exists("diary_appear_alpha")) {
    global.diary_appear_alpha = 0;
}
