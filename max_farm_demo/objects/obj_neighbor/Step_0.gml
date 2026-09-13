// =====================
// NEIGHBOR (STEP)
// =====================

depth = -bbox_bottom;

// === ИДЁТ К МАКС ПО ДОРОГЕ (только по X) ===
if (approaching) {
    if (instance_exists(obj_max)) {
        // Цель фиксируется один раз при старте подхода — не гоняемся за
        // живой позицией Макс каждый кадр (игрок мог отойти назад и
        // спровоцировать ложное "дошли", запуская диалог раньше времени)
        if (!variable_instance_exists(id, "target_locked")) {
            target_x     = obj_max.x - 80;
            target_locked = true;
        }

        // Макс замечает Мэгги и поворачивается
        if (obj_max.x - x < 220) {
            obj_max.sprite_index     = spr_max_idle_left;
            obj_max.direction_facing = "left";
            obj_max.image_speed      = 0;
            obj_max.image_index      = 0;
        }
    }

    if (x < target_x - 4) {
        x           += move_speed;
        sprite_index = spr_magiie_walk_right;
        image_speed  = 0.5;
    } else {
        approaching  = false;
        sprite_index = spr_maggie_idle_right;
        image_speed  = 0.5;
        alarm[0]     = 30;
    }
}

// === УХОДИТ ПОСЛЕ ДИАЛОГА ===
if (leaving) {
    x -= move_speed;
    sprite_index = spr_maggie_walk_left;
    image_speed  = 0.5;
    if (x < -150) {
        instance_destroy();
        exit;
    }
}
