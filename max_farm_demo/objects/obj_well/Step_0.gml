// === КОЛОДЕЦ (STEP) ===
if ((!variable_global_exists("control_locked") || !global.control_locked)
&&  instance_exists(obj_max)) {
    var _d = point_distance(x, y, obj_max.x, obj_max.y);
    if (_d < 48 && keyboard_check_pressed(ord("E"))) {
        inventory_add("water", 1);
        audio_play_sound(snd_water_can, 1, false, 0.6);

        var _hud = instance_find(obj_ui_inventory, 0);
        if (_hud != noone) with (_hud) show_item_pop(spr_water_drop, "+1");
    }
}
