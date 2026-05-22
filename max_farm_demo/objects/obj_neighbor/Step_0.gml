// =====================
// NEIGHBOR (STEP)
// =====================

// Динамическая глубина: чем ниже на экране, тем ближе к камере
depth = -bbox_bottom;

// === ЛОГИКА ПРИХОДА (движение слева) ===
if (approaching) {
    x += 2;
    if (x >= 192) {
        approaching = false;
        alarm[0] = 30;  // показываем диалог когда дошла
    }
}

// === ЛОГИКА УХОДА ПОСЛЕ ДИАЛОГА ===
if (leaving) {
    x -= 2;
    if (x < -50) {
        instance_destroy();
        exit;
    }
}

// === ОБЫЧНОЕ ВЗАИМОДЕЙСТВИЕ (если не уходит и intro сделано) ===
if (!leaving && intro_done) {
    // пример радиуса общения
    if (instance_exists(obj_max)) {
        var dist = point_distance(x, y, obj_max.x, obj_max.y);

        // если Макс рядом и нажали E — показать диалог (заглушка)
        if (dist < 48 && keyboard_check_pressed(ord("E"))) {
            show_debug_message("Talk to neighbor!");
            // тут позже вызовем твой obj_ui_letter или отдельный obj_dialog
        }
    }
}
