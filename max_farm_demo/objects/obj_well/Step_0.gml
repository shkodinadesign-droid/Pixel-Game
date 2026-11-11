// === КОЛОДЕЦ (STEP) ===
var _sec = room_speed;
var _near = well_max_near();

// --- реплика Макса при первом подходе ---
if (_near && !global.well_remark_done && well_state == "idle"
&&  (!variable_global_exists("control_locked") || !global.control_locked)) {
    global.well_remark_done = true;
    remark_timer = remark_max;
}
if (remark_timer > 0) remark_timer--;

// --- [E] — набрать воду ---
if (well_state == "idle" && _near && keyboard_check_pressed(ord("E"))
&&  (!variable_global_exists("control_locked") || !global.control_locked)) {
    remark_timer = 0;
    well_state = "down";
    well_t = 0;
    bucket_full = false;

    // Макс замирает и смотрит на колодец
    global.control_locked = true;
    locked_by_well = true;
    with (obj_max) {
        var _dx = (other.bbox_left + other.bbox_right) * 0.5 - (bbox_left + bbox_right) * 0.5;
        var _dy = (other.bbox_top + other.bbox_bottom) * 0.5 - bbox_bottom;
        if (abs(_dx) > abs(_dy)) direction_facing = (_dx > 0) ? "right" : "left";
        else                     direction_facing = (_dy > 0) ? "down"  : "up";
    }
}

// --- анимация ведра ---
well_t++;
switch (well_state) {
    case "down":                                   // ведро уходит вниз, ускоряясь
        var _k = min(1, well_t / (_sec * 0.9));
        bucket_dy = bucket_depth * _k * _k;
        if (_k >= 1) {
            well_state = "splash"; well_t = 0;
            audio_play_sound(snd_water_can, 1, false, 0.6);
            well_splash(8);
        }
        break;

    case "splash":                                 // пауза: ведро набирает воду
        if (well_t == round(_sec * 0.25)) well_splash(4);
        if (well_t >= _sec * 0.5) { well_state = "up"; well_t = 0; bucket_full = true; }
        break;

    case "up":                                     // поднимается рывками (крутят ворот)
        var _k2 = min(1, well_t / (_sec * 1.1));
        var _steps = floor(_k2 * 6) / 6;
        var _ease  = lerp(_steps, _k2, 0.6);
        bucket_dy = bucket_depth * (1 - _ease);
        if (_k2 >= 1) {
            bucket_dy = 0;
            well_state = "drip"; well_t = 0;
            inventory_add("water", 1);
            var _hud = instance_find(obj_ui_inventory, 0);
            if (_hud != noone) with (_hud) show_item_pop(spr_water_bucket, "+1");
        }
        break;

    case "drip":                                   // с полного ведра капает, Макс снова свободен
        if (well_t mod round(_sec * 0.3) == 1) {
            array_push(drops, { x: bucket_x + 9 + irandom_range(-5, 5), y: bucket_y + 20,
                                vx: 0, vy: 0.5, life: _sec * 0.5 });
        }
        if (well_t == round(_sec * 0.3) && locked_by_well) {
            global.control_locked = false;
            locked_by_well = false;
        }
        if (well_t >= _sec * 1.5) { well_state = "idle"; bucket_full = false; }
        break;
}

// --- капли ---
for (var i = array_length(drops) - 1; i >= 0; i--) {
    var _d = drops[i];
    _d.x += _d.vx; _d.y += _d.vy; _d.vy += 0.15; _d.life--;
    if (_d.life <= 0) array_delete(drops, i, 1);
}
