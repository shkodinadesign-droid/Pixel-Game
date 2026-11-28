// ===== ЁЖИК (STEP) =====
depth = -y;
var _d = 9999;
if (instance_exists(obj_max)) _d = point_distance(x, y, obj_max.x + 16, obj_max.y + 47);   // до ног Макс
if (state == "sit") {
    image_index = ((current_time div 500) mod 5 == 0) ? 3 : 2;      // изредка шевелит носом
    if (_d < 56) { state = "ball"; image_index = 0; calm_timer = 0; }
} else {
    image_index = 0;
    calm_timer = (_d > 96) ? calm_timer + 1 : 0;
    if (calm_timer > 120) state = "sit";                            // ~2 с без Макс рядом
}
