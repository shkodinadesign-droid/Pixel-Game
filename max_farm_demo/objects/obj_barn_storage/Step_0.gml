if (place_meeting(x, y, obj_max)
&& keyboard_check_pressed(ord("E"))
&& global.inv_carrot > 0) {

    var n = global.inv_carrot;
    global.inv_carrot  = 0;
    global.barn_carrot += n;

    var hud = instance_find(obj_ui_inventory, 0);
    if (hud != noone) with (hud) show_carrot_pop("-" + string(n));
}
