// Макс рядом и нажимает ↑ — собираем морковь
if (place_meeting(x, y, obj_max) && keyboard_check_pressed(ord("E"))) {
    inventory_add(ITEM_CARROT, 1);

    // вызвать вспышку из нового HUD
    var hud = instance_find(obj_ui_inventory, 0);
    if (hud != noone) with (hud) show_carrot_pop("+1");

    instance_destroy(); // убираем морковь с земли
}

