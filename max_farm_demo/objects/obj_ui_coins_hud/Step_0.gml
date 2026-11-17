// ===== COINS HUD STEP =====

// Анимация счётчика: цель — всегда настоящая сумма global.coins (покупки, продажи, награды — любые изменения),
// показываемое значение ползёт к ней вверх или вниз; при большой разнице — быстрее.
if (variable_global_exists("coins")) global.coins_anim_target = global.coins;
var _diff = global.coins_anim_target - global.coins_anim_current;
if (_diff != 0) {
    var _step = max(1, ceil(abs(_diff) / 20));
    global.coins_anim_current += sign(_diff) * min(_step, abs(_diff));
}

// Плавное появление при первом начислении монет
if (global.coins > 0 || global.coins_anim_target > 0) {
    fade_in = min(fade_in + 0.06, 1);
}
