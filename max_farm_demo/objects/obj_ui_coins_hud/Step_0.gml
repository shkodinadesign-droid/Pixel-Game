// ===== COINS HUD STEP =====

// Анимация счётчика: global.coins_anim_current ползёт к target
if (global.coins_anim_current < global.coins_anim_target) {
    global.coins_anim_current++;
}

// Плавное появление при первом начислении монет
if (global.coins > 0 || global.coins_anim_target > 0) {
    fade_in = min(fade_in + 0.06, 1);
}
