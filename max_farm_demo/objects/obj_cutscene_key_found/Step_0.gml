// ===== МАКС НАШЛА КЛЮЧ (STEP) =====
t += 1;

// цель ключа — над головой Макс
var _tx = mx + 16, _ty = my - 12 - hop;
if (t <= T_RISE) {
    var _k = t / T_RISE;
    var _e = 1 - power(1 - _k, 3);         // плавное замедление в конце
    kx = lerp(kx0, _tx, _e);
    ky = lerp(ky0, _ty, _e) - sin(_k * pi) * 26;   // дугой вверх
} else {
    kx = _tx; ky = _ty;
}

// три радостных прыжка
if (t > T_RISE && t < T_JOY) {
    var _jt = (t - T_RISE) mod 40;
    hop = (_jt < 24) ? sin(_jt / 24 * pi) * 9 : 0;
} else hop = 0;

// искорки вокруг ключа
if (t > T_RISE - 10 && t < T_JOY && t mod 5 == 0) {
    var _a = random(360), _v = random_range(0.6, 1.4);
    array_push(sparks, { x: kx, y: ky, vx: lengthdir_x(_v, _a), vy: lengthdir_y(_v, _a) - 0.3, life: 40 });
}
for (var i = array_length(sparks) - 1; i >= 0; i--) {
    var s = sparks[i];
    s.x += s.vx; s.y += s.vy; s.vy += 0.02; s.life -= 1;
    if (s.life <= 0) array_delete(sparks, i, 1);
}

if (t == T_RISE) quest_item_add("secret_key");   // ключ — в хотбар

if (t >= T_END) {
    if (instance_exists(p)) p.visible = true;
    global.control_locked = false;
    instance_destroy();
    forest_on_dialog_finished("cache_after_key");
}
