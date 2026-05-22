// ===== COINS HUD CREATE =====
// Persistent объект — разместить в rm_farm, сам переходит во все комнаты

if (instance_number(obj_ui_coins_hud) > 1) {
    instance_destroy();
    exit;
}

persistent = true;

// Анимация счётчика монет
if (!variable_global_exists("coins_anim_target"))  global.coins_anim_target  = 0;
if (!variable_global_exists("coins_anim_current")) global.coins_anim_current = 0;

// Плавное появление иконки (0.0 → 1.0)
fade_in = 0;
